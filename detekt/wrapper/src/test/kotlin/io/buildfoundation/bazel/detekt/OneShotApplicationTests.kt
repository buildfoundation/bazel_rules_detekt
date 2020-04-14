package io.buildfoundation.bazel.detekt

import io.buildfoundation.bazel.detekt.execute.Result
import io.buildfoundation.bazel.detekt.execute.TestExecutable
import io.buildfoundation.bazel.detekt.stream.Streams
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.ByteArrayOutputStream
import java.io.PrintStream

class OneShotApplicationTests {

    @Test
    fun `it does not write to error stream on successful execution`() {
        val errorStreamBuffer = ByteArrayOutputStream()

        val executable = TestExecutable(Result.Success)
        val streams = Streams.system().copy(error = PrintStream(errorStreamBuffer))
        val platform = TestPlatform()
        val application = Application.OneShot(executable, streams, platform)

        application.run(emptyArray())

        assertTrue(errorStreamBuffer.toString().isEmpty())
        assertEquals(0, platform.exitCode)
    }

    @Test
    fun `writes to error stream on failed execution`() {
        val errorStreamBuffer = ByteArrayOutputStream()
        val errorDescription = "error description"

        val executable = TestExecutable(Result.Failure(errorDescription))
        val streams = Streams.system().copy(error = PrintStream(errorStreamBuffer))
        val platform = TestPlatform()
        val application = Application.OneShot(executable, streams, platform)

        application.run(emptyArray())

        assertTrue(errorStreamBuffer.toString().isNotEmpty())
        assertEquals("$errorDescription\n", errorStreamBuffer.toString())
        assertEquals(1, platform.exitCode)
    }
}