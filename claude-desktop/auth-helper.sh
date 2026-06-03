#!/usr/bin/env sh
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/bin:$PATH"

DATUMCTL=$(command -v datumctl)
if [ -z "$DATUMCTL" ]; then
  echo "datumctl not found" >&2
  exit 1
fi
exec "$DATUMCTL" auth get-token
