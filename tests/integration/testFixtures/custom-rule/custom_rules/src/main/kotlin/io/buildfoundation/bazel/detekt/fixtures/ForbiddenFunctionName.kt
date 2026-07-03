package io.buildfoundation.bazel.detekt.fixtures

import io.gitlab.arturbosch.detekt.api.CodeSmell
import io.gitlab.arturbosch.detekt.api.Config
import io.gitlab.arturbosch.detekt.api.Debt
import io.gitlab.arturbosch.detekt.api.Entity
import io.gitlab.arturbosch.detekt.api.Issue
import io.gitlab.arturbosch.detekt.api.Rule
import io.gitlab.arturbosch.detekt.api.RuleSet
import io.gitlab.arturbosch.detekt.api.RuleSetProvider
import io.gitlab.arturbosch.detekt.api.Severity
import org.jetbrains.kotlin.psi.KtNamedFunction

class ForbiddenFunctionName(config: Config) : Rule(config) {
    override val issue = Issue(
        javaClass.simpleName,
        Severity.CodeSmell,
        "Flags forbidden fixture function names.",
        Debt.FIVE_MINS,
    )

    override fun visitNamedFunction(function: KtNamedFunction) {
        super.visitNamedFunction(function)
        if (function.name == "customRuleViolation") {
            report(CodeSmell(issue, Entity.from(function), "customRuleViolation is forbidden."))
        }
    }
}

class CustomRuleSetProvider : RuleSetProvider {
    override val ruleSetId = "custom"

    override fun instance(config: Config) = RuleSet(ruleSetId, listOf(ForbiddenFunctionName(config)))
}
