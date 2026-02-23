# Conduit (Modern iOS OpenWebUI Client)

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
