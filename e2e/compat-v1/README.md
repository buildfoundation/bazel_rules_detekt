# Detekt 1.x compatibility

This nested module overrides the local `rules_detekt` checkout to Detekt
1.23.8. Its test covers the 1.x CLI, `max_issues`, XML and text reports, and a
locally built 1.x custom rule plugin.

It also depends on `ignored_detekt_version`, a module that sets a different
`detekt_version`, to check that only the root module's version is used.
