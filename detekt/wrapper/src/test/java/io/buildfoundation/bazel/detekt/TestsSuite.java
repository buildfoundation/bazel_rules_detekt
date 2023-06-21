package io.buildfoundation.bazel.detekt;

import io.buildfoundation.bazel.detekt.execute.DetektExecutableTests;
import io.buildfoundation.bazel.detekt.execute.WorkerExecutableTests;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;

@RunWith(Suite.class)
@Suite.SuiteClasses({
        ApplicationOneShotTests.class,
        DetektExecutableTests.class,
        ExecutionUtilsTests.class,
        WorkerExecutableTests.class,
})
public class TestsSuite {
}
