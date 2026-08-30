# Copilot Instructions

## fspure overlay (do not clobber)

The next **PR fspure updates to fstarter** copies overlay files from `e-St/fspure` (`src/scripts/integrations/fstarter/`). Keep fstarter-owned container settings:

- Image `ghcr.io/e-st/fstarter:latest`; `postCreateCommand` only (no `postAttachCommand`); no `features`
- `FSharp.analyzersPath` includes `/usr/local/share/fspure/analyzers`
- `setup-fspure.sh` baked-fast-path under `/usr/local/share/fspure/`; fallback `gh skill install` still has `--agent github-copilot`, `--scope user`, `--pin`
- Dockerfile is **not** in the overlay. If you change overlay-copied files, update the fspure pack too.

For overlay / start-time work, use `.github/agents/fspure-integration.agent.md`.

## Package management

Always use **paket** to install, remove, or update NuGet packages — never `dotnet add package`.

- Add a package: edit `paket.dependencies` to add the `nuget <Package> [version]` line, then run `paket update`.
- Reference it in a project: ensure `paket.references` in that project lists the package, then run `paket install`.
- Remove a package: remove the line from `paket.dependencies` (and `paket.references`), then run `paket install`.
- The paket binary is available globally as `paket`.
