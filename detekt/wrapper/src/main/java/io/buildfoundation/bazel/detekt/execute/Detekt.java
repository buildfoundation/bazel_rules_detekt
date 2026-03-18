package io.buildfoundation.bazel.detekt.execute;

import dev.detekt.cli.CliRunner;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintStream;
import java.util.Arrays;
import java.util.List;

public interface Detekt {

    void execute(String[] args, PrintStream output, PrintStream error);

    final class Impl implements Detekt {

        private final CliRunner runner = new CliRunner();

        @Override
        public void execute(String[] args, PrintStream output, PrintStream error) {
            List<String> argsList = Arrays.asList(args);
            if (argsList.contains("--create-baseline")) {
                String baseline = argsList.get(argsList.indexOf("--baseline") + 1);
                File baselineFile = new File(baseline);
                // Bazel pre-creates declared output files as empty 0-byte files.
                // Detekt tries to parse the existing baseline before creating a new one,
                // which fails on an empty file. Delete it so Detekt starts fresh.
                if (baselineFile.exists() && baselineFile.length() == 0) {
                    baselineFile.delete();
                }
            }

            RuntimeException resultError = runner.run(args, output, error).getError();

            if (resultError != null) {
                throw resultError;
            } else {
                if (argsList.contains("--create-baseline")) {
                    String baseline = argsList.get(argsList.indexOf("--baseline") + 1);
                    File baselineFile = new File(baseline);
                    if (!baselineFile.exists()) {
                        try {
                            createEmptyBaseline(baselineFile);
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }
                    }
                }
            }
        }

        String emptyBaseLineContent = "<?xml version=\"1.0\" ?>\n" +
                "<SmellBaseline>\n" +
                "  <ManuallySuppressedIssues></ManuallySuppressedIssues>\n" +
                "  <CurrentIssues>\n" +
                "  </CurrentIssues>\n" +
                "</SmellBaseline>\n";

        private void createEmptyBaseline(File baselineFile) throws IOException {
            baselineFile.createNewFile();
            try (FileWriter writer = new FileWriter(baselineFile)) {
                writer.write(emptyBaseLineContent);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
