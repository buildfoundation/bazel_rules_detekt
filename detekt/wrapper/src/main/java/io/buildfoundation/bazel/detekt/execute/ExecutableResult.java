package io.buildfoundation.bazel.detekt.execute;

public interface ExecutableResult {

    String output();

    int statusCode();

    final class Success implements ExecutableResult {

        final String output;

        public Success() {
            this("");
        }

        public Success(String output) {
            this.output = output;
        }

        @Override
        public String output() {
            return output;
        }

        @Override
        public int statusCode() {
            return 0;
        }
    }

    final class Failure implements ExecutableResult {

        final String output;

        public Failure(String output) {
            this.output = output;
        }

        @Override
        public String output() {
            return output;
        }

        @Override
        public int statusCode() {
            return 1;
        }
    }
}
