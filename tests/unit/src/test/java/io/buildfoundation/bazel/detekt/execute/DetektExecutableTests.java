package io.buildfoundation.bazel.detekt.execute;

import org.junit.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

public class DetektExecutableTests {
    @Test
    public void successResultOnDetektExecutionSuccessAsBuildTarget() throws IOException {
        check(TestDetekt.ExecuteResult.Success, ExecutableResult.Success.class, false, 0);
    }

    @Test
    public void failureResultOnDetektExecutionFailureAsBuildTarget() throws IOException {
        check(TestDetekt.ExecuteResult.Failure, ExecutableResult.Failure.class, false, 1);
    }

    @Test
    public void successResultOnDetektExecutionSuccessAsTestTarget() throws IOException {
        check(TestDetekt.ExecuteResult.Success, ExecutableResult.Success.class, true, 0);
    }

    @Test
    public void successResultOnDetektExecutionFailureAsTestTarget() throws IOException {
        check(TestDetekt.ExecuteResult.Failure, ExecutableResult.Success.class, true, 1);
    }

    @Test
    public void writesV2TextReportForSuccessfulAnalysis() throws IOException {
        Path report = reportPath();
        Path executionResult = Files.createTempFile("detekt-execution-result", ".txt");

        ExecutableResult result = runV2(new String[]{
                "--input", sourceFile().toString(),
                "--all-rules",
                "--fail-on-severity", "Never",
                "--report", "txt:" + report,
                "--execution-result", executionResult.toString(),
        });

        assertEquals(ExecutableResult.Success.class, result.getClass());
        assertEquals("0", new String(Files.readAllBytes(executionResult)));
        assertTrue(new String(Files.readAllBytes(report)).contains("UndocumentedPublicClass"));
    }

    @Test
    public void writesV2TextReportForFindingsFailure() throws IOException {
        Path report = reportPath();
        Path executionResult = Files.createTempFile("detekt-execution-result", ".txt");

        ExecutableResult result = runV2(new String[]{
                "--input", sourceFile().toString(),
                "--all-rules",
                "--report", "txt:" + report,
                "--execution-result", executionResult.toString(),
        });

        assertEquals(ExecutableResult.Failure.class, result.getClass());
        assertEquals("1", new String(Files.readAllBytes(executionResult)));
        assertTrue(new String(Files.readAllBytes(report)).contains("UndocumentedPublicClass"));
    }

    @Test
    public void preservesV2TextReportForFindingsAsTestTarget() throws IOException {
        Path report = reportPath();
        Path executionResult = Files.createTempFile("detekt-execution-result", ".txt");

        ExecutableResult result = runV2(new String[]{
                "--input", sourceFile().toString(),
                "--all-rules",
                "--report", "txt:" + report,
                "--execution-result", executionResult.toString(),
                "--run-as-test-target",
        });

        assertEquals(ExecutableResult.Success.class, result.getClass());
        assertEquals("1", new String(Files.readAllBytes(executionResult)));
        assertTrue(new String(Files.readAllBytes(report)).contains("UndocumentedPublicClass"));
    }

    @Test
    public void writesV2ConfigErrorToTextReportAsTestTarget() throws IOException {
        Path report = reportPath();
        Path executionResult = Files.createTempFile("detekt-execution-result", ".txt");
        Path config = Files.createTempFile("detekt-missing-config", ".yml");
        Files.delete(config);

        ExecutableResult result = runV2(new String[]{
                "--input", sourceFile().toString(),
                "--config", config.toString(),
                "--report", "txt:" + report,
                "--execution-result", executionResult.toString(),
                "--run-as-test-target",
        });

        assertEquals(ExecutableResult.Success.class, result.getClass());
        assertEquals("1", new String(Files.readAllBytes(executionResult)));
        assertTrue(new String(Files.readAllBytes(report)).contains("does not exist"));
    }

    @Test
    public void writesV2CliErrorToTextReportAsTestTarget() throws IOException {
        Path report = reportPath();
        Path executionResult = Files.createTempFile("detekt-execution-result", ".txt");

        ExecutableResult result = runV2(new String[]{
                "--input", sourceFile().toString(),
                "--unknown-option",
                "--report", "txt:" + report,
                "--execution-result", executionResult.toString(),
                "--run-as-test-target",
        });

        assertEquals(ExecutableResult.Success.class, result.getClass());
        assertEquals("1", new String(Files.readAllBytes(executionResult)));
        assertTrue(new String(Files.readAllBytes(report)).contains("unknown-option"));
    }

