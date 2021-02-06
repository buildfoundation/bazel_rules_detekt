package io.buildfoundation.bazel.detekt.stream;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.PrintStream;

public class TestStreams implements Streams {

    final ByteArrayOutputStream inputSink = new ByteArrayOutputStream();
    final ByteArrayOutputStream outputSink = new ByteArrayOutputStream();
    final ByteArrayOutputStream errorSink = new ByteArrayOutputStream();

    @Override
    public InputStream input() {
        return new ByteArrayInputStream(inputSink.toByteArray());
    }

    @Override
    public PrintStream output() {
        return new PrintStream(outputSink);
    }

    @Override
    public PrintStream error() {
        return new PrintStream(errorSink);
    }
}
