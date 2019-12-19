fmt:
	buildifier -mode fix -lint fix -r .

fmt-check:
	buildifier -mode check -lint warn -r .

docs:
	bazelisk build //detekt:docs
	mv bazel-bin/detekt/rule.md docs/rule.md
	chmod -x docs/rule.md
	chmod u+w docs/rule.md

.PHONY: docs
