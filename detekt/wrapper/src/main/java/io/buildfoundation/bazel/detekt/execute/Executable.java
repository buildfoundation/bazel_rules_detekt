package io.buildfoundation.bazel.detekt.execute;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;

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

            try {
                detekt.execute(args, outputPrinter, errorPrinter);

                return new ExecutableResult.Success();
            } catch (Exception e) {
                outputPrinter.flush();

                e.printStackTrace(errorPrinter);
                errorPrinter.flush();

                try {
                    String output = outputBuffer.toString(charset);
                    String error = errorBuffer.toString(charset);

                    return new ExecutableResult.Failure(output + error);
                } catch (UnsupportedEncodingException unsupportedEncodingException) {
                    return new ExecutableResult.Failure("Unknown Detekt error, please report this issue");
                }
            } finally {
                outputPrinter.close();
                errorPrinter.close();
            }
        }
    }

}
