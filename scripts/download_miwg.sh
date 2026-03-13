#!/usr/bin/env bash
# Download MIWG (Model Interchange Working Group) BPMN conformance test files.
#
# These files are reference BPMN 2.0 diagrams used to verify parser conformance.
# Source: https://github.com/bpmn-miwg/bpmn-miwg-test-suite
#
# Downloads the latest release zip and extracts all .bpmn reference files.
#
# Usage: ./scripts/download_miwg.sh

set -euo pipefail

DEST="test/fixtures/conformance/miwg"
TMPDIR=$(mktemp -d)

trap 'rm -rf "$TMPDIR"' EXIT

echo "Fetching latest release info..."
DOWNLOAD_URL=$(curl -sSL "https://api.github.com/repos/bpmn-miwg/bpmn-miwg-test-suite/releases/latest" \
  | grep -o '"browser_download_url": "[^"]*"' \
  | head -1 \
  | cut -d'"' -f4)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "ERROR: Could not determine download URL from latest release"
  exit 1
fi

echo "Downloading: $DOWNLOAD_URL"
curl -sSfL "$DOWNLOAD_URL" -o "$TMPDIR/miwg.zip"

echo "Extracting reference BPMN files..."
unzip -o "$TMPDIR/miwg.zip" "Reference/*.bpmn" -d "$TMPDIR" > /dev/null 2>&1

mkdir -p "$DEST"
cp "$TMPDIR/Reference/"*.bpmn "$DEST/"

echo "Done. Files saved to ${DEST}/:"
ls "$DEST/"*.bpmn | xargs -I{} basename {}
