#!/usr/bin/env bash
set -euo pipefail

# scripts/print_integration_sed.sh
# Helper that prints suggested sed commands to inject detection into a build script
# Usage: ./scripts/print_integration_sed.sh <path-to-build-script>

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <build-script-path>" >&2
  exit 2
fi
BUILD_SCRIPT="$1"

cat <<'EOF'
# Suggested insertion (before cloning the kernel) - run these commands to apply

# 1) Add sourcing of detection script at the top of your build script (after set -euo pipefail):
# sed -i '1,/set -euo pipefail/ s//&\n\n# Auto-detect latest v5.10 tag\nsource "$(pwd)/scripts/detect_5_10_tag.sh"\n/' 