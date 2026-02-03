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
}
