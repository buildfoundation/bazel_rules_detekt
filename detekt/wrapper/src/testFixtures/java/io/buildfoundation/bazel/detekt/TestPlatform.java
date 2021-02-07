package io.buildfoundation.bazel.detekt;

class TestPlatform implements Platform {

    int exitCode = Integer.MIN_VALUE;

    @Override
    public void exit(int code) {
        this.exitCode = code;
    }
}
