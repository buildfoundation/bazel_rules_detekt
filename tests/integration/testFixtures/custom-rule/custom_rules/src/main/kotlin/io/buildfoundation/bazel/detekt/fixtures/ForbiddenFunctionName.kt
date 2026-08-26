package io.buildfoundation.bazel.detekt.fixtures

import dev.detekt.api.Config
import dev.detekt.api.Entity
import dev.detekt.api.Finding
import dev.detekt.api.Rule
import dev.detekt.api.RuleSet
import dev.detekt.api.RuleSetId
import dev.detekt.api.RuleSetProvider
import org.jetbrains.kotlin.psi.KtNamedFunction

class ForbiddenFunctionName(config: Config) : Rule(config, "Flags forbidden fixture function names.") {

    override fun visitNamedFunction(function: KtNamedFunction) {
        super.visitNamedFunction(function)
        if (function.name == "customRuleViolation") {
            report(Finding(Entity.from(function), "customRuleViolation is forbidden."))
        }
    }
}

class CustomRuleSetProvider : RuleSetProvider {
    override val ruleSetId = RuleSetId("custom")

    override fun instance() = RuleSet(ruleSetId, listOf(::ForbiddenFunctionName))
}
