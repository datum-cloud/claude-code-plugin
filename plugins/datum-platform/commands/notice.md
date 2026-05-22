Update the NOTICE file in the root of this repository with current dependency license information.

## Steps

1. **Detect the project language** by inspecting the repository root for language-specific files:
   - `go.mod` → Go
   - `requirements.txt`, `pyproject.toml`, `setup.py`, `setup.cfg`, `Pipfile` → Python
   - `package.json` → Node.js / JavaScript / TypeScript
   - `Cargo.toml` → Rust
   - Multiple detected → handle each, or pick the dominant one

2. **Generate license data using the preferred tool for the language**, falling back to manual extraction if the tool is unavailable:

   ### Go
   - **Preferred:** `go-licenses` ([github.com/google/go-licenses](https://github.com/google/go-licenses))
     ```
     go install github.com/google/go-licenses@latest
     go-licenses report ./... --template /dev/stdin
     ```
     Use `go-licenses report ./... 2>/dev/null` to get a CSV of `package,url,license_type`.
     If go-licenses is already installed (`which go-licenses`), use it directly.
   - **Fallback:** Parse `go.mod` to enumerate direct dependencies, then fetch license info from each module's source via `go mod download -json` and inspect the license file in the module cache (`$(go env GOMODCACHE)`).

   ### Python
   - **Preferred:** `pip-licenses` (`pip install pip-licenses`)
     ```
     pip-licenses --format=plain-vertical --with-license-file --no-license-path
     ```
   - **Fallback:** Parse `requirements.txt` or run `pip list --format=json` and use `importlib.metadata` to extract license classifiers from each package's metadata.

   ### Node.js / JavaScript / TypeScript
   - **Preferred:** `license-checker` (`npx license-checker --summary`)
     ```
     npx license-checker --production --json
     ```
   - **Fallback:** Parse `package.json` dependencies, look up each in `node_modules/<pkg>/package.json` for the `license` field, and read any `LICENSE` file present.

   ### Rust
   - **Preferred:** `cargo-about` (`cargo install cargo-about`)
     ```
     cargo about generate --format json
     ```
   - **Fallback:** Parse `Cargo.lock` to enumerate dependencies, then inspect each crate's `LICENSE` file in the cargo registry cache (`~/.cargo/registry/src`).

   ### Unknown / Polyglot
   - Scan the repo for `LICENSE`, `LICENSE.txt`, `LICENSE.md`, `COPYING` files in subdirectories under `vendor/`, `third_party/`, or similar.
   - If nothing automated is possible, state clearly in the NOTICE what could not be determined automatically and ask the user to fill it in.

3. **Write the NOTICE file** to the repository root. Use this format:

```
NOTICES FOR THIRD-PARTY SOFTWARE

This product includes software developed by third parties.
The following components are included in this distribution:

================================================================================
{Dependency Name} {Version}
{License Type}
{Source URL or package path}
--------------------------------------------------------------------------------
{Full license text or "See: {URL}" if text is not available locally}

================================================================================
... (repeat for each dependency)
================================================================================

END OF NOTICES
```

   Rules:
   - Sort dependencies alphabetically by name.
   - Include only production/runtime dependencies — skip test-only and dev dependencies unless the project is a library.
   - If a dependency has no detectable license, flag it with `LICENSE: UNKNOWN — manual review required`.
   - Do not truncate license text. If it's long, include it in full.
   - Preserve any existing header comment at the top of the NOTICE file (e.g., the project's own copyright line), if one exists.

4. **Report what was done**: After writing the file, summarize:
   - How many dependencies were processed
   - Which tool was used (or if fallback was used and why)
   - Any dependencies with unknown or missing licenses that need manual attention
   - Any errors encountered
