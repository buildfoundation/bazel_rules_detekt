package io.buildfoundation.bazel.detekt;

import io.buildfoundation.bazel.detekt.execute.DetektExecutableTests;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;

@RunWith(Suite.class)
@Suite.SuiteClasses({
        DetektExecutableTests.class,
        ExecutionUtilsTests.class,
})
public class TestsSuite {
}
