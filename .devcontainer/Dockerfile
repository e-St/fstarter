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
COPY .devcontainer/newf.sh /usr/local/bin/newf
COPY .devcontainer/bundlef.sh /usr/local/bin/bundlef
COPY .devcontainer/runf.sh /usr/local/bin/runf
COPY .devcontainer/watchf.sh /usr/local/bin/watchf
COPY .devcontainer/replf.sh /usr/local/bin/replf
RUN chmod +x /usr/local/bin/newf /usr/local/bin/bundlef /usr/local/bin/runf \
        /usr/local/bin/watchf /usr/local/bin/replf

# Ubuntu image /bin/sh is dash — `set -o pipefail` is a bash option (CI exit 2).
SHELL ["/bin/bash", "-c"]

# Pin-sensitive fspure bits: CLI, analyzer DLLs, Copilot skill, decorations VSIX.
# $$ keeps pins for the shell after sourcing versions.env (Docker would otherwise empty ${...}).
RUN set -euo pipefail \
    && set -a && . /usr/local/share/fspure/versions.env && set +a \
    && curl -fsSL -o /usr/local/bin/fspure \
        "https://github.com/e-St/fspure/releases/download/$${FSPURE_CLI_RELEASE}/fspure" \
    && chmod +x /usr/local/bin/fspure \
    && mkdir -p /usr/local/share/fspure/analyzers/dotnet/fs \
        /usr/local/share/fspure/skills/fspure-reduce-impurity \
    && curl -fsSL -o /tmp/fsharp.pureanalyzer.nupkg \
        "https://api.nuget.org/v3-flatcontainer/fsharp.pureanalyzer/$${FSPURE_ANALYZER_VERSION}/fsharp.pureanalyzer.$${FSPURE_ANALYZER_VERSION}.nupkg" \
    && unzip -qo /tmp/fsharp.pureanalyzer.nupkg "analyzers/dotnet/fs/*" -d /tmp/fspure-nupkg \
    && cp /tmp/fspure-nupkg/analyzers/dotnet/fs/*.dll /usr/local/share/fspure/analyzers/dotnet/fs/ \
    && curl -fsSL -o /usr/local/share/fspure/skills/fspure-reduce-impurity/SKILL.md \
        "https://raw.githubusercontent.com/e-St/fspure/$${FSPURE_SKILL_REF}/plugins/fspure/skills/fspure-reduce-impurity/SKILL.md" \
    && python3 -c "import json,urllib.request; url=json.load(urllib.request.urlopen('https://open-vsx.org/api/e-St/fsharp-pure-decorations/latest'))['files']['download']; urllib.request.urlretrieve(url, '/usr/local/share/fspure/fsharp-pure-decorations.vsix')" \
    && rm -rf /tmp/fsharp.pureanalyzer.nupkg /tmp/fspure-nupkg

USER vscode

RUN mkdir -p /home/vscode/.copilot/skills/fspure-reduce-impurity \
        /home/vscode/.local/bin \
        /home/vscode/.cache/nuget-tmp \
    && cp /usr/local/share/fspure/skills/fspure-reduce-impurity/SKILL.md \
        /home/vscode/.copilot/skills/fspure-reduce-impurity/SKILL.md \
    && dotnet tool install --global paket \
    && dotnet tool install --global Fun.Build.Cli \
    && dotnet tool install --global fantomas
