# TornFCA shared-platform handoff — 2026-09-05

This repo note carries shared backend decisions from the platform coordination work.

## Founder contract

- Founder status is earned only through an explicitly authorized Android, iOS or Web beta grant.
- Discord testing never qualifies.
- Once legitimately granted, Founder is account-level lifetime **Personal Premium** across TornFCA.
- Android/iOS native auto-claim is allowed only for authenticated explicit pre-1.0 native clients while the Founder program is open and that platform cap has capacity.
- Web never auto-claims Founder; Web grants are owner-only manual grants for approved Web beta testers.
- Current configured caps observed: Android 20, iOS 20, Web 10.
- Founder does **not** grant Faction Premium.

## Premium backend

Canonical shared Premium backend remains **v1.6.1** in `matthayesego-web/Android-app` `development`, path `backend/TornFcaPremiumBackend.gs`, until a later candidate is deliberately promoted/deployed.

v1.6.1 hardens Founder duplicate prevention/counting and server authority.

## Faction Premium addendum

Read `FACTION_PREMIUM_CONTRACT.md`.

- Personal Premium: player-scoped, **1 Xanax = 7 days**.
- Faction Premium: faction-scoped, **1 EDVD = 7 days**.
- Multiple payers stack on the same faction expiry; 4 EDVD = 28 days, 8 = 56 days.
- Paid faction time stays with the faction if payer leaves.
- Default EDVD target is sender's verified current faction; explicit sponsorship uses `TORNFCA FACTION <faction_id>`.
- Faction Premium never grants Torn leadership permissions.

A Premium backend **v1.7.0 candidate** is prepared/syntax-validated for this model but is **not deployed yet**.

## iOS implementation requirement

When iOS Premium support is implemented:
- send `platform=iOS` and the real app version/version code for Founder checks;
- use shared backend Personal entitlement rather than minting locally;
- prepare separate Faction Premium state resolved from the authenticated player's current faction;
- do not collapse Personal/Faction states into one generic Premium boolean;
- keep Torn permission checks independent from subscription state;
- make UI language clear: Personal follows the player, Faction follows the faction;
- do not advertise live EDVD activation until deployed backend capability verifies it.

No separate iOS Founder/Premium database should be created.
