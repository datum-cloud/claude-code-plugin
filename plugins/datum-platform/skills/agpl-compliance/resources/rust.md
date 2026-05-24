# Rust — AGPL-3.0 Compliance Rules

## File Extensions in Scope
`.rs`

## Skip Rules
- Files under `target/`
- `build.rs` if it contains only auto-generated scaffold (no substantive logic)
- Protobuf-generated files: `*.pb.rs`, files under `src/gen/` or `src/generated/`
- Files under `vendor/` or `third_party/`

## Header Placement
Must appear at the very top of the file — before any `use`, `mod`, `extern crate`, or
attribute declarations (`#![...]`).

**Exception**: Inner crate-level attributes (`#![allow(...)]`, `#![cfg_attr(...)]`) may
appear before the header if the project convention requires it, but this should be flagged
as advisory — the preferred order is header first.

## Correct Header
```rust
// Copyright (C) <YEAR> <AUTHOR/ORG>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
```

## Detection Markers
To quickly scan whether a file has the correct header, check the first 30 lines for:
- `GNU Affero General Public License`
- `https://www.gnu.org/licenses/`
- A `Copyright` line with a year and author
