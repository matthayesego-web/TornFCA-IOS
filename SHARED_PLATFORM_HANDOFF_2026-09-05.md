# TornFCA shared-platform handoff — 2026-09-05

This repo note carries shared backend decisions from the platform coordination work.

## Founder contract

- Founder status is earned only through an explicitly authorized Android, iOS or Web beta grant.
- Discord testing never qualifies.
- Once legitimately granted, Founder is account-level lifetime Premium across TornFCA.
- Android/iOS native auto-claim is allowed only for authenticated explicit pre-1.0 native clients while the Founder program is open and that platform cap has capacity.
- Web never auto-claims Founder; Web grants are owner-only manual grants for approved Web beta testers.
- Current configured caps observed: Android 20, iOS 20, Web 10.

## Premium backend

Canonical shared Premium backend has advanced to **v1.6.1** in `matthayesego-web/Android-app` `development`, path `backend/TornFcaPremiumBackend.gs`.

v1.6.1 hardens duplicate prevention/counting:
- unique Torn player IDs count toward caps, not raw rows;
- cap checks happen inside the same ScriptLock as claim append;
- Special Thanks output is deduplicated;
- owner-only Founder registry repair is available.

## iOS implementation requirement

When iOS Founder support is implemented:
- send `platform=iOS`;
- send the real pre-1.0 app version/version code;
- use the shared Premium status endpoint and shared account entitlement;
- never mint Founder locally;
- avoid overlapping status requests where practical;
- preserve server authority for caps and Founder eligibility.

No separate iOS Founder database should be created.
