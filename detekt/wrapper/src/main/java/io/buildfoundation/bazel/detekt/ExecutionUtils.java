package io.buildfoundation.bazel.detekt;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ExecutionUtils {
    /**
     * Returns true if run-as-test-target flag is included in arguments
     */
    public static boolean shouldRunAsTestTarget(List<String> arguments) {
        return arguments.contains("--run-as-test-target");
    }

    /**
     * Retrieves the output path for the test result from the input arguments.
     */
    public static String getRequiredArgumentValue(List<String> arguments, String argumentName) {
        String outputPath = getValueForArgumentName(arguments, argumentName);
        if (outputPath == null) {
            throw new IllegalStateException("Value not found for argument " + argumentName);
        }
        return outputPath;
    }

    /**
     * Writes the execution result to a file
     */
    public static void writeExecutionResultToFile(Integer exitCode, Path executionResultOutputPath) {
        try {
            Files.write(executionResultOutputPath, exitCode.toString().getBytes(), StandardOpenOption.CREATE);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static boolean isParamsFile(String argument) {
        return argument.startsWith("@");
    }

    /**
     * Read-in arguments from a params-file
     */
    public static List<String> readArgumentsFromFile(Path filePath) {
        try {
            return Files.readAllLines(filePath);
        } catch (IOException e) {
            throw new IllegalStateException("An error occurred while reading the params file: " + e.getMessage());
        }
    }

    /**
     * Retrieves the value associated with the given argument name from the input arguments list.
     *
     * @param inputArgs List of input arguments.
     * @param argName The name of the argument whose value needs to be fetched.
     * @return The value associated with the given argument name or null if the argument is not found.
     */
    public static String getValueForArgumentName(List<String> inputArgs, String argName) {
        try {
            // Get the index of the argument and return the value at the next index.
            int indexOfArgument = inputArgs.indexOf(argName);
            if (indexOfArgument == -1) {
                return null;
            }
            return inputArgs.get(indexOfArgument + 1);
        } catch (IndexOutOfBoundsException ignored) {
            // Return null if the argument is not found or there's no value after it.
            return null;
        }
    }

    /**
     * Sanitizes the Detekt arguments by excluding arguments used solely by the detekt-wrapper
     */
    public static List<String> sanitizeDetektArguments(List<String> inputArgs) {
        Set<String> excludedArgs = new HashSet<>(Arrays.asList("--execution-result", "--run-as-test-target"));
        return filterOutArgValuePairs(inputArgs, excludedArgs);
    }

    private static final Set<String> PATH_LIST_ARGUMENTS = new HashSet<>(Arrays.asList(
            "--input", "--config", "--plugins", "--classpath"));
    private static final Set<String> PATH_ARGUMENTS = new HashSet<>(Arrays.asList(
            "--baseline", "--execution-result", "--base-path"));
    private static final String BASE_PATH_ARGUMENT = "--base-path";

    /**
     * Resolves every relative input and output path against a multiplex sandbox directory.
     *
     * <p>A multiplex worker serves concurrent requests from one process, so it cannot change its
     * working directory per request; each request names its input tree in
     * {@code WorkRequest.sandbox_dir} instead. Paths are made absolute here, and {@code --base-path}
     * defaults to the sandbox so formatted reports keep execroot-relative paths.</p>
     */
    public static List<String> resolveSandboxPaths(List<String> arguments, Path sandboxDir) {
        List<String> resolved = new ArrayList<>(arguments.size() + 2);
        boolean hasBasePath = false;

        for (int index = 0; index < arguments.size(); index++) {
            String argument = arguments.get(index);
            resolved.add(argument);
            if (index + 1 >= arguments.size()) {
                continue;
            }

            if (PATH_LIST_ARGUMENTS.contains(argument)) {
                resolved.add(resolvePathList(arguments.get(++index), sandboxDir));
            } else if (PATH_ARGUMENTS.contains(argument)) {
                hasBasePath |= BASE_PATH_ARGUMENT.equals(argument);
                resolved.add(resolvePath(arguments.get(++index), sandboxDir));
            } else if ("--report".equals(argument)) {
                String report = arguments.get(++index);
                int separator = report.indexOf(':');
                resolved.add(separator > 0
                        ? report.substring(0, separator + 1) + resolvePath(report.substring(separator + 1), sandboxDir)
                        : report);
            }
        }

        if (!hasBasePath) {
            resolved.add(BASE_PATH_ARGUMENT);
            resolved.add(sandboxDir.toString());
        }
        return resolved;
    }

    /**
     * Rewrites absolute paths under {@code sandboxDir} to relative ones, so diagnostics do not
     * depend on which sandbox served the request. A null {@code sandboxDir} leaves text unchanged.
     */
    public static String relativizePaths(String text, Path sandboxDir) {
        if (sandboxDir == null || text.isEmpty()) {
            return text;
        }
        return text.replace(sandboxDir.toString() + File.separator, "");
    }

    private static String resolvePathList(String value, Path sandboxDir) {
        // Starlark joins inputs with ',' and the classpath with the host path separator.
        StringBuilder resolved = new StringBuilder(value.length() + 64);
        int start = 0;
        for (int index = 0; index <= value.length(); index++) {
            if (index == value.length() || value.charAt(index) == ',' || value.charAt(index) == File.pathSeparatorChar) {
                resolved.append(resolvePath(value.substring(start, index), sandboxDir));
                if (index < value.length()) {
                    resolved.append(value.charAt(index));
                }
                start = index + 1;
            }
        }
        return resolved.toString();
    }

    private static String resolvePath(String path, Path sandboxDir) {
        if (path.isEmpty() || Paths.get(path).isAbsolute()) {
            return path;
        }
        return sandboxDir.resolve(path).normalize().toString();
    }

    /**
     * Filters out specified arguments and their corresponding values from the input argument list.
     */
    public static List<String> filterOutArgValuePairs(List<String> args, Set<String> excludeArgs) {
        List<String> filteredList = new ArrayList<>();

        int index = 0;

        while (index < args.size()) {
            String value = args.get(index);
            if (!excludeArgs.contains(value)) {
                filteredList.add(value);
            } else {
                if (index + 1 < args.size() && !args.get(index + 1).startsWith("--")) {
                    // Skip the arg-value pair since the next list-item is the value
                    index += 1;
                }
            }
            index += 1;
        }

        return filteredList;
    }
}
