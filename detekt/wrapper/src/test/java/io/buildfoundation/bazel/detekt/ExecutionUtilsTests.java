package io.buildfoundation.bazel.detekt;

import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.*;

public class ExecutionUtilsTests {

    @Test
    public void testShouldRunAsTestTargetWhenTrue() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--run-as-test-target"));
        assertTrue(ExecutionUtils.shouldRunAsTestTarget(args));
    }

    @Test
    public void testShouldRunAsTestTargetWhenFalse() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one"));
        assertFalse(ExecutionUtils.shouldRunAsTestTarget(args));
    }

    @Test
    public void testIsParamsFileWhenTrue() {
        assertTrue(ExecutionUtils.isParamsFile("@bazel-out/file.params"));
    }

    @Test
    public void testIsParamsFileWhenFalse() {
        assertFalse(ExecutionUtils.isParamsFile("value"));
    }

    @Test
    public void testGetArgumentWhenArgumentExists() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--execution-result", "/some/file/path"));
        assertEquals(ExecutionUtils.getArgument(args, "--execution-result"), "/some/file/path");
    }

    @Test
    public void testGetArgumentWhenArgumentDoesNotExist() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one"));
        assertNull(ExecutionUtils.getArgument(args, "--execution-result"));
    }

    @Test
    public void testSanitizeDetektArgumentsWhenPassedInAtBeginningOfArgs() {
        List<String> args = new ArrayList<>(Arrays.asList("--execution-result", "/some/file/path", "--run-as-test-target", "--input", "one"));
        List<String> expectedArgs = new ArrayList<>(Arrays.asList("--input", "one"));
        assertEquals(ExecutionUtils.sanitizeDetektArguments(args), expectedArgs);
    }

    @Test
    public void testSanitizeDetektArgumentsWhenPassedInAtMiddleOfArgs() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--execution-result", "/some/file/path", "--run-as-test-target", "--another", "value"));
        List<String> expectedArgs = new ArrayList<>(Arrays.asList("--input", "one", "--execution-result", "/some/file/path"));
        assertEquals(ExecutionUtils.sanitizeDetektArguments(args), expectedArgs);
    }

    @Test
    public void testSanitizeDetektArgumentsWhenPassedInAtEndOfArgs() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one", "--execution-result", "/some/file/path", "--run-as-test-target"));
        List<String> expectedArgs = new ArrayList<>(Arrays.asList("--input", "one"));
        assertEquals(ExecutionUtils.sanitizeDetektArguments(args), expectedArgs);
    }

    @Test
    public void testSanitizeDetektArgumentsWhenNoneExist() {
        List<String> args = new ArrayList<>(Arrays.asList("--input", "one"));
        List<String> expectedArgs = new ArrayList<>(Arrays.asList("--input", "one"));
        assertEquals(ExecutionUtils.sanitizeDetektArguments(args), expectedArgs);
    }
}
