# syntax=docker/dockerfile:1
# Edit this file and the image tag in .devcontainer/devcontainer.json and .github/workflows/devcontainer.yml only if you want a container other than ghcr.io/e-st/fstarter:latest.
FROM mcr.microsoft.com/devcontainers/dotnet:10.0-noble

USER root

# Node, GitHub CLI, and unzip are baked here so start does not run extra
# devcontainer features or package downloads.
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs gh unzip \
    && rm -rf /var/lib/apt/lists/*

COPY .devcontainer/fspure-versions.env /usr/local/share/fspure/versions.env
COPY .devcontainer/bake-fspure.sh /usr/local/share/fspure/bake-fspure.sh
COPY .devcontainer/newf.sh /usr/local/bin/newf
COPY .devcontainer/bundlef.sh /usr/local/bin/bundlef
COPY .devcontainer/runf.sh /usr/local/bin/runf
COPY .devcontainer/watchf.sh /usr/local/bin/watchf
COPY .devcontainer/replf.sh /usr/local/bin/replf
RUN chmod +x /usr/local/bin/newf /usr/local/bin/bundlef /usr/local/bin/runf \
        /usr/local/bin/watchf /usr/local/bin/replf \
        /usr/local/share/fspure/bake-fspure.sh

# Ubuntu image /bin/sh is dash — bake script needs bash (`set -o pipefail`).
# Do not put ${FSPURE_*} in this RUN: Docker empties them; `$$` can become a PID URL (404).
SHELL ["/bin/bash", "-c"]
RUN --mount=type=secret,id=github_token,required=false \
    if [[ -f /run/secrets/github_token ]]; then export GH_TOKEN="$(cat /run/secrets/github_token)"; fi \
    && bash /usr/local/share/fspure/bake-fspure.sh

USER vscode

RUN mkdir -p /home/vscode/.copilot/skills/fspure-reduce-impurity \
        /home/vscode/.local/bin \
        /home/vscode/.cache/nuget-tmp \
    && cp /usr/local/share/fspure/skills/fspure-reduce-impurity/SKILL.md \
        /home/vscode/.copilot/skills/fspure-reduce-impurity/SKILL.md \
    && dotnet tool install --global paket \
    && dotnet tool install --global Fun.Build.Cli \
    && dotnet tool install --global fantomas
