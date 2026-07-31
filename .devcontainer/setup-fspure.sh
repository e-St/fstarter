#!/usr/bin/env bash
# Install fspure into an fstarter (or customer) Codespace / dev container.
#
# - FSharp.PureAnalyzer from nuget.org → workspace analyzers/dotnet/fs/
# - fsharp-pure-decorations via `code` CLI when available
#
# Wired from devcontainer.json:
#   postCreateCommand / postAttachCommand → bash .devcontainer/setup-fspure.sh
#
# Escape hatch: SKIP_FSPURE_SETUP=1
set -euo pipefail

if [[ "${SKIP_FSPURE_SETUP:-}" == "1" ]]; then
  echo "Skipping fspure setup (SKIP_FSPURE_SETUP=1)."
  exit 0
fi

# NuGet scratch off /tmp (chmod 700 can fail on some Docker mounts).
export TMPDIR="${TMPDIR:-${HOME}/.cache/nuget-tmp}"
export TEMP="${TEMP:-$TMPDIR}"
export TMP="${TMP:-$TMPDIR}"
mkdir -p "$TMPDIR"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_ANALYZERS="$ROOT/analyzers/dotnet/fs"
GLOBAL_PACKAGES="${NUGET_PACKAGES:-$HOME/.nuget/packages}"
PUBLISHER_EXT="e-st.fsharp-pure-decorations"

code_cli_usable() {
  command -v code >/dev/null 2>&1 || return 1
  local out
  if ! out="$(code --version 2>&1)"; then
    return 1
  fi
  [[ "$out" != *"not installed"* ]] || return 1
  return 0
}

mirror_from_global() {
  local src
  src="$(
    find "$GLOBAL_PACKAGES/fsharp.pureanalyzer" \
      -path '*/analyzers/dotnet/fs/FSharp.PureAnalyzer.dll' 2>/dev/null \
      | sort -V \
      | tail -1 || true
  )"
  if [[ -z "$src" || ! -f "$src" ]]; then
    return 1
  fi
  mkdir -p "$WORKSPACE_ANALYZERS"
  cp -f "$src" "$WORKSPACE_ANALYZERS/FSharp.PureAnalyzer.dll"
  echo "    workspace → $WORKSPACE_ANALYZERS/FSharp.PureAnalyzer.dll"
}

install_analyzer_nuget() {
  local tmp
  tmp="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp'" RETURN
  echo "==> FSharp.PureAnalyzer: nuget.org"
  (
    cd "$tmp"
    dotnet new classlib -n install -f net10.0 --force --language C# >/dev/null
    cd install
    dotnet add package FSharp.PureAnalyzer
  )
}

echo "==> fspure setup (fstarter)"

if install_analyzer_nuget && mirror_from_global; then
  echo "✅ FSharp.PureAnalyzer installed and mirrored for Ionide"
else
  echo "ERROR: could not install or mirror FSharp.PureAnalyzer from nuget.org" >&2
  echo "       Check network / package availability, then re-run:" >&2
  echo "       bash .devcontainer/setup-fspure.sh" >&2
  exit 1
fi

if code_cli_usable; then
  echo "==> fsharp-pure-decorations: code --install-extension"
  if code --install-extension "$PUBLISHER_EXT" --force; then
    echo "✅ Installed $PUBLISHER_EXT"
  else
    echo "WARNING: extension install failed; try Open VSX / VSIX after attach." >&2
  fi
else
  echo "WARNING: VS Code 'code' CLI not usable; skip extension install." >&2
  echo "         postAttach will re-run this script when code is available." >&2
fi

echo ""
echo "✅ fspure setup done."
echo "   Analyzer: $WORKSPACE_ANALYZERS/FSharp.PureAnalyzer.dll"
echo "   If pure/impure labels are missing: Developer: Reload Window"
