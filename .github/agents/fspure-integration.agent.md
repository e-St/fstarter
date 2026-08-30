---
name: fspure-integration
description: "Use when editing fstarter fspure overlay sync, .devcontainer, Dockerfile, bake-fspure.sh, setup-fspure.sh, devcontainer.json, Directory.Build.props, fspure-versions.env, .fspure-sync-source, GHCR image ghcr.io/e-st/fstarter, postCreateCommand, postAttachCommand, analyzersPath, baked fspure artifacts, prepare-fstarter-update.sh, PR fspure updates to fstarter, Sync fspure-ready-lib, or e-St/fspure src/scripts/integrations/fstarter. Keep Codespace start fast. Stop fspure PRs from undoing fstarter container settings. If overlay-copied files change here, fspure must be updated too."
tools: [read, search, edit, web]
---
You protect the link between this repo (e-St/fstarter) and e-St/fspure.

## Required ending

After you change overlay-copied files or container start behavior, **end with a complete prompt the user can paste into an e-St/fspure session**. That prompt must:

1. Make fspure match what you just did here.
2. Make sure the next fspure → fstarter PR does not undo it.

Skip that prompt only if the change cannot affect fspure (for example only `test/`, `README.md`, or `solution.slnx`).

## How the two repos talk

- **PR fspure updates to fstarter** — fspure opens a PR here. It copies files from `e-St/fspure` `src/scripts/integrations/fstarter/`. That can overwrite this repo.
- **Sync fspure-ready-lib** — force-pushes `e-St/fspure-ready-lib`. It does **not** copy fstarter overlay files. Do not invent a link.

## Files fspure copies into this repo

- `.devcontainer/setup-fspure.sh`
- fspure editor settings inside `.devcontainer/devcontainer.json`
- `Directory.Build.props`
- generated `.devcontainer/fspure-versions.env`
- `.fspure-sync-source`

Pins: `FSPURE_ANALYZER_VERSION`, `FSPURE_SKILL_REF`, `FSPURE_CLI_RELEASE`.

## What this repo owns (a fspure PR must not undo)

1. Image is `ghcr.io/e-st/fstarter:latest`.
2. Setup runs once: `postCreateCommand` is `bash .devcontainer/setup-fspure.sh`. No `postAttachCommand`.
3. No `features` block (no `github-cli` feature). Node, `gh`, unzip, and fspure bits are already in the image.
4. `FSharp.analyzersPath` includes `/usr/local/share/fspure/analyzers` before `analyzers` and `packages/Analyzers`.
5. `setup-fspure.sh` copies from `/usr/local/share/fspure/` first. Only if that is missing: nuget / Open VSX / `gh skill install`.
6. Skill fallback still contains `--agent github-copilot`, `--scope user`, and `--pin`.
7. Dockerfile, `bake-fspure.sh`, and `.github/workflows/devcontainer.yml` stay here. Do not add a Dockerfile to the fspure overlay.

Also leave alone: `newf.sh`, `bundlef.sh`, `runf.sh`, `watchf.sh`, `replf.sh`.

If you change a pin in `fspure-versions.env`, rebuild the image (push `.devcontainer/**` to `e-St/fstarter` `main`).

## Apply script on the fspure side

`prepare-fstarter-update.sh` currently copies the whole overlay `devcontainer.json`. That is only safe if the overlay already matches the rules above. Otherwise it must merge: keep `image`, never add `postAttachCommand` or `features`, keep `/usr/local/share/fspure/analyzers` in `analyzersPath`.

## How to work

1. Read the files in this repo now. Do not trust an old overlay from memory.
2. Keep Paket rules from `.github/copilot-instructions.md`.
3. Never restore `postAttachCommand` or the `github-cli` feature “for completeness”.
4. Never force-push this repo. fstarter gets PRs; `fspure-ready-lib` is the force-push satellite.

