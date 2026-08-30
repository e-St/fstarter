#!/usr/bin/env bash
# Bake fspure CLI, analyzer DLLs, Copilot skill, and decorations VSIX into the image.
# Invoked from Dockerfile (not overlay-copied). Pins come from versions.env.
set -euo pipefail

PREFIX="${FSPURE_BAKE_PREFIX:-/usr/local}"
VERSIONS="${FSPURE_VERSIONS_FILE:-${PREFIX}/share/fspure/versions.env}"
UA="e-St-fstarter-image-bake"

set -a
# shellcheck disable=SC1090
. "$VERSIONS"
set +a

: "${FSPURE_ANALYZER_VERSION:?missing FSPURE_ANALYZER_VERSION in $VERSIONS}"
: "${FSPURE_SKILL_REF:?missing FSPURE_SKILL_REF in $VERSIONS}"
: "${FSPURE_CLI_RELEASE:?missing FSPURE_CLI_RELEASE in $VERSIONS}"

TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"

echo "==> bake fspure"
echo "    versions=${VERSIONS}"
echo "    analyzer=${FSPURE_ANALYZER_VERSION}"
echo "    skill_ref=${FSPURE_SKILL_REF}"
echo "    cli_release=${FSPURE_CLI_RELEASE}"
echo "    github_auth=$([ -n "$TOKEN" ] && echo yes || echo no)"

mkdir -p \
  "${PREFIX}/bin" \
  "${PREFIX}/share/fspure/analyzers/dotnet/fs" \
  "${PREFIX}/share/fspure/skills/fspure-reduce-impurity"

auth_headers=()
if [[ -n "$TOKEN" ]]; then
  auth_headers=(-H "Authorization: Bearer ${TOKEN}")
fi

# GitHub Actions 404s anonymous github.com/releases/download. Use the API + asset URL.
echo "==> fspure CLI tag=${FSPURE_CLI_RELEASE}"
api="https://api.github.com/repos/e-St/fspure/releases/tags/${FSPURE_CLI_RELEASE}"
echo "    GET ${api}"
asset_api="$(
  curl -fsSL --retry 3 --retry-delay 2 \
    -H "User-Agent: ${UA}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${auth_headers[@]}" \
    "$api" \
    | python3 -c '
import json, sys
rel = json.load(sys.stdin)
for a in rel.get("assets") or []:
    if a.get("name") == "fspure":
        print(a["url"])
        sys.exit(0)
sys.exit("release has no asset named fspure")
'
)"
echo "    GET ${asset_api} (octet-stream)"
curl -fsSL --retry 3 --retry-delay 2 \
  -H "User-Agent: ${UA}" \
  -H "Accept: application/octet-stream" \
  "${auth_headers[@]}" \
  -L -o "${PREFIX}/bin/fspure" \
  "$asset_api"
chmod +x "${PREFIX}/bin/fspure"

nupkg_url="https://api.nuget.org/v3-flatcontainer/fsharp.pureanalyzer/${FSPURE_ANALYZER_VERSION}/fsharp.pureanalyzer.${FSPURE_ANALYZER_VERSION}.nupkg"
echo "==> FSharp.PureAnalyzer ${FSPURE_ANALYZER_VERSION}"
echo "    GET ${nupkg_url}"
curl -fsSL --retry 3 --retry-delay 2 -H "User-Agent: ${UA}" -o /tmp/fsharp.pureanalyzer.nupkg "$nupkg_url"
unzip -qo /tmp/fsharp.pureanalyzer.nupkg "analyzers/dotnet/fs/*" -d /tmp/fspure-nupkg
cp /tmp/fspure-nupkg/analyzers/dotnet/fs/*.dll "${PREFIX}/share/fspure/analyzers/dotnet/fs/"

skill_url="https://raw.githubusercontent.com/e-St/fspure/${FSPURE_SKILL_REF}/plugins/fspure/skills/fspure-reduce-impurity/SKILL.md"
echo "==> skill ${FSPURE_SKILL_REF}"
echo "    GET ${skill_url}"
curl -fsSL --retry 3 --retry-delay 2 -H "User-Agent: ${UA}" \
  -o "${PREFIX}/share/fspure/skills/fspure-reduce-impurity/SKILL.md" \
  "$skill_url"

echo "==> fsharp-pure-decorations Open VSX"
python3 -c "import json,urllib.request; req=urllib.request.Request('https://open-vsx.org/api/e-St/fsharp-pure-decorations/latest', headers={'User-Agent':'${UA}'}); url=json.load(urllib.request.urlopen(req))['files']['download']; urllib.request.urlretrieve(url, '${PREFIX}/share/fspure/fsharp-pure-decorations.vsix')"

rm -rf /tmp/fsharp.pureanalyzer.nupkg /tmp/fspure-nupkg
echo "==> bake done"
