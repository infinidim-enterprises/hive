# Nix Configuration

This repository is home to the nix code that builds my systems.

<!-- Disable octoprint for now -->
<!-- [![octoprint](https://img.shields.io/cirrus/github/infinidim-enterprises/hive?label=octoprint&logo=nixos&logoColor=white&task=Build%20octoprint)][octoprint] -->

[![tl-wsl](https://img.shields.io/github/actions/workflow/status/infinidim-enterprises/hive/build-tl-wsl.yaml?event=push&logo=nixos&logoColor=white&label=tl-wsl)][tl-wsl]
[![depsos](https://img.shields.io/github/actions/workflow/status/infinidim-enterprises/hive/build-depsos.yaml?event=push&logo=nixos&logoColor=white&label=depsos)][depsos]
[![hyperos](https://img.shields.io/github/actions/workflow/status/infinidim-enterprises/hive/build-hyperos.yaml?event=push&logo=nixos&logoColor=white&label=hyperos)][hyperos]
[![nas](https://img.shields.io/github/actions/workflow/status/infinidim-enterprises/hive/build-nas.yaml?event=push&logo=nixos&logoColor=white&label=nas)][nas]
[![rockiosk](https://img.shields.io/github/actions/workflow/status/infinidim-enterprises/hive/build-rockiosk.yaml?event=push&logo=nixos&logoColor=white&label=rockiosk)][rockiosk]
[![squadbook](https://img.shields.io/cirrus/github/infinidim-enterprises/hive?label=squadbook&logo=nixos&logoColor=white&task=Build%20squadbook)][squadbook]

<!-- [![oracle](https://img.shields.io/circleci/build/github/cci-eve3ef/hive/master?logo=nixos&logoColor=white&label=oracle&token=fc9316dc8bf54cce1696513462f83e93dd3e77aa)][oracle] -->
<!-- [![voron](https://img.shields.io/circleci/build/github/cci-eve3ef/hive/master?logo=nixos&logoColor=white&label=voron&token=fc9316dc8bf54cce1696513462f83e93dd3e77aa)][voron] -->

## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This means that once something is setup and configured once, it works forever. If someone else shares their configuration, anyone can make use of it.

This flake is configured with the use of [hive][hive].

## Apply configs

### NixOS hosts

```bash
colmena build
colmena apply
# OR
colmena apply --on "nixos-$HOST"
```

### Darwin hosts

```bash
darwin-rebuild switch --flake .
```

[hive]: https://github.com/divnix/hive

<!-- [octoprint]: <https://cirrus-ci.com/github/infinidim-enterprises/infra/> -->
<!-- GitHub Actions -->

[tl-wsl]: https://github.com/infinidim-enterprises/hive/actions/workflows/build-tl-wsl.yaml
[depsos]: https://github.com/infinidim-enterprises/hive/actions/workflows/build-depsos.yaml
[hyperos]: https://github.com/infinidim-enterprises/hive/actions/workflows/build-hyperos.yaml
[nas]: https://github.com/infinidim-enterprises/hive/actions/workflows/build-nas.yaml
[rockiosk]: https://github.com/infinidim-enterprises/hive/actions/workflows/build-rockiosk.yaml

<!-- CirrusCI -->

[squadbook]: https://cirrus-ci.com/github/infinidim-enterprises/hive/

<!-- CircleCI -->

[voron]: https://app.circleci.com/pipelines/github/2RXFjC67aDYfzqq8Drhzfg/hive?branch=master
[oracle]: https://app.circleci.com/pipelines/github/2RXFjC67aDYfzqq8Drhzfg/hive?branch=master
