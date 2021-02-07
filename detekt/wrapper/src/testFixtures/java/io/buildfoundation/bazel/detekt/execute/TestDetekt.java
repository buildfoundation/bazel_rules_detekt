package io.buildfoundation.bazel.detekt.execute;

import java.io.PrintStream;

class TestDetekt implements Detekt {

    enum ExecuteResult {
        Success, Failure
    }

    private final ExecuteResult executeResult;

    TestDetekt(ExecuteResult executeResult) {
        this.executeResult = executeResult;
    }

    @Override
    public void execute(String[] args, PrintStream output, PrintStream error) {
        if (executeResult == ExecuteResult.Failure) {
            throw new RuntimeException();
        }
    }
}
