package io.buildfoundation.bazel.detekt;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class WriterFactory {
    public BufferedWriter getBufferedWriter(String path) throws IOException {
        return new BufferedWriter(new FileWriter(path));
    }
}
