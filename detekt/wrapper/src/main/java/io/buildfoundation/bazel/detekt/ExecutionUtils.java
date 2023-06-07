package io.buildfoundation.bazel.detekt;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
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
        String outputPath = getArgument(arguments, argumentName);
        if (outputPath == null) {
            throw new IllegalStateException("Value not found for argument " + argumentName);
        }
        return outputPath;
    }

    /**
     * Writes the execution result to a file
     */
    public static void writeExecutionResultToFile(Integer exitCode, String executionResultOutputPath) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(executionResultOutputPath))) {
            writer.write(String.format("%d", exitCode));
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
    public static List<String> readArgumentsFromFile(String filePath) {
        try {
            if (isParamsFile(filePath)) {
                filePath = filePath.substring(1);
            }
            Path path = Paths.get(filePath);
            return Files.readAllLines(path);
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
    public static String getArgument(List<String> inputArgs, String argName) {
        try {
            // Get the index of the argument and return the value at the next index.
            return inputArgs.get(inputArgs.indexOf(argName) + 1);
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
                if (!args.get(index + 1).startsWith("--")) {
                    // Skip the arg-value pair since matching argument was found
                    index += 1;
                }
            }
            index += 1;
        }

        return filteredList;
    }
}
