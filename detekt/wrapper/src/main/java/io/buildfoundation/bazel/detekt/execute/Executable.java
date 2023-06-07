package io.buildfoundation.bazel.detekt.execute;

import io.buildfoundation.bazel.detekt.ExecutionUtils;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
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
                detektWrapperArguments = ExecutionUtils.readArgumentsFromFile(args[0]);
            }

            ExecutableResult result;
            String executionResultOutputPath = ExecutionUtils.getRequiredArgumentValue(detektWrapperArguments, "--execution-result");

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

                    result = new ExecutableResult.Failure(output + error);
                } catch (UnsupportedEncodingException unsupportedEncodingException) {
                    result = new ExecutableResult.Failure("Unknown Detekt error, please report this issue");
                }
            } finally {
                outputPrinter.close();
                errorPrinter.close();
            }

            ExecutionUtils.writeExecutionResultToFile(result.statusCode(), executionResultOutputPath);

            if (ExecutionUtils.shouldRunAsTestTarget(detektWrapperArguments)) {
                result = new ExecutableResult.Success();
            }
            return result;
        }
    }

}
