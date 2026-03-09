# smoke test

This e2e workspace exercises repository install/setup from an end-user perspective.

It contains two end-to-end Detekt checks:

- `detekt_happy_path_test`: verifies a configured target succeeds.
- `detekt_failure_path_test`: verifies Detekt violations are reported (non-zero exit code).