    @Test
    public void writesV2ValidationErrorsToTextReportAsTestTarget() throws IOException {
        checkV2ValidationError("--jvm-target");
        checkV2ValidationError("--language-version");
    }

    @Test
    public void writesV2TranslationErrorToTextReportAsTestTarget() throws IOException {
        Path report = reportPath();
        Path executionResult = Files.createTempFile("detekt-execution-result", ".txt");

        ExecutableResult result = runV2(new String[]{
                "--input", sourceFile().toString(),
                "--max-issues", "1",
                "--report", "txt:" + report,
                "--execution-result", executionResult.toString(),
                "--run-as-test-target",
        });

        assertEquals(ExecutableResult.Success.class, result.getClass());
        assertEquals("1", new String(Files.readAllBytes(executionResult)));
        assertTrue(new String(Files.readAllBytes(report)).contains("max_issues"));
    }

    @Test
    public void preservesExistingTextReportAndAppendsFailureDiagnostics() throws IOException {
        Path report = Files.createTempFile("detekt-report", ".txt");
        Files.write(report, Arrays.asList("native report"));
        Path executionResult = Files.createTempFile("detekt-execution-result", ".txt");

        Detekt detekt = (args, output, error) -> {
            output.print("native report\n");
            error.print("stderr\n");
            throw new RuntimeException("failure");
        };
        ExecutableResult result = new Executable.DetektImpl(detekt).execute(new String[]{
                "--input", "one",
                "--report", "txt:" + report,
                "--execution-result", executionResult.toString(),
        });

        assertEquals(ExecutableResult.Failure.class, result.getClass());
        String reportContent = new String(Files.readAllBytes(report));
        assertTrue(reportContent.startsWith("native report\n"));
        assertTrue(reportContent.contains("stderr\n"));
        assertTrue(reportContent.contains("RuntimeException: failure"));
        assertFalse(reportContent.contains("native report\nnative report\n"));
    }

    @Test
    public void keepsFailureStatusWhenTextReportCannotBeWritten() throws IOException {
        Path report = Files.createTempDirectory("detekt-report");
        Path executionResult = Files.createTempFile("detekt-execution-result", ".txt");

        Detekt detekt = (args, output, error) -> {
            throw new RuntimeException("original failure");
        };
        ExecutableResult result = new Executable.DetektImpl(detekt).execute(new String[]{
                "--input", "one",
                "--report", "txt:" + report,
                "--execution-result", executionResult.toString(),
                "--run-as-test-target",
        });

        assertEquals(ExecutableResult.Failure.class, result.getClass());
        assertTrue(result.output().contains("RuntimeException: original failure"));
        assertTrue(result.output().contains("Unable to write Detekt text report"));
        assertEquals("1", new String(Files.readAllBytes(executionResult)));
    }

    @Test
    public void resolvesV2RequestAgainstMultiplexSandboxDir() throws IOException {
        // Mirror a Bazel/actiond multiplex sandbox: inputs are symlinks into another tree, the
        // params file and every path in it are relative to sandbox_dir, not the worker's cwd.
        Path tree = Files.createTempDirectory("detekt-tree");
        Path realSource = tree.resolve("Undocumented.kt");
        Files.write(realSource, Arrays.asList("class Undocumented {", "    fun method(): Int = 1", "}"));
        Path sandbox = Files.createTempDirectory("detekt-sandbox").toRealPath();
        Files.createDirectories(sandbox.resolve("pkg"));
        Files.createDirectories(sandbox.resolve("bazel-out"));
        Files.createSymbolicLink(sandbox.resolve("pkg/Undocumented.kt"), realSource);
        Files.write(sandbox.resolve("bazel-out/params"), Arrays.asList(
                "--input", "pkg/Undocumented.kt",
                "--all-rules",
                "--report", "txt:bazel-out/report.txt",
                "--report", "sarif:bazel-out/report.sarif",
                "--execution-result", "bazel-out/exit.txt"));

        ExecutableResult result = new Executable.DetektImpl(new Detekt.Impl())
                .execute(new String[]{"@bazel-out/params"}, sandbox);

        assertEquals(ExecutableResult.Failure.class, result.getClass());
        assertEquals("1", new String(Files.readAllBytes(sandbox.resolve("bazel-out/exit.txt"))));
        for (String report : Arrays.asList("report.txt", "report.sarif")) {
            String content = new String(Files.readAllBytes(sandbox.resolve("bazel-out").resolve(report)));
            assertTrue(report + ": " + content, content.contains("UndocumentedPublicClass"));
            assertTrue(report + ": " + content, content.contains("pkg/Undocumented.kt"));
            assertFalse(report + ": " + content, content.contains(sandbox.toString()));
            assertFalse(report + ": " + content, content.contains(tree.toString()));
        }
        assertFalse(result.output(), result.output().contains(sandbox.toString()));
    }

    @Test
    public void resolvesExplicitBasePathAgainstMultiplexSandboxDir() throws IOException {
        // base_path = "." on the rule emits `--base-path .`, which must mean the sandbox root.
        Path sandbox = Files.createTempDirectory("detekt-sandbox").toRealPath();
        Files.createDirectories(sandbox.resolve("pkg"));
        Files.createDirectories(sandbox.resolve("bazel-out"));
        Files.write(sandbox.resolve("pkg/Undocumented.kt"), Arrays.asList("class Undocumented {", "    fun method(): Int = 1", "}"));

        ExecutableResult result = new Executable.DetektImpl(new Detekt.Impl()).execute(new String[]{
                "--input", "pkg/Undocumented.kt",
                "--all-rules",
                "--base-path", ".",
                "--report", "sarif:bazel-out/report.sarif",
                "--report", "txt:bazel-out/report.txt",
                "--execution-result", "bazel-out/exit.txt",
                "--run-as-test-target",
        }, sandbox);

        assertEquals(ExecutableResult.Success.class, result.getClass());
        assertEquals("1", new String(Files.readAllBytes(sandbox.resolve("bazel-out/exit.txt"))));
        for (String report : Arrays.asList("report.txt", "report.sarif")) {
            String content = new String(Files.readAllBytes(sandbox.resolve("bazel-out").resolve(report)));
            assertTrue(report + ": " + content, content.contains("pkg/Undocumented.kt"));
            assertFalse(report + ": " + content, content.contains(sandbox.toString()));
        }
    }

    @Test
    public void relativizesTextReportAndOutputOnlyForSandboxedRequests() throws IOException {
        Path sandbox = Files.createTempDirectory("detekt-sandbox").toRealPath();
        String finding = sandbox.resolve("pkg/A.kt") + ":1:1 Finding";
        Detekt detekt = (args, output, error) -> {
            List<String> arguments = Arrays.asList(args);
            String report = arguments.get(arguments.indexOf("--report") + 1).substring("txt:".length());
            try {
                Files.write(Paths.get(report), Arrays.asList(finding));
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            output.print(finding + "\n");
            throw new RuntimeException("findings");
        };

        Files.createDirectories(sandbox.resolve("out"));
        ExecutableResult sandboxed = new Executable.DetektImpl(detekt).execute(new String[]{
                "--input", "pkg/A.kt",
                "--report", "txt:out/report.txt",
                "--execution-result", "out/exit.txt",
        }, sandbox);

        assertEquals(ExecutableResult.Failure.class, sandboxed.getClass());
        String sandboxedReport = new String(Files.readAllBytes(sandbox.resolve("out/report.txt")));
        assertTrue(sandboxedReport, sandboxedReport.startsWith("pkg/A.kt:1:1 Finding\n"));
        assertFalse(sandboxedReport, sandboxedReport.contains(sandbox.toString()));
        assertTrue(sandboxed.output(), sandboxed.output().contains("pkg/A.kt:1:1 Finding"));
        assertFalse(sandboxed.output(), sandboxed.output().contains(sandbox.toString()));

        Path report = Files.createTempDirectory("detekt-report").resolve("report.txt");
        ExecutableResult unsandboxed = new Executable.DetektImpl(detekt).execute(new String[]{
                "--input", "pkg/A.kt",
                "--report", "txt:" + report,
                "--execution-result", Files.createTempFile("detekt-execution-result", ".txt").toString(),
        });

        assertTrue(new String(Files.readAllBytes(report)).contains(finding));
        assertTrue(unsandboxed.output(), unsandboxed.output().contains(finding));
    }

    @Test
    public void translatesDetekt2Arguments() {
        Detekt.Impl.Translation translation = Detekt.Impl.translate(new String[]{
                "--input", "one,two",
                "--config", "config-one,config-two",
                "--classpath", "first,second",
                "--report", "txt:report.txt",
                "--report", "xml:report.xml",
                "--report", "md:report.md",
        }, true);

        assertArrayEquals(new String[]{
                "--input", "one" + java.io.File.pathSeparator + "two",
                "--config", "config-one" + java.io.File.pathSeparator + "config-two",
                "--classpath", "first" + java.io.File.pathSeparator + "second",
                "--report", "checkstyle:report.xml",
                "--report", "markdown:report.md",
                "--analysis-mode", "full",
        }, translation.arguments);
        assertEquals("report.txt", translation.textReport);
    }

    @Test
    public void preservesDetekt1Arguments() {
        Detekt.Impl.Translation translation = Detekt.Impl.translate(new String[]{
                "--input", "one,two",
                "--report", "xml:report.xml",
                "--report", "txt:report.txt",
                "--max-issues", "1",
        }, false);

        assertArrayEquals(new String[]{
                "--input", "one,two",
                "--report", "xml:report.xml",
                "--report", "txt:report.txt",
                "--max-issues", "1",
        }, translation.arguments);
        assertNull(translation.textReport);
    }

    @Test
    public void rejectsDetekt1FailureFlagForDetekt2() {
        try {
            Detekt.Impl.translate(new String[]{"--max-issues", "1"}, true);
        } catch (IllegalArgumentException error) {
            assertTrue(error.getMessage().contains("fail_on_severity"));
            return;
        }
        throw new AssertionError("Expected max_issues to be rejected by Detekt 2");
    }

    @Test
    public void rejectsDetekt2FailureFlagForDetekt1() {
        try {
            Detekt.Impl.translate(new String[]{"--fail-on-severity", "Error"}, false);
        } catch (IllegalArgumentException error) {
            assertTrue(error.getMessage().contains("max_issues"));
            return;
        }
        throw new AssertionError("Expected fail_on_severity to be rejected by Detekt 1");
    }

    private <T extends ExecutableResult> void check(TestDetekt.ExecuteResult detektResult, Class<T> result, boolean runAsTestTarget, int exitCode) throws IOException {
        Path tempFile = Files.createTempFile("execution-result", ".txt");
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--execution-result", tempFile.toFile().getAbsolutePath()));
        if (runAsTestTarget) {
            args.add("--run-as-test-target");
        }
        Executable executable = new Executable.DetektImpl(new TestDetekt(detektResult));
        ExecutableResult executableResult = executable.execute(args.toArray(new String[0]));
        assertEquals(result, executableResult.getClass());
        assertEquals(Integer.toString(exitCode), new String(Files.readAllBytes(tempFile)));
    }

    private ExecutableResult runV2(String[] args) {
        return new Executable.DetektImpl(new Detekt.Impl()).execute(args);
    }

    private Path reportPath() throws IOException {
        return Files.createTempDirectory("detekt-report").resolve("report.txt");
    }

    private void checkV2ValidationError(String argument) throws IOException {
        Path report = reportPath();
        Path executionResult = Files.createTempFile("detekt-execution-result", ".txt");

        ExecutableResult result = runV2(new String[]{
                "--input", sourceFile().toString(),
                argument, "not-a-version",
                "--report", "txt:" + report,
                "--execution-result", executionResult.toString(),
                "--run-as-test-target",
        });

        assertEquals(ExecutableResult.Success.class, result.getClass());
        assertEquals("1", new String(Files.readAllBytes(executionResult)));
        assertTrue(new String(Files.readAllBytes(report)).contains(argument));
    }

    private Path sourceFile() throws IOException {
        Path source = Files.createTempFile("detekt-source", ".kt");
        Files.write(source, Arrays.asList("class Undocumented {", "    fun method(): Int = 1", "}"));
        return source;
    }
}
