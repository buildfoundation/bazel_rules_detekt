package io.buildfoundation.bazel.detekt.execute;

public class TestExecutable implements Executable {

    private final ExecutableResult executeResult;

    public TestExecutable(ExecutableResult executeResult) {
        this.executeResult = executeResult;
    }

    @Override
    public ExecutableResult execute(String[] args) {
        return executeResult;
    }
}
