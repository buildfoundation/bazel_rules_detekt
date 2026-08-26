package io.buildfoundation.bazel.detekt.execute;

import org.junit.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
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
    public void translatesDetekt2Arguments() {
        Detekt.Impl.Translation translation = Detekt.Impl.translate(new String[]{
                "--input", "one,two",
                "--config", "config-one,config-two",
                "--classpath", "first,second",
                "--report", "txt:report.txt",
                "--report", "xml:report.xml",
        }, true);

        assertArrayEquals(new String[]{
                "--input", "one" + java.io.File.pathSeparator + "two",
                "--config", "config-one" + java.io.File.pathSeparator + "config-two",
                "--classpath", "first" + java.io.File.pathSeparator + "second",
                "--report", "checkstyle:report.xml",
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
}
