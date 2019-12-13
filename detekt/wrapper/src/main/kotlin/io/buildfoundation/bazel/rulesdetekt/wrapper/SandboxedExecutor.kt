package io.buildfoundation.bazel.rulesdetekt.wrapper

import java.lang.reflect.InvocationTargetException

interface SandboxedExecutor {

    enum class Result { Success, Failure }

    fun execute(arguments: Array<String>): Result

    object DetektExecutor : SandboxedExecutor {

        override fun execute(arguments: Array<String>): Result = try {
            executeRunner(arguments)
            Result.Success
        } catch (e: IllegalStateException) {
            System.err.println("Detekt access error: ${e.message}")
            Result.Failure
        } catch (e: InvocationTargetException) {
            e.cause?.printStackTrace()
            Result.Failure
        } catch (e: Exception) {
            System.err.println("Unknown error")
            e.printStackTrace()
            Result.Failure
        }

        private fun executeRunner(arguments: Array<String>) {
            val mainClass = try {
                Class.forName("io.gitlab.arturbosch.detekt.cli.Main")
            } catch (e: ClassNotFoundException) {
                throw IllegalStateException("Detekt main class not found", e)
            }

            val runner = try {
                mainClass.declaredMethods.first { it.name == "buildRunner" }.invoke(null, arguments)
            } catch (e: NoSuchElementException) {
                throw IllegalStateException("Detekt runner building method not found", e)
            }

            try {
                runner.javaClass.declaredMethods.first { it.name == "execute" }.invoke(runner)
            } catch (e: NoSuchElementException) {
                throw IllegalStateException("Detekt runner execute method not found", e)
            }
        }
    }
}