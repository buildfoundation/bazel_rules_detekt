package io.buildfoundation.bazel.detekt.execute

sealed class Result {
    object Success : Result()
    data class Failure(val description: String) : Result()

    val consoleStatusCode by lazy {
        when (this) {
            is Success -> 0
            is Failure -> 1
        }
    }
}