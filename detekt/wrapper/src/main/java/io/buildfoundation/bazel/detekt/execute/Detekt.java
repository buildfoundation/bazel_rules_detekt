package io.buildfoundation.bazel.detekt.execute;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.ServiceConfigurationError;
import java.util.ServiceLoader;

public interface Detekt {

    void execute(String[] args, PrintStream output, PrintStream error);

    final class Impl implements Detekt {

        private final Runner runner;

        public Impl() {
            this.runner = Runner.load();
        }

        @Override
        public void execute(String[] args, PrintStream output, PrintStream error) {
            Translation translation = translate(args, runner.v2);
            ByteArrayOutputStream capturedOutput = translation.textReport == null ? null : new ByteArrayOutputStream();
            PrintStream invocationOutput = capturedOutput == null ? output : new PrintStream(capturedOutput);

            try {
                RuntimeException resultError = runner.run(translation.arguments, invocationOutput, error);
                if (resultError != null) {
                    throw resultError;
                }
            } finally {
                if (capturedOutput != null) {
                    invocationOutput.flush();
                    byte[] report = capturedOutput.toByteArray();
                    output.write(report, 0, report.length);
                    output.flush();
                    writeTextReport(translation.textReport, report);
                    invocationOutput.close();
                }
            }

            List<String> argsList = Arrays.asList(args);
            if (argsList.contains("--create-baseline")) {
                String baseline = argsList.get(argsList.indexOf("--baseline") + 1);
                File baselineFile = new File(baseline);
                if (!baselineFile.exists()) {
                    try {
                        createEmptyBaseline(baselineFile);
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                }
            }
        }

        /**
         * Adapts arguments emitted by the Starlark rule to the selected Detekt major version.
         *
         * <p>Detekt 1.x uses commas for the input/config/plugin lists, while Detekt 2.x uses the
         * host JVM's path separator. Keeping this translation here lets one wrapper work with
         * either CLI jar without linking against either CLI package at compile time.</p>
         */
        static Translation translate(String[] args, boolean v2) {
            List<String> translated = new ArrayList<>();
            String textReport = null;
            boolean hasAnalysisMode = false;
            boolean hasClasspath = false;

            for (int index = 0; index < args.length; index++) {
                String argument = args[index];

                if ("--max-issues".equals(argument) && v2) {
                    throw new IllegalArgumentException("max_issues is only supported by Detekt 1.x; use fail_on_severity for Detekt 2.x");
                }
                if ("--fail-on-severity".equals(argument) && !v2) {
                    throw new IllegalArgumentException("fail_on_severity is only supported by Detekt 2.x; use max_issues for Detekt 1.x");
                }

                if ("--analysis-mode".equals(argument)) {
                    hasAnalysisMode = true;
                }

                if ("--report".equals(argument) && index + 1 < args.length) {
                    String report = args[++index];
                    int separator = report.indexOf(':');
                    if (separator > 0 && v2) {
                        String reportType = report.substring(0, separator);
                        String reportPath = report.substring(separator + 1);
                        if ("txt".equals(reportType)) {
                            textReport = reportPath;
                            continue;
                        }
                        if ("xml".equals(reportType)) {
                            report = "checkstyle:" + reportPath;
                        }
                    }
                    translated.add(argument);
                    translated.add(report);
                    continue;
                }

                translated.add(argument);
                if (v2 && isPathListArgument(argument) && index + 1 < args.length) {
                    String value = args[++index];
                    translated.add(value.replace(",", File.pathSeparator));
                    if ("--classpath".equals(argument) && !value.isEmpty()) {
                        hasClasspath = true;
                    }
                }
            }

            if (v2 && hasClasspath && !hasAnalysisMode) {
                translated.add("--analysis-mode");
                translated.add("full");
            }

            return new Translation(translated.toArray(new String[0]), textReport);
        }

        private static boolean isPathListArgument(String argument) {
            return "--input".equals(argument) || "--config".equals(argument) ||
                    "--plugins".equals(argument) || "--classpath".equals(argument);
        }

        private static void writeTextReport(String path, byte[] report) {
            try {
                Files.write(Paths.get(path), report, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            } catch (IOException e) {
                throw new RuntimeException("Unable to write Detekt text report " + path, e);
            }
        }

        String emptyBaseLineContent = "<?xml version=\"1.0\" ?>\n" +
                "<SmellBaseline>\n" +
                "  <ManuallySuppressedIssues></ManuallySuppressedIssues>\n" +
                "  <CurrentIssues>\n" +
                "  </CurrentIssues>\n" +
                "</SmellBaseline>\n";

        private void createEmptyBaseline(File baselineFile) throws IOException {
            baselineFile.createNewFile();
            try (FileWriter writer = new FileWriter(baselineFile)) {
                writer.write(emptyBaseLineContent);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        static final class Translation {
            final String[] arguments;
            final String textReport;

            Translation(String[] arguments, String textReport) {
                this.arguments = arguments;
                this.textReport = textReport;
            }
        }

        private static final class Runner {
            private static final String V2_TOOLING = "dev.detekt.tooling.api.DetektCli";
            private static final String V1_TOOLING = "io.github.detekt.tooling.api.DetektCli";

            private final boolean v2;
            private final Object instance;
            private final Method runMethod;
            private final Method errorMethod;

            private Runner(boolean v2, Object instance, Method runMethod, Method errorMethod) {
                this.v2 = v2;
                this.instance = instance;
                this.runMethod = runMethod;
                this.errorMethod = errorMethod;
            }

            static Runner load() {
                List<String> failures = new ArrayList<>();
                for (String interfaceName : Arrays.asList(V2_TOOLING, V1_TOOLING)) {
                    try {
                        Class<?> toolingInterface = Class.forName(interfaceName);
                        ServiceLoader<?> providers = ServiceLoader.load(toolingInterface, toolingInterface.getClassLoader());
                        Iterator<?> providerIterator = providers.iterator();
                        if (!providerIterator.hasNext()) {
                            failures.add(interfaceName + " has no registered provider");
                            continue;
                        }
                        Method runMethod = toolingInterface.getMethod("run", String[].class, Appendable.class, Appendable.class);
                        Method errorMethod = runMethod.getReturnType().getMethod("getError");
                        return new Runner(V2_TOOLING.equals(interfaceName), providerIterator.next(), runMethod, errorMethod);
                    } catch (ClassNotFoundException e) {
                        failures.add(interfaceName + " was not found");
                    } catch (ReflectiveOperationException | LinkageError | ServiceConfigurationError e) {
                        failures.add(interfaceName + ": " + e.getMessage());
                    }
                }
                throw new IllegalStateException("No compatible Detekt tooling provider found: " + String.join("; ", failures));
            }

            RuntimeException run(String[] args, PrintStream output, PrintStream error) {
                try {
                    Object result = runMethod.invoke(instance, new Object[]{args, output, error});
                    Object resultError = errorMethod.invoke(result);
                    if (resultError == null) {
                        return null;
                    }
                    if (resultError instanceof RuntimeException) {
                        return (RuntimeException) resultError;
                    }
                    if (resultError instanceof Error) {
                        throw (Error) resultError;
                    }
                    if (resultError instanceof Throwable) {
                        return new RuntimeException((Throwable) resultError);
                    }
                    return new RuntimeException(String.valueOf(resultError));
                } catch (InvocationTargetException e) {
                    Throwable cause = e.getCause();
                    if (cause instanceof RuntimeException) {
                        throw (RuntimeException) cause;
                    }
                    if (cause instanceof Error) {
                        throw (Error) cause;
                    }
                    throw new IllegalStateException("Detekt CLI invocation failed", cause);
                } catch (ReflectiveOperationException e) {
                    throw new IllegalStateException("Unable to read the Detekt CLI result", e);
                }
            }
        }
    }
}
