package io.buildfoundation.bazel.detekt.stream;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;

public interface Streams {

    InputStream input();
    PrintStream output();
    PrintStream error();

    final class Impl implements Streams {

        private final InputStream input;
        private final PrintStream output;
        private final PrintStream error;

        public Impl() {
            this.input = System.in;
            this.output = System.out;
            this.error = System.err;

            // Prevent accidental writes since Bazel treats system streams as worker communication channel.
            System.setOut(new PrintStream(new DevNullOutputStream()));
            System.setErr(new PrintStream(new DevNullOutputStream()));
        }

        @Override
        public InputStream input() {
            return input;
        }

        @Override
        public PrintStream output() {
            return output;
        }

        @Override
        public PrintStream error() {
            return error;
        }

        private static class DevNullOutputStream extends OutputStream {
            @Override
            public void write(int writeByte) {
            }
        }
    }

}
