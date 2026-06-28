# Conduit (Modern iOS OpenWebUI Client)

<!-- THOX-BADGES:START -->
[![Repository](https://img.shields.io/badge/repository-ttracx/nellie--webui--ios-0B1220)](https://github.com/ttracx/nellie-webui-ios)
![THOX.ai LLC](https://img.shields.io/badge/owner-THOX.ai%20LLC-00A676)
![Visibility](https://img.shields.io/badge/visibility-public-00A676)
![Leadership](https://img.shields.io/badge/CTO-Tommy%20Xaypanya-1F6FEB)
![Leadership](https://img.shields.io/badge/CEO-Craig%20Ross-6F42C1)
<!-- THOX-BADGES:END -->


Conduit is a modern SwiftUI iOS client for OpenWebUI with support for:
- Streaming chat via `/api/chat/completions` (SSE)
- Model listing from `/api/models`
- Notes + Memory views via OpenWebUI endpoints
- Tool/Function catalog view
- Session sign-in (`/api/v1/auths/signin`) and token persistence
- Image attachment upload for chat (OpenWebUI file endpoints)
- VibeCaaS branding with Light, Dark, and High-Contrast themes

## Architecture
- SwiftUI + `@Observable` state containers
- `async/await` networking with typed models
- Feature-first folder layout
- Fallback endpoint strategy for OpenWebUI version differences

## Generate Xcode Project
This repo uses `xcodegen`.

```bash
brew install xcodegen
cd conduit
xcodegen generate
open Conduit.xcodeproj
```

## Configure OpenWebUI
In app Settings:
- Base URL: e.g. `http://100.105.6.57:3001`
- API Key (optional when signed in)
- Sign in with email/password (if auth enabled)

Conduit sends:
- `Authorization: Bearer <token-or-key>`
- `X-API-Key: <token-or-key>`

## Branding: VibeCaaS Theme
- Primary: `#6D4AFF` (Vibe Purple)
- Secondary: `#14B8A6` (Aqua Teal)
- Accent: `#FF8C00` (Signal Amber)
- Theme modes: `System`, `Light`, `Dark`, `High Contrast`
- Typography hooks:
  - Sans/UI: `Inter`
  - Mono: `JetBrainsMono-Regular`

If these fonts are not bundled in the app target, iOS falls back to system fonts.

## Notes
- This environment cannot run Xcode (`xcodebuild` is unavailable on Linux), so compile/run on macOS.
- Endpoint paths vary by OpenWebUI version; Conduit includes fallbacks for notes/memory/tools/upload routes.

<!-- THOX-DOCS-STANDARD:START -->
## Repository Description

Nellie WebUI iOS client with modern OpenWebUI features

## Documentation

- [Repository documentation](docs/README.md)
- [Security policy](SECURITY.md)
- [Contributing guide](CONTRIBUTING.md)
- [Legal notice](NOTICE.md)

## THOX.ai LLC

This repository is maintained by THOX.ai LLC.

- Tommy Xaypanya is CTO.
- Craig Ross is CEO.

## Copyright and Legal

Copyright (c) 2026 THOX.ai LLC. All rights reserved unless this repository includes a separate license file that states otherwise.

THOX-specific documentation, configuration, branding, product definitions, and integration work are owned by THOX.ai LLC unless explicitly noted. Third-party dependencies, forks, vendored components, and upstream source materials remain governed by their original licenses and notices.
<!-- THOX-DOCS-STANDARD:END -->
