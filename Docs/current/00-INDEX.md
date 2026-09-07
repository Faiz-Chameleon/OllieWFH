# Docs Index — trust this first

**Last updated:** 2026-09-08

This index points at what is current. When two documents disagree, the one listed
here wins. Superseded docs are moved to `Docs/archive/` — never deleted.

---

## Start here

| Doc | What it covers | Status |
|---|---|---|
| [`../SESSION_2026-09-08.md`](../SESSION_2026-09-08.md) | **Most recent session.** Auth-flow back buttons + signup password toggles, disk-full build fix, and the live `api.theollie.app` DNS outage. Has a "Resume Here" list. | ✅ Current |

## Open items requiring action

| Item | Where | Severity |
|---|---|---|
| `api.theollie.app` DNS record missing (`NXDOMAIN`) — app fully down; TLS cert expires **2026-09-21** | `SESSION_2026-09-08.md` §3 | 🔴 Blocking (external — backend/infra team) |
| 13 auth-flow files uncommitted on `main` | `SESSION_2026-09-08.md` §1 | 🟡 Needs commit on a branch |
| `lib/CareCircle/groups/group_chat_screen.dart` — ~809 lines uncommitted, undocumented, predates this session | `SESSION_2026-09-08.md` working-tree section | 🟡 Needs a decision |
| `mime` used but not declared in root `pubspec.yaml` | `SESSION_2026-09-08.md` Resume Here #4 | 🟢 One-line fix |
| AGP 9 / `android.newDsl` migration | `SESSION_2026-09-08.md` Resume Here #4 | 🟢 Pre-emptive |
| Nested `Ollie-frontend-main/` duplicate copy — did not receive this session's changes | `SESSION_2026-09-08.md` Resume Here #4 | 🟢 Needs a decision |

---

## Project facts worth knowing

- **Package name:** `ollie` — Flutter app, GetX state management.
- **API base:** `https://api.theollie.app/api/v1` (`lib/app_urls.dart:7`).
- **Backend:** Node/pm2 process `ollie-backend` on VPS `187.77.111.201` (srv1526101, Ubuntu 24.04.4), behind nginx on the `api.theollie.app` vhost. DNS zone at mysecurecloudhost.com (`ns1`–`ns4`).
- **Gradle:** wrapper pinned to **8.12** (`android/gradle/wrapper/gradle-wrapper.properties`).
- **Formatting:** `dart.lineLength: 150` (`.vscode/settings.json`), but **most files are not actually formatted to it**. Do not run a blanket `dart format` — it produces hundreds of lines of unrelated churn. Format only what you touch, by hand.
- **Shared UI widgets** live in `lib/common/common.dart`: `CustomTextField`, `CustomButton`, `AuthBackButton`, `customInputDecoration`, `appSnackbar`.
- **Auth screen layout convention:** no `AppBar`. Every screen is `Scaffold → Stack → Container(color: BGcolor) → Positioned(bottom: background image) → SingleChildScrollView`. `AuthBackButton` goes in as the **last** `Stack` child.
- **Auth navigation:** `Login_Screen` is always the stack root (reached via `Get.offAll`). `CreateProfileScreen` is reachable both via `Get.to` (from OTP) and `Get.offAll` (from `login_controller.dart:375`, incomplete profile) — which is why `AuthBackButton` self-hides when there is nothing to pop.

## Pre-existing docs (root, not yet triaged)

These predate the `Docs/` system and were all committed together in `e6183d5`. Treat as
historical reference — accuracy against current code is unverified.

`IMPLEMENTATION_SUMMARY.md` (ElevenLabs TTS), `ELEVENLABS_TTS_SETUP.md`,
`ELEVENLABS_WEBSOCKET_SETUP.md`, `CONVERSATIONAL_AI_SETUP.md`,
`COMMENT_SYSTEM_README.md`, `GETX_COMMENT_SYSTEM_README.md`, `README.md`
