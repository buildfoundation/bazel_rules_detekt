# How to Contribute

## Using devcontainers

If you are using [devcontainers](https://code.visualstudio.com/docs/devcontainers/containers)
and/or [codespaces](https://github.com/features/codespaces) then you can start
contributing immediately and skip the next step.

## Formatting

Starlark files should be formatted by buildifier.
We suggest using a pre-commit hook to automate this.
First [install pre-commit](https://pre-commit.com/#installation),
then run

```shell
pre-commit install
```

Otherwise later tooling on CI will report formatting/linting violations.

## Using this repository as a development dependency

To force another Bazel workspace to use this local checkout instead of a release artifact,
run this from the root of this repo:

```sh
OVERRIDE="--override_repository=rules_detekt=$(pwd)"
echo "common $OVERRIDE" >> ~/.bazelrc
```

## Releasing

Releases are triggered by pushing a semver tag, for example:

```sh
git tag v1.2.3
git push origin v1.2.3
```

That triggers `.github/workflows/release.yaml`, which also invokes `.github/workflows/publish.yaml` for BCR publication.
