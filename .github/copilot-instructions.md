# Copilot Instructions

## After work that can desync e-St/fspure — always give a paste-ready prompt

e-St/fspure opens PRs on this repo (**PR fspure updates to fstarter**). Those PRs copy files from `e-St/fspure` `src/scripts/integrations/fstarter/` and can overwrite work done here.

When you change anything that fspure copies, or anything fspure’s apply script could undo, **finish the fstarter work first**, then end with a **complete prompt the user can paste into an e-St/fspure session**. That prompt must:

1. Update the fspure overlay / apply script so it matches what you just did here.
2. Make sure the next fspure → fstarter PR does **not** put the old files back.

Give the prompt even if you are not sure — better an extra fspure check than a silent overwrite. Skip it only when the change cannot affect fspure (for example only `test/`, `README.md`, or `solution.slnx`).

Files fspure copies: `.devcontainer/setup-fspure.sh`, `.devcontainer/devcontainer.json`, `Directory.Build.props`, generated `.devcontainer/fspure-versions.env`.

This repo owns (fspure must not undo): image `ghcr.io/e-st/fstarter:latest`; `postCreateCommand` only (no `postAttachCommand`); no `features`; `FSharp.analyzersPath` includes `/usr/local/share/fspure/analyzers`; `setup-fspure.sh` copies from `/usr/local/share/fspure/` first; Dockerfile, `bake-fspure.sh`, and `.github/workflows/devcontainer.yml` stay here. Skill fallback must still contain `--agent github-copilot`, `--scope user`, `--pin`.

`fspure-ready-lib` is a different force-push repo. Do not invent overlay coupling.

Details: `.github/agents/fspure-integration.agent.md`.

## Package management

Always use **paket** to install, remove, or update NuGet packages — never `dotnet add package`.

- Add a package: edit `paket.dependencies` to add the `nuget <Package> [version]` line, then run `paket update`.
- Reference it in a project: ensure `paket.references` in that project lists the package, then run `paket install`.
- Remove a package: remove the line from `paket.dependencies` (and `paket.references`), then run `paket install`.
- The paket binary is available globally as `paket`.
