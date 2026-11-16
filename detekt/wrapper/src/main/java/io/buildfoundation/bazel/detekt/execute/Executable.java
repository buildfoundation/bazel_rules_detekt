package io.buildfoundation.bazel.detekt.execute;

import io.buildfoundation.bazel.detekt.ExecutionUtils;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.Arrays;
import java.util.List;

public interface Executable {

    /**
     * Runs Detekt with paths resolved against {@code sandboxDir}, the request's multiplex sandbox,
     * or against the working directory when it is null.
     */
    ExecutableResult execute(String[] args, Path sandboxDir);

    default ExecutableResult execute(String[] args) {
        return execute(args, null);
    }

    final class DetektImpl implements Executable {

        private final Detekt detekt;
        private final String charset;

        public DetektImpl(Detekt detekt) {
            this.detekt = detekt;
            this.charset = Charset.defaultCharset().name();
        }

        @Override
        public ExecutableResult execute(String[] args, Path sandboxDir) {
            ByteArrayOutputStream outputBuffer = new ByteArrayOutputStream();
            PrintStream outputPrinter = new PrintStream(new BufferedOutputStream(outputBuffer));

            ByteArrayOutputStream errorBuffer = new ByteArrayOutputStream();
            PrintStream errorPrinter = new PrintStream(new BufferedOutputStream(errorBuffer));

            List<String> detektWrapperArguments = Arrays.asList(args);
            if (args.length == 1 && ExecutionUtils.isParamsFile(args[0])) {
                // drop leading `@` from params-file
                Path paramsFilePath = Paths.get(args[0].substring(1));
                if (sandboxDir != null) {
                    paramsFilePath = sandboxDir.resolve(paramsFilePath);
                }
                detektWrapperArguments = ExecutionUtils.readArgumentsFromFile(paramsFilePath);
            }
            if (sandboxDir != null) {
                detektWrapperArguments = ExecutionUtils.resolveSandboxPaths(detektWrapperArguments, sandboxDir);
            }

            ExecutableResult result;
            boolean reportWriteFailed = false;
            Path executionResultOutputPath = Paths.get(ExecutionUtils.getRequiredArgumentValue(detektWrapperArguments, "--execution-result"));

            try {
                List<String> detektExecutableArguments = ExecutionUtils.sanitizeDetektArguments(detektWrapperArguments);
                detekt.execute(detektExecutableArguments.toArray(new String[0]), outputPrinter, errorPrinter);
                result = new ExecutableResult.Success();
            } catch (Exception e) {
                outputPrinter.flush();
                e.printStackTrace(errorPrinter);
                errorPrinter.flush();

                try {
                    String output = ExecutionUtils.relativizePaths(outputBuffer.toString(charset), sandboxDir);
                    String error = ExecutionUtils.relativizePaths(errorBuffer.toString(charset), sandboxDir);
                    String diagnostics = output + error;
                    try {
                        writeTextReport(detektWrapperArguments, output, error);
                    } catch (RuntimeException reportError) {
                        reportWriteFailed = true;
                        diagnostics += System.lineSeparator() + reportError.getMessage();
                    }

                    result = new ExecutableResult.Failure(diagnostics);
                } catch (UnsupportedEncodingException unsupportedEncodingException) {
                    result = new ExecutableResult.Failure("Unknown Detekt error, please report this issue");
                }
            } finally {
                outputPrinter.close();
                errorPrinter.close();
            }

            if (sandboxDir != null && !reportWriteFailed) {
                try {
                    relativizeTextReport(detektWrapperArguments, sandboxDir);
                } catch (IOException e) {
                    reportWriteFailed = true;
                    result = new ExecutableResult.Failure("Unable to rewrite Detekt text report: " + e.getMessage());
                }
            }

            ExecutionUtils.writeExecutionResultToFile(result.statusCode(), executionResultOutputPath);

            if (ExecutionUtils.shouldRunAsTestTarget(detektWrapperArguments) && !reportWriteFailed) {
                result = new ExecutableResult.Success();
            }
            return result;
        }

        private void writeTextReport(List<String> arguments, String output, String error) {
            String reportPath = getTextReportPath(arguments);
            if (reportPath == null || (output.isEmpty() && error.isEmpty())) {
                return;
            }

            try {
                Path path = Paths.get(reportPath);
                if (!Files.exists(path) || Files.size(path) == 0) {
                    Files.write(path, (output + error).getBytes(charset), StandardOpenOption.CREATE,
                            StandardOpenOption.TRUNCATE_EXISTING);
                } else if (!error.isEmpty()) {
                    Files.write(path, error.getBytes(charset), StandardOpenOption.APPEND);
                }
            } catch (IOException e) {
                throw new RuntimeException("Unable to write Detekt text report " + reportPath, e);
            }
        }

        /**
         * Detekt prints findings with absolute paths, which under a multiplex sandbox name the
         * request's sandbox directory; strip it so the report is the same whichever sandbox ran it.
         */
        private void relativizeTextReport(List<String> arguments, Path sandboxDir) throws IOException {
            String reportPath = getTextReportPath(arguments);
            if (reportPath == null || !Files.exists(Paths.get(reportPath))) {
                return;
            }
            Path path = Paths.get(reportPath);
            String content = new String(Files.readAllBytes(path), charset);
            String relativized = ExecutionUtils.relativizePaths(content, sandboxDir);
            if (!relativized.equals(content)) {
                Files.write(path, relativized.getBytes(charset), StandardOpenOption.TRUNCATE_EXISTING);
            }
        }

        private static String getTextReportPath(List<String> arguments) {
            for (int index = 0; index + 1 < arguments.size(); index++) {
                if ("--report".equals(arguments.get(index))) {
                    String report = arguments.get(index + 1);
                    if (report.startsWith("txt:")) {
                        return report.substring("txt:".length());
                    }
                }
            }
            return null;
        }
    }

}
