package io.buildfoundation.bazel.detekt

import org.junit.Assert.assertEquals
import org.junit.Test

class DetektExecutableTests {

    @Test
    fun `it returns success result on Detekt successful execution`() {
        val detekt = TestDetekt(TestDetekt.ExecutionResult.Success)
        val detektExecutable = Executable.DetektImpl(detekt)

        assertEquals(Result.Success, detektExecutable.execute(emptyArray()))
    }

    @Test
    fun `it returns failure result on Detekt failed execution`() {
        val detekt = TestDetekt(TestDetekt.ExecutionResult.Failure)
        val detektExecutable = Executable.DetektImpl(detekt)

        assertEquals(Result.Failure::class, detektExecutable.execute(emptyArray())::class)
    }
}