package tests.integration.jvm

class JvmClasspath {
    fun size(): Int? = JvmApi.name()?.length
}
