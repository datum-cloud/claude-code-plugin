# Claude Desktop auth helper

Bridges [`datumctl`](https://github.com/datum-cloud/datumctl) and the **Helper script** in Claude Desktop's _Configure third-party inference_ (Developer Mode) so the desktop app can authenticate as the signed-in Datum user.

Claude Desktop re-runs the script on HTTP 401, so credentials refresh automatically - no manual token pasting required.

## Prerequisites

- `datumctl` installed and authenticated
- Claude Desktop installed

## Setup

1. Install the helper:

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/datum-cloud/claude-code-plugins/main/claude-desktop/auth-helper.sh -o ~/.local/bin/datum-claude-auth-helper
chmod +x ~/.local/bin/datum-claude-auth-helper
```

2. Copy the absolute path to the helper script:

```bash
readlink -f ~/.local/bin/datum-claude-auth-helper
```

3. In Claude Desktop, enable Developer Mode if you haven't already: **Help → Troubleshooting → Enable Developer Mode**. Then open **Developer → Configure third-party inference**.

4. Set **Authentication** to **Helper script** and point it at the path from step 2.

5. Click **Test script** — it should produce a single line of stdout in under a second.

6. Click **Apply locally**. The app relaunches with the configuration active.

Base URL, provider, and any other fields are environment-specific — get those from your team's internal setup notes.

## How it works

The script augments `PATH` with common install locations (Claude Desktop launches with a minimal environment that doesn't include the user's shell PATH), then `exec`s `datumctl auth get-token`. Stdout is the bare token; nothing else is printed.

## Troubleshooting

| Symptom                     | Cause                                             | Fix                                                                                    |
| --------------------------- | ------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `datumctl not found`        | Not on the augmented PATH                         | Install via `brew install datum-cloud/tap/datumctl`, or symlink into `~/.local/bin/`   |
| `Output has multiple lines` | Something is printing to stdout besides the token | Re-run `datumctl auth login` and confirm `datumctl auth get-token` emits a single line |
