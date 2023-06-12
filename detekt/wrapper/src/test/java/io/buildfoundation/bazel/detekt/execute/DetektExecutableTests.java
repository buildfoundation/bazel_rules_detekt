package io.buildfoundation.bazel.detekt.execute;

import io.buildfoundation.bazel.detekt.ExecutionUtils;
import io.buildfoundation.bazel.detekt.WriterFactory;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import java.io.BufferedWriter;

import static org.junit.Assert.assertEquals;

public class DetektExecutableTests {
    @Test
    public void successResultOnDetektExecutionSuccessAsBuildTarget() throws IOException {
        check(TestDetekt.ExecuteResult.Success, ExecutableResult.Success.class, false);
    }

    @Test
    public void failureResultOnDetektExecutionFailureAsBuildTarget() throws IOException {
        check(TestDetekt.ExecuteResult.Failure, ExecutableResult.Failure.class, false);
    }

    @Test
    public void successResultOnDetektExecutionSuccessAsTestTarget() throws IOException {
        check(TestDetekt.ExecuteResult.Success, ExecutableResult.Success.class, true);
    }

    @Test
    public void failureResultOnDetektExecutionFailureAsTestTarget() throws IOException {
        check(TestDetekt.ExecuteResult.Success, ExecutableResult.Success.class, true);
    }

    private <T extends ExecutableResult> void check(TestDetekt.ExecuteResult detektResult, Class<T> result, boolean runAsTestTarget) throws IOException {
        Path tempFile = Files.createTempFile("execution-result", "txt");
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--execution-result", tempFile.toFile().getAbsolutePath()));
        if (runAsTestTarget) {
            args.add("--run-as-test-target");
        }
        Executable executable = new Executable.DetektImpl(new TestDetekt(detektResult));
        ExecutableResult executableResult = executable.execute(args.toArray(new String[0]));
        assertEquals(result, executableResult.getClass());
    }
}
