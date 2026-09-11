#!/bin/sh
# 1cmdinstall — fetch the Company OS bootstrap prompts into the current repo.
# Usage: curl -fsSL <raw>/1cmdinstall/install.sh | sh
set -eu

RAW="https://raw.githubusercontent.com/Miyamura80/code-agent-config/main/1cmdinstall"

for f in company-os-init.md company-os-wire.md; do
  echo "Fetching $f ..."
  curl -fsSL "$RAW/$f" -o "$f"
done

cat <<'EOF'

Done. Two prompts are now in this directory:
  - company-os-init.md   (run first: interview + scaffold)
  - company-os-wire.md   (run second: submodules, sync, hooks, CI)

Next: open your coding agent (e.g. Claude Code) in this repo and paste the
contents of company-os-init.md. When the scaffold exists, paste company-os-wire.md.
EOF
