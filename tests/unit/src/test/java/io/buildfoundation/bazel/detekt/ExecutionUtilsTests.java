package io.buildfoundation.bazel.detekt;

import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

public class ExecutionUtilsTests {

    @Test
    public void shouldRunAsTestTargetWhenTrue() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--run-as-test-target"));
        assertTrue(ExecutionUtils.shouldRunAsTestTarget(args));
    }

    @Test
    public void shouldRunAsTestTargetWhenFalse() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one"));
        assertFalse(ExecutionUtils.shouldRunAsTestTarget(args));
    }

    @Test
    public void isParamsFileWhenTrue() {
        assertTrue(ExecutionUtils.isParamsFile("@bazel-out/file.params"));
    }

    @Test
    public void isParamsFileWhenFalse() {
        assertFalse(ExecutionUtils.isParamsFile("value"));
    }

    @Test
    public void getArgumentWhenArgumentExists() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--execution-result", "/some/file/path"));
        assertEquals(ExecutionUtils.getValueForArgumentName(args, "--execution-result"), "/some/file/path");
    }

    @Test
    public void getArgumentWhenArgumentDoesNotExist() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one"));
        assertNull(ExecutionUtils.getValueForArgumentName(args, "--execution-result"));
    }

    @Test
    public void sanitizeDetektArgumentsWhenPassedInAtBeginningOfArgs() {
        List<String> args = new ArrayList<>(Arrays.asList("--execution-result", "/some/file/path", "--run-as-test-target", "--input", "one"));
        List<String> expectedArgs = new ArrayList<>(Arrays.asList("--input", "one"));
        assertEquals(ExecutionUtils.sanitizeDetektArguments(args), expectedArgs);
    }

    @Test
    public void sanitizeDetektArgumentsWhenPassedInAtMiddleOfArgs() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--execution-result", "/some/file/path", "--run-as-test-target", "--another", "value"));
        List<String> expectedArgs = new ArrayList<>(Arrays.asList("--input", "one", "--another", "value"));
        assertEquals(ExecutionUtils.sanitizeDetektArguments(args), expectedArgs);
    }

    @Test
    public void sanitizeDetektArgumentsWhenPassedInAtEndOfArgs() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--execution-result", "/some/file/path", "--run-as-test-target"));
        List<String> expectedArgs = new ArrayList<>(Arrays.asList("--input", "one"));
        assertEquals(ExecutionUtils.sanitizeDetektArguments(args), expectedArgs);
    }

    @Test
    public void sanitizeDetektArgumentsWhenNoneExist() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one"));
        List<String> expectedArgs = new ArrayList<>(Arrays.asList("--input", "one"));
        assertEquals(ExecutionUtils.sanitizeDetektArguments(args), expectedArgs);
    }

    @Test
    public void resolveSandboxPathsRewritesRelativePathsOnly() {
        java.nio.file.Path sandbox = java.nio.file.Paths.get("/sb/r3");
        String sep = java.io.File.pathSeparator;
        List<String> args = Arrays.asList(
                "--input", "a/One.kt,/abs/Two.kt",
                "--config", "cfg.yml",
                "--config-resource", "res/detekt.yml",
                "--plugins", "p1.jar,p2.jar",
                "--classpath", "/jdk/rt.jar" + sep + "bazel-out/lib.jar",
                "--baseline", "baseline.xml",
                "--report", "sarif:bazel-out/r.sarif",
                "--report", "md:/abs/r.md",
                "--execution-result", "bazel-out/exit.txt",
                "--fail-on-severity", "Info",
                "--run-as-test-target");

        assertEquals(Arrays.asList(
                "--input", "/sb/r3/a/One.kt,/abs/Two.kt",
                "--config", "/sb/r3/cfg.yml",
                "--config-resource", "res/detekt.yml",
                "--plugins", "/sb/r3/p1.jar,/sb/r3/p2.jar",
                "--classpath", "/jdk/rt.jar" + sep + "/sb/r3/bazel-out/lib.jar",
                "--baseline", "/sb/r3/baseline.xml",
                "--report", "sarif:/sb/r3/bazel-out/r.sarif",
                "--report", "md:/abs/r.md",
                "--execution-result", "/sb/r3/bazel-out/exit.txt",
                "--fail-on-severity", "Info",
                "--run-as-test-target",
                "--base-path", "/sb/r3"), ExecutionUtils.resolveSandboxPaths(args, sandbox));
    }

    @Test
    public void resolveSandboxPathsKeepsExplicitBasePath() {
        List<String> resolved = ExecutionUtils.resolveSandboxPaths(
                Arrays.asList("--base-path", ".", "--input", "pkg/../One.kt"), java.nio.file.Paths.get("/sb/r1"));

        assertEquals(Arrays.asList("--base-path", "/sb/r1", "--input", "/sb/r1/One.kt"), resolved);
    }

    @Test
    public void relativizePathsStripsOnlyTheBasePathPrefix() {
        java.nio.file.Path base = java.nio.file.Paths.get("/sb/r1");

        assertEquals("src/A.kt:1:1 /sb/r10/B.kt", ExecutionUtils.relativizePaths("/sb/r1/src/A.kt:1:1 /sb/r10/B.kt", base));
        assertEquals("/sb/r1/A.kt", ExecutionUtils.relativizePaths("/sb/r1/A.kt", null));
    }
}
