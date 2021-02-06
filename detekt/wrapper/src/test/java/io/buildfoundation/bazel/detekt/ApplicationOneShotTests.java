package io.buildfoundation.bazel.detekt;

import io.buildfoundation.bazel.detekt.execute.Executable;
import io.buildfoundation.bazel.detekt.execute.ExecutableResult;
import io.buildfoundation.bazel.detekt.execute.TestExecutable;
import io.buildfoundation.bazel.detekt.stream.Streams;
import io.buildfoundation.bazel.detekt.stream.TestStreams;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class ApplicationOneShotTests {

    @Test
    public void successExitOnExecutionSuccess() {
        check(new ExecutableResult.Success());
    }

    @Test
    public void failureExitOnExecutionFailure() {
        check(new ExecutableResult.Failure("fake error"));
    }

    private void check(ExecutableResult executableResult) {
        Executable executable = new TestExecutable(executableResult);
        Streams streams = new TestStreams();
        TestPlatform platform = new TestPlatform();

        new Application.OneShot(executable, streams, platform).run(new String[0]);

        assertEquals(executableResult.statusCode(), platform.exitCode);
    }
}
