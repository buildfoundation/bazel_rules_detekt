package io.buildfoundation.bazel.rulesdetekt.wrapper

import io.gitlab.arturbosch.detekt.cli.BuildFailure
import io.gitlab.arturbosch.detekt.cli.InvalidConfig
import io.gitlab.arturbosch.detekt.cli.buildRunner

interface SandboxedExecutor {

    enum class Result { Success, Failure }

    fun execute(arguments: Array<String>): Result

    class DetektExecutor : SandboxedExecutor {

        override fun execute(arguments: Array<String>) = try {
            buildRunner(arguments).execute()
            Result.Success
        } catch (e: InvalidConfig) {
            e.printStackTrace()
            Result.Failure
        } catch (e: BuildFailure) {
            e.printStackTrace()
            Result.Failure
        } catch (e: Exception) {
            e.printStackTrace()
            Result.Failure
        }
    }
}