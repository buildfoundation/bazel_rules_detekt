package io.buildfoundation.bazel.detekt

import io.buildfoundation.bazel.detekt.execute.DetektExecutableTests
import io.buildfoundation.bazel.detekt.execute.WorkerExecutableTests
import io.buildfoundation.bazel.detekt.stream.WorkerStreamsTests
import org.junit.runner.RunWith
import org.junit.runners.Suite

@RunWith(Suite::class)
@Suite.SuiteClasses(
        DetektExecutableTests::class,
        OneShotApplicationTests::class,
        WorkerExecutableTests::class,
        WorkerStreamsTests::class
)
class TestsSuite