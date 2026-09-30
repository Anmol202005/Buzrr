# Buzrr — iOS App

A SwiftUI client for **Buzrr**, a live multiplayer quiz game. Players create a
guest profile, join a room with a short game code, answer timed questions, and
climb a live leaderboard through to a final results screen — all driven by a
real-time Socket.IO connection and a small REST API.

This directory contains the native iOS app. The web/backend monorepo lives in
[`../buzzr-web`](../buzzr-web).

---

## Table of contents

- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Project structure](#project-structure)
- [Architecture](#architecture)
- [App flow](#app-flow)
- [Networking (REST)](#networking-rest)
- [Realtime protocol (Socket.IO)](#realtime-protocol-socketio)
- [Session persistence](#session-persistence)
- [Assets](#assets)
- [Appearance](#appearance)
- [Conventions](#conventions)
- [Troubleshooting](#troubleshooting)

---

## Requirements

| Tool | Version |
| --- | --- |
| Xcode | 17 or newer |
| iOS deployment target | 26.5 |
| Swift | 5.0 (language mode) |
| Device family | iPhone + iPad |

Dependencies are resolved via Swift Package Manager:

- [`socket.io-client-swift`](https://github.com/socketio/socket.io-client-swift) `16.1.1`
- [`Starscream`](https://github.com/daltoniam/Starscream) `4.0.8` (transitive)

No CocoaPods, Carthage, or manual framework steps are required.

---

## Getting started

```bash
git clone <repo-url>
cd Buzrr
open Buzrr.xcodeproj
```

Then in Xcode:

1. Let Swift Package Manager resolve the two packages (Xcode does this automatically on open).
2. Pick the **Buzrr** scheme and an iOS Simulator (or device).
3. Run (`⌘R`).

From the command line:

```bash
xcodebuild -project Buzrr.xcodeproj \
  -scheme Buzrr \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug build
```

> The backend base URL is defined in `Networking/APIConfiguration.swift`.
> Point it at your own instance if you are not using the hosted one.

---

## Project structure

The project uses Xcode's **file-system synchronized groups** (`PBXFileSystemSynchronizedRootGroup`),
so the folder layout below *is* the project layout — moving files on disk is
automatically reflected in Xcode. There is no need to edit the `.xcodeproj` when
adding or moving sources.

```
Buzrr/
├── App/                        # App entry point + root flow
│   ├── BuzrrApp.swift          # @main App, injects GameClient
│   └── ContentView.swift       # Root router: onboarding → profile → room → game
│
├── Features/                   # Screen-level views, grouped by feature
│   ├── Onboarding/
│   │   ├── SubView.swift       # Onboarding slides carousel
│   │   ├── UsernameView.swift  # Name + avatar selection / profile creation
│   │   └── HorizontalImageView.swift  # Horizontal avatar picker
│   │
│   ├── Lobby/
│   │   ├── RoomCode.swift      # Enter game code + join
│   │   ├── GameLobby.swift     # Waiting room roster
│   │   └── VerticalListView.swift  # Player roster list
│   │
│   ├── Gameplay/
│   │   ├── LiveGameView.swift          # Question + answers + countdown
│   │   ├── AnswerSubmittedView.swift   # "Answer locked in" state
│   │   ├── QuestionResultsView.swift   # Reveal / distribution screen
│   │   └── LeaderboardView.swift       # Live leaderboard rows
│   │
│   └── Results/
│       └── GameOverView.swift  # Final leaderboard + score summary
│
├── Components/                 # Reusable, feature-agnostic UI
│   ├── ButtonComponent.swift   # Styled button
│   ├── NameInputView.swift     # Text field with underline + hint
│   ├── TimerComponent.swift    # Countdown display
│   └── KeyboardDismiss.swift   # `.dismissKeyboardOnTap()` view modifier
│
├── Models/                     # Domain / wire models
│   ├── GameSocketModels.swift  # GamePhase, PublicQuestion, payloads, roster, leaderboard
│   └── PlayerAvatar.swift      # Avatar index ↔ asset/server path mapping
│
├── Game/                       # Client-side game state
│   ├── GameClient.swift        # @Observable coordinator (session + API + socket)
│   └── GameSocketService.swift # Socket.IO connection + event mapping
│
├── Networking/                 # REST layer
│   ├── APIConfiguration.swift  # Base URL
│   ├── APIClient.swift         # Request builder/executor
│   ├── APIError.swift          # Typed errors + user-facing messages
│   ├── APIModels.swift         # Request/response DTOs
│   └── PlayerAPI.swift         # Endpoint methods
│
├── Session/
│   └── GuestSessionStore.swift # Guest identity persisted in UserDefaults
│
└── Assets.xcassets             # App icon, colors, image sets
```

### Where does a new file go?

- A **new screen or feature** → a subfolder under `Features/`.
- A **reusable view/widget** → `Components/`.
- A **wire model or value type** → `Models/`.
- A **new endpoint** → `Networking/` (add the DTO to `APIModels.swift`, the method to the relevant API type).
- **App-wide state** → `Game/`.

---

## Architecture

The app is a small, explicitly layered client with a single source of truth for
game state.

```
        ┌─────────────────────────────┐
        │          SwiftUI Views       │  Features/, Components/
        └──────────────┬──────────────┘
                       │ reads state / calls actions
        ┌──────────────▼──────────────┐
        │   GameClient  (@Observable)  │  Game/GameClient.swift
        └───────┬───────────────┬──────┘
                │               │
     ┌──────────▼─────┐  ┌──────▼────────────────┐
     │   PlayerAPI     │  │  GameSocketService     │
     │   (REST)        │  │  (Socket.IO)           │
     └──────────┬─────┘  └──────┬────────────────┘
                │               │
        ┌───────▼─────┐  ┌──────▼──────┐
        │  APIClient  │  │   Server    │
        └─────────────┘  └─────────────┘
```

- **`GameClient`** is the coordinator. It owns the `GuestSessionStore` and
  `GameSocketService`, exposes high-level actions (`createGuest`, `joinRoom`,
  `submitAnswer`, `leaveRoom`, `finishSession`, `changeProfile`), and is injected
  into the view tree as an environment value.
- **`GameSocketService`** owns the Socket.IO connection and translates raw
  server events into observable properties (`phase`, `question`, `players`,
  `leaderboard`, `you`, …). All mutations happen on the main actor via an
  `onMain` helper.
- **State observation** uses the Observation framework (`@Observable`,
  `@Environment(GameClient.self)`), not `ObservableObject`/`@Published`.
- **Views are thin.** They read state from the environment and call `GameClient`
  methods; almost no networking or business logic lives in views.

---

## App flow

`ContentView` is a router over the session and socket state:

1. **Restoring** — if a stored identity exists, `restoreSession()` re-hydrates the
   player and reconnects to any in-progress game (`isRestoring`).
2. **Onboarding** — first launch shows the `SubView` slide carousel (only once;
   the "seen intro" flag is persisted).
3. **Profile** — `UsernameView`: choose a display name and avatar, then
   `createGuest` registers an anonymous player.
4. **Room** — `RoomCode`: enter a game code to join. A back button clears the
   identity so the player can return and pick a name/avatar again.
5. **Game** — `GameFlow` renders a screen per server **phase**:

   | Phase | Screen |
   | --- | --- |
   | `lobby` | `GameLobby` (roster, waiting) |
   | `starting` | `GameLobby` with "starting" state |
   | `question` | `LiveGameView`, or `AnswerSubmittedView` once answered |
   | `reveal` | `QuestionResultsView` |
   | `final` / `ended` | `GameOverView` (final leaderboard) |

   A **final leaderboard** event and an explicit **game-over** event both lead to
   `GameOverView`.

---

## Networking (REST)

Base URL: `Networking/APIConfiguration.swift`.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `POST` | `players` | — | Create a guest player → `playerId` + `accessToken` |
| `PATCH` | `players/name` | — | Update a player's display name |
| `GET` | `players/{id}` | — | Fetch a player |
| `PATCH` | `players/{id}/clear-game` | — | Detach a player from their current game |
| `POST` | `game-sessions/join` | Bearer token | Join a room by `gameCode` |
| `GET` | `game-sessions/player-play/{playerId}` | — | Restore a player's current game |

Requests are built and executed by `APIClient`; failures are surfaced as
`APIError` with a user-facing `userMessage`.

---

## Realtime protocol (Socket.IO)

`GameSocketService` connects with the query params `userType=player` and
`gameCode`, plus an `Authorization: Bearer <token>` header, then listens for
server events and re-syncs on connect (`request-sync`).

**Client → server**

| Event | Payload | Notes |
| --- | --- | --- |
| `request-sync` | — | Ask for a full state snapshot (on connect / reconnect) |
| `submit-answer` | `{ qIndex, optionId }` | Expects an ack `{ accepted, reason }` |
| `leave-room` | — | Leave the current room |

**Server → client**

| Event | Effect |
| --- | --- |
| `state-sync` | Replaces phase, question, roster, leaderboard, and "you" state |
| `game-started` | Phase → `starting` |
| `question-start` | Phase → `question`; sets question, index, count, deadline |
| `question-end` | Phase → `reveal`; sets per-option counts + correct options |
| `answer-result` | Updates the player's score/correctness for the question |
| `leaderboard` | Updates the live leaderboard; a final one sets phase → `final` |
| `game-over` | Phase → `ended`; carries final entries + rating changes |
| `player-connection` | Updates a roster player's connected flag |
| `player-joined` / `player-left` / `player-removed` | Updates the roster |
| `game-session-ended` | Phase → `ended`; triggers session cleanup |

---

## Session persistence

`GuestSessionStore` stores the guest identity in `UserDefaults` under the
`buzrr.*` keys:

- `buzrr.playerId`, `buzrr.playerToken` — identity (determines `hasIdentity`)
- `buzrr.playerName`, `buzrr.playerProfile` — cached display data
- `buzrr.seenIntro` — whether the onboarding slides have been shown

The intro flag is intentionally **not** cleared when the identity is reset, so
onboarding never reappears after the first run.

---

## Assets

Everything lives in `Assets.xcassets`:

- `AppIcon` — app icon (single 1024×1024 image; must match the size declared in `Contents.json`).
- `AccentColor`, `ButtonColor` — palette.
- Image sets for the logo, onboarding slides, lobby/join art, and player avatars (`profile1`–`profile12`).

`PlayerAvatar` centralizes avatar resolution so views can map a server
`profilePic` value to a bundled asset name (with a fallback).

---

## Appearance

The app is **locked to light mode** via `INFOPLIST_KEY_UIUserInterfaceStyle = Light`
in the target's build settings. It renders identically in light and dark system
settings by design.

---

## Conventions

- **File headers:** every Swift file starts with the standard header block:
  ```swift
  //
  //  FileName.swift
  //  Buzrr
  //
  //  Created by Anmol Sharma on 28/09/26.
  //
  ```
- **Comments:** the codebase is intentionally comment-light; prefer clear names
  and small types over inline commentary.
- **State:** use `@Observable` + `@Environment`, not `ObservableObject`.
- **Concurrency:** UI types are main-actor isolated (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`).

---

## Troubleshooting

- **App icon build error** ("… did not have any applicable content"): the icon PNG's
  pixel size must match the `size` declared in
  `Assets.xcassets/AppIcon.appiconset/Contents.json` (1024×1024).
- **Stale errors in the Xcode editor** while the command-line build passes: clear
  `~/Library/Developer/Xcode/DerivedData/Buzrr-*` and reopen Xcode.
- **Won't reconnect to a game:** identity restoration runs via
  `GET game-sessions/player-play/{playerId}`; a `404` clears the stored session.
