---
description: "Use when editing fstarter .devcontainer, Dockerfile, bake-fspure.sh, setup-fspure.sh, devcontainer.json, Directory.Build.props, fspure-versions.env, GHCR image, postCreateCommand, analyzersPath, or fspure overlay sync. After those edits, give a paste-ready prompt for e-St/fspure."
applyTo:
  - ".devcontainer/**"
  - "Directory.Build.props"
  - ".fspure-sync-source"
  - ".github/workflows/devcontainer.yml"
  - ".github/agents/fspure-integration.agent.md"
---

# Keep fspure in sync with this repo

If this task changed overlay-copied files or container start behavior, end with a **paste-ready prompt for e-St/fspure** so:

1. fspure’s overlay matches what you just did.
2. the next **PR fspure updates to fstarter** does not overwrite it.

Do not restore `postAttachCommand`, `features` / `github-cli`, or a nuget-every-start `setup-fspure.sh`. Do not drop `/usr/local/share/fspure/analyzers` from `FSharp.analyzersPath`.

Full rules: `.github/agents/fspure-integration.agent.md`.
