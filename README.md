# fstarter

Starter template for F# projects. Paket, Fun.Build, Ionide, and the fspure analyzer/decorations are pre-wired.

## Create a repo from this template

Use GitHub’s **Use this template** flow:

https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template

## Out of the box (zero edits)

- The dev container pulls `ghcr.io/e-st/fstarter:latest` (public GHCR image).
- VS Code/Codespaces extensions in `.devcontainer/devcontainer.json` install automatically (Ionide, C#). `fsharp-pure-decorations` is not on the MS Marketplace; setup unpacks the baked Open VSX VSIX (pure/impure labels).
- `postCreateCommand` runs `.devcontainer/setup-fspure.sh` (analyzer DLLs for Ionide, decorations VSIX, `fspure` CLI, Copilot skill).

The image-publish workflow in `.github/workflows/devcontainer.yml` only runs in `e-St/fstarter`. Downstream repos keep the shared image and do not need to rename tags.

## What you still change by hand

- [README.md](README.md) — replace this text with your project’s description.
- [solution.slnx](solution.slnx) and [test/](test/) — rename or replace the sample `test` project.

Nothing else in this template is repo-name-specific. Leave `.devcontainer/devcontainer.json` `"image"` as `ghcr.io/e-st/fstarter:latest` unless you customize the container.

## Customizing the dev container

Only if you need different tools or scripts than `ghcr.io/e-st/fstarter:latest`:

1. Change [.devcontainer/Dockerfile](.devcontainer/Dockerfile).
2. Point `"image"` in [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) at your own registry path, and publish that image (the comments at the top of the Dockerfile and `.github/workflows/devcontainer.yml` describe the same pair of edits).

## Day-2 commands

- Build / test: `dotnet build` / `dotnet test`
- Format: `fantomas .`
- Analyze: `fspure analyze --project <fsproj>`
- Packages: `paket install` / `paket update`

## Staying up to date with fstarter

This workflow is **not** enabled in fstarter. In a repo created from the template:

1. Copy [docs/template-sync/template-sync.workflow.yml](docs/template-sync/template-sync.workflow.yml) to `.github/workflows/` (any filename ending in `.yml`).
2. Copy [docs/template-sync/.templatesyncignore.example](docs/template-sync/.templatesyncignore.example) to `.templatesyncignore` at the repo root (or under `.github/`).
3. Enable **Settings > Actions > General > Allow GitHub Actions to create and approve pull requests**.

The example runs monthly (`0 0 1 * *`) and on `workflow_dispatch`, with `source_repo_path: e-St/fstarter`. Review and merge sync PRs by hand.
