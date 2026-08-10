#!/usr/bin/env bash
set -euo pipefail

# scripts/detect_5_10_tag.sh
# Detect the latest v5.10.* tag from a kernel remote and export variables
# Usage:
#   KERNEL_REMOTE can be set in the environment to override the default remote
#   ./scripts/detect_5_10_tag.sh

# Default remote (linux-stable). Replace with your fork/vendor if needed.
KERNEL_REMOTE="${KERNEL_REMOTE:-https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git}"
PATTERN='refs/tags/v5.10.*'

# Find the latest tag matching v5.10.*
LATEST_5_10_TAG=$(git ls-remote --tags --refs "$KERNEL_REMOTE" "$PATTERN" \
  | awk -F/ '{print $3}' \
  | sed 's/\^{}$//' \
  | sort -V \
  | tail -n1)

if [ -z "$LATEST_5_10_TAG" ]; then
  echo "ERROR: não foi possível detectar tag v5.10.* em $KERNEL_REMOTE" >&2
  exit 1
fi

# Extract the numeric sublevel (e.g., v5.10.260 -> 260)
SUBLEVEL=$(printf '%s' "$LATEST_5_10_TAG" | sed -E 's/^v?5\.10\.([0-9]+)$/\1/')

if [ -z "$SUBLEVEL" ]; then
  echo "ERROR: tag detectada ($LATEST_5_10_TAG) não tem formato v5.10.<sublevel>" >&2
  exit 1
fi

# Print/export variables for use in scripts or CI
echo "KERNEL_TAG=$LATEST_5_10_TAG"
echo "KERNEL_REMOTE=$KERNEL_REMOTE"
echo "KERNEL_SUBLEVEL=$SUBLEVEL"

# Export so that sourcing the script sets them in the caller environment
export KERNEL_TAG="$LATEST_5_10_TAG"
export KERNEL_SUBLEVEL="$SUBLEVEL"
export KERNEL_REMOTE

# Also write to a file for CI consumption if wanted
if [ "${WRITE_KERNEL_ENV:-}" = "1" ]; then
  echo "KERNEL_TAG=$KERNEL_TAG" > .kernel_tag.env
  echo "KERNEL_SUBLEVEL=$KERNEL_SUBLEVEL" >> .kernel_tag.env
  echo "KERNEL_REMOTE=$KERNEL_REMOTE" >> .kernel_tag.env
fi
