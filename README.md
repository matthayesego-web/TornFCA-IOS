# TornFCA iOS

Native iOS companion for the TornFCA platform.

## Status

Early foundation work only. Android remains the current reference implementation and product specification. The iOS client should mirror Android feature behavior, permissions, terminology and backend contracts as closely as Apple platform conventions allow.

Current bootstrap version: **0.1.0-dev**

## Branch policy

- `main` — future App Store-ready source. Do not develop directly here.
- `development` — accepted next-version iOS development source.
- `work/*` — implementation branches.
- `restore/*` — recovery snapshots before risky changes.

## Initial architecture

- SwiftUI app shell
- iOS 17+
- XcodeGen project definition (`project.yml`)
- GitHub Actions simulator compile gate
- Torn API v2 client using `Authorization: ApiKey ...`
- API key stored only in Keychain
- Shared feature homes matching Android: Home / Faction / War / Leadership / More
- Permission model keeps Premium and faction authority separate

## Product rules inherited from TornFCA

- Premium never grants faction authority.
- Leadership access must come from verified Torn/backend permissions.
- TornFCA never automates attacks.
- TornFCA never automatically moves faction money.
- Never pool keys to evade Torn rate limits.
- Never commit API keys, backend secrets, signing credentials or private tokens.
- Unknown WAR//OS history remains unknown; never invent certainty.

## Generate the Xcode project

```bash
brew install xcodegen
xcodegen generate
open TornFCA.xcodeproj
```

The generated `.xcodeproj` is intentionally not the source of truth; `project.yml` and `Sources/` are.
