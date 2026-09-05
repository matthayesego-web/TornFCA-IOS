# TornFCA Faction Premium Contract

Status: shared cross-platform product/backend contract — 2026-09-05

## Entitlement model

- **Personal Premium** is keyed to verified Torn `player_id` and follows the player between factions.
- **Faction Premium** is keyed to Torn `faction_id` and stays with the faction regardless of who paid.
- A player may have neither, Personal only, Faction through their current faction only, or both.
- Neither subscription grants Torn leadership permissions; real Torn permissions remain authoritative.

## Pricing

- Personal Premium: **1 Xanax = 7 days**, stacking enabled.
- Faction Premium: **1 Erotic DVD (EDVD; item ID 366) = 7 days**, stacking enabled.
- 4 EDVD = 28 days; 8 EDVD = 56 days.
- Multiple people can contribute to the same faction expiry.

## Faction payment attribution

- Faction Premium belongs to `faction_id`, not payer ID.
- If the payer leaves, the faction keeps the purchased time.
- Default `TORNFCA` EDVD payment applies to the sender's current verified faction.
- Explicit sponsorship is supported/reserved as `TORNFCA FACTION <faction_id>`; a valid explicit target takes priority over current-faction inference.
- Entitlements are server-authoritative and receipt processing must be replay-safe.

## Founder

**Beta Founder grants lifetime Personal Premium only.** It never grants lifetime Faction Premium to a faction the Founder joins.

## Product boundary

### Personal Premium
Personal Insights, personal trend/history depth, Training Goal Pacing, Smart Alerts, personal saved views/filters, personal WarPay receipt analytics, personalization/cosmetics and similar player-scoped convenience.

### Faction Premium
Shared faction operations such as 30-day leadership Activity Tracker, Faction Pulse, advanced Member Dossier aggregation, shared WarPay presets/history/exports, extended Armory history, Banking reconciliation/history, Leadership Attention shared/custom rules, OC/chain exception workflows, shared dashboards/templates and later enhanced faction/Discord integrations.

Free retains useful core participation and essential leadership functionality; Premium deepens workflows rather than removing basic access.

## Backend status

Canonical/live deployment target remains Premium backend **v1.6.1** for now.

A **v1.7.0 candidate** has been prepared and syntax-validated to add faction-scoped entitlement storage, EDVD payment stacking, independent monetization gates, current-faction attribution, explicit sponsorship, and authenticated `faction_entitlement` / `faction_offer` response fields.

**v1.7.0 is not deployed yet.** Do not represent Faction Premium payment processing as live until the shared backend is deliberately updated and verified.

## iOS implementation

When iOS consumes the new model:
- keep Personal and Faction entitlement state separate;
- resolve Faction Premium against the authenticated player's current faction;
- never mint/extend either entitlement locally;
- keep Torn permission checks separate from subscription checks;
- make UI copy clear: Personal follows the player, Faction follows the faction.
