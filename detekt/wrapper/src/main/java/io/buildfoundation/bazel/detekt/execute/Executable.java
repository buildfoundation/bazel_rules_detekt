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

    ExecutableResult execute(String[] args);

    final class DetektImpl implements Executable {

        private final Detekt detekt;
        private final String charset;

        public DetektImpl(Detekt detekt) {
            this.detekt = detekt;
            this.charset = Charset.defaultCharset().name();
        }

        @Override
        public ExecutableResult execute(String[] args) {
            ByteArrayOutputStream outputBuffer = new ByteArrayOutputStream();
            PrintStream outputPrinter = new PrintStream(new BufferedOutputStream(outputBuffer));

            ByteArrayOutputStream errorBuffer = new ByteArrayOutputStream();
            PrintStream errorPrinter = new PrintStream(new BufferedOutputStream(errorBuffer));

            List<String> detektWrapperArguments = Arrays.asList(args);
            if (args.length == 1 && ExecutionUtils.isParamsFile(args[0])) {
                // drop leading `@` from params-file
                Path paramsFilePath = Paths.get(args[0].substring(1));
                detektWrapperArguments = ExecutionUtils.readArgumentsFromFile(paramsFilePath);
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
                    String output = outputBuffer.toString(charset);
                    String error = errorBuffer.toString(charset);
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
