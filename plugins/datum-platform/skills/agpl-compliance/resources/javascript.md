# JavaScript / TypeScript — AGPL-3.0 Compliance Rules

## File Extensions in Scope
`.js`, `.jsx`, `.ts`, `.tsx`

## Skip Rules

### Directories — always skip entirely
- `node_modules/`
- `dist/`, `build/`, `.next/`, `out/` — bundler output
- `.cache/`

### Auto-generated files — skip if first 3 lines contain
- `// @generated`
- `// This file is auto-generated`
- `/* eslint-disable */` combined with a generation comment

### Protobuf/gRPC generated files
- `*_pb.js`, `*_pb.ts`, `*_pb.d.ts`
- `*_grpc_web_pb.js`

### Config files — skip by filename pattern
- `vite.config.*`
- `next.config.*`
- `tailwind.config.*`
- `postcss.config.*`
- `jest.config.*`
- `babel.config.*`
- `eslint.config.*`, `.eslintrc.*`, `.eslintrc.js`, `.eslintrc.cjs`
- `prettier.config.*`, `.prettierrc.*`
- `webpack.config.*`
- `rollup.config.*`
- `tsconfig*.json` (not a source file)

## Header Placement
Must appear at the very top of the file.

**Exception**: `'use strict';` or `"use strict";` may appear before the header if already
present in the file — flag as advisory to move it after the header.

For `.tsx`/`.jsx` files, the header goes before any `import` statements.

## Correct Header
```js
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
