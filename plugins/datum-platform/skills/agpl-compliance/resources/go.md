# Go — AGPL-3.0 Compliance Rules

## File Extensions in Scope
`.go`

## Skip Rules
- Files starting with `// Code generated` or `// DO NOT EDIT` in the first 3 lines
- Protobuf-generated files: `*.pb.go`, `*_grpc.pb.go`
- Files under `vendor/`

## Header Placement
Must appear at the very top of the file — before the `package` declaration.

**Exception**: `//go:build` and `// +build` constraint lines may appear before the header.
Place the header immediately after any build constraints.

Example with build constraint:
```go
//go:build linux

// Copyright (C) <YEAR> <AUTHOR/ORG>
//
// ...license text...

package foo
```

## Correct Header
```go
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
