# Nellie WebUI iOS - Agent Issue Backlog

Use these as copy/paste GitHub issues or direct coding-agent prompts. Each item includes a clear done definition.

## 1) Integrate Brand Fonts (Inter + JetBrains Mono)
Prompt:
`Add Inter and JetBrains Mono font assets to the iOS target, register them in Info.plist (UIAppFonts), and replace remaining system-font fallbacks in branded screens.`

Acceptance Criteria:
- Inter and JetBrains Mono files are committed under app assets.
- `Info.plist` includes all registered font filenames.
- Chat, Settings, Notes, Memories, and Tools render brand fonts on device.
- No missing-font runtime warnings.

Labels:
- `ios`
- `design-system`
- `branding`

## 2) Global Visual QA and Token Alignment
Prompt:
`Run a visual consistency pass across all tabs and reusable components. Normalize spacing, corner radii, stroke weight, typography scale, and gradient usage to the VibeCaaS token system.`

Acceptance Criteria:
- Spacing/radii are consistent across cards, inputs, and buttons.
- Borders and text colors remain legible in Light/Dark/HC.
- Gradient appears in intended hero/CTA surfaces only.

Labels:
- `ios`
- `ui-polish`
- `branding`

## 3) Accessibility Compliance Pass
Prompt:
`Implement accessibility hardening for VoiceOver, Dynamic Type, contrast checks, reduced motion behavior, and touch target size.`

Acceptance Criteria:
- Interactive elements have accessibility labels/hints where needed.
- Layout remains usable with larger text sizes.
- Theme switching preserves readable contrast.
- Reduced-motion preference minimizes animation duration.

Labels:
- `ios`
- `accessibility`

## 4) Chat UX Completion
Prompt:
`Enhance chat interactions with timestamp display, streaming status indicator, cancel-generation action, and retry/resend for failed sends, while preserving current OpenWebUI streaming behavior.`

Acceptance Criteria:
- User can cancel an active generation.
- Failed assistant responses can be retried.
- Message metadata (timestamps) is visible but unobtrusive.
- No regression in SSE streaming flow.

Labels:
- `ios`
- `chat`
- `ux`

## 5) Notes and Memory CRUD
Prompt:
`Implement create/edit/delete flows for Notes and Memories (based on available OpenWebUI endpoints), with optimistic updates and rollback on API failure.`

Acceptance Criteria:
- Create/edit/delete UI exists for Notes and Memories.
- Successful actions update UI immediately.
- Failures show clear inline error and revert local optimistic state.

Labels:
- `ios`
- `feature`
- `notes`
- `memory`

## 6) Tools Detail Screen
Prompt:
`Add a Tool detail screen that shows full description, parameter schema, and copy actions for IDs/snippets. Keep style aligned with VibeCaaS tokens.`

Acceptance Criteria:
- Tapping a tool opens a detail view.
- Long descriptions and schemas render safely and readably.
- Copy action provides visible confirmation.

Labels:
- `ios`
- `tools`
- `feature`

## 7) Settings Validation and Error UX
Prompt:
`Add strong validation for Base URL/API key/session fields and improve inline feedback for sign-in and connection issues.`

Acceptance Criteria:
- Invalid URLs are blocked with actionable messages.
- Sign-in state and errors are explicit.
- Save/update actions avoid silent failures.

Labels:
- `ios`
- `settings`
- `ux`

## 8) Offline, Empty, and Failure States
Prompt:
`Standardize offline/empty/error states across all tabs, including retry buttons and consistent branded visuals.`

Acceptance Criteria:
- Each tab has explicit empty and error handling.
- Retry action is available where network calls fail.
- State components use shared visual style.

Labels:
- `ios`
- `resilience`
- `ux`

## 9) Test Coverage (Unit + UI Smoke)
Prompt:
`Add targeted unit tests for API parsing/auth/session flows and UI smoke tests for theme switching + primary navigation.`

Acceptance Criteria:
- Unit tests cover model parsing and auth token handling.
- UI smoke tests verify app launch, tab navigation, and theme mode switch.
- CI/local test command and expected output documented.

Labels:
- `ios`
- `testing`

## 10) Build, Assets, and Release Readiness
Prompt:
`Prepare app for release: app icon/splash polish, build warning cleanup, and TestFlight readiness checklist.`

Acceptance Criteria:
- App icon and launch assets are present and branded.
- No high-priority build warnings.
- Release checklist exists and is complete.

Labels:
- `ios`
- `release`
- `branding`

## 11) Documentation and Operator Runbook
Prompt:
`Expand README/runbook with setup, OpenWebUI endpoint compatibility notes, theme behavior, troubleshooting, and screenshots for Light/Dark/HC.`

Acceptance Criteria:
- Setup steps are reproducible from clean environment.
- Endpoint fallback behavior is documented.
- Screenshots for all theme modes are included or tracked with follow-up.

Labels:
- `docs`
- `ios`

## 12) Final Integration + Ship Commit
Prompt:
`Run final QA checklist, resolve blockers, and produce a release summary with known limitations and follow-up items.`

Acceptance Criteria:
- Final QA checklist is completed.
- Final commit(s) are pushed to `main`.
- Release notes include known limitations and next actions.

Labels:
- `release`
- `qa`
- `ios`
