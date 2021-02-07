package io.buildfoundation.bazel.detekt.execute;

import io.gitlab.arturbosch.detekt.cli.CliRunner;

import java.io.PrintStream;

public interface Detekt {

    void execute(String[] args, PrintStream output, PrintStream error);

    final class Impl implements Detekt {

        private final CliRunner runner = new CliRunner();

        @Override
        public void execute(String[] args, PrintStream output, PrintStream error) {
            RuntimeException resultError = runner.run(args, output, error).getError();

            if (resultError != null) {
                throw resultError;
            }
        }
    }
}
