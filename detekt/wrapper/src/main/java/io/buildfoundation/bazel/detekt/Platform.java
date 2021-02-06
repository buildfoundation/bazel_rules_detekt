package io.buildfoundation.bazel.detekt;

public interface Platform {

    void exit(int code);

    final class Impl implements Platform {

        @Override
        public void exit(int code) {
            System.exit(code);
        }
    }
}
