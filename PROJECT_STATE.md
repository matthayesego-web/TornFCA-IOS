# TornFCA iOS Project State

Last updated: 2026-08-31

## Current milestone

**v0.1.0-dev — platform bootstrap**

The repository was empty except for `.gitignore`. Android is the canonical feature reference while iOS catches up gradually.

## Branches

- `main`: untouched initial repository baseline / future App Store-ready source
- `development`: accepted iOS development line
- `work/ios-bootstrap-v0.1.0`: first implementation branch

## Implemented foundation

- SwiftUI application shell.
- Secure API-key flow using Keychain.
- Torn API v2 `/user/basic` verification.
- Root navigation modeled after Android.
- Feature-home cards for the current Android information architecture.
- Leadership tab hidden unless verified authority is eventually supplied by the permission layer.
- CI configuration for a no-signing iOS Simulator compile using XcodeGen.

## Android parity map

### Home
- My Day
- Training & Progress
- Notification Inbox

### Faction
- Faction Chat
- Announcements
- Overview & Directory
- Resources
- Faction Tools
- Voting

### War
- Ranked War / WAR//OS
- Chain Status
- Territories
- My War Prep

### Leadership
- Needs Attention
- People & Activity
- War & Intel
- Finance & Assets
- Faction Admin

### More
- Settings
- Notification Inbox
- Premium
- Feedback & Requests
- Legal & Privacy
- About

## Next implementation order

1. Faction identity + delegated permission resolution.
2. Shared backend configuration/client layer.
3. Home and Faction read-only data.
4. War + chain data and WAR//OS device-first logic.
5. TornFCA native community chat.
6. Banking shared queue.
7. Notifications / Live Activities where appropriate.
8. Premium / Beta Founder entitlement parity.
9. Feedback and tester status.
10. App Store/TestFlight packaging when hardware/account access is available.

Do not claim a feature is implemented merely because its destination exists in the scaffold.
