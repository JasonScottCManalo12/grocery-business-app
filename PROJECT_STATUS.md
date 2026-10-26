# Grocery Business App — Project Status

**Last reviewed:** 2026-10-26  
**Repository:** [JasonScottCManalo12/grocery-business-app](https://github.com/JasonScottCManalo12/grocery-business-app)  
**Default branch:** `main`

> This file is the project's current status and working checklist. Update it when a milestone is supported by repository code, tests, or other verifiable evidence. A successful build confirms packaging—not that grocery features are implemented.

## 1. Project direction

The Grocery Business App is **one shared business ecosystem** with specialized interfaces for:

- Customer
- Owner / Boss
- POS / Staff
- Financial Reports / Accounting
- Compliance
- Inventory & Purchasing
- Payments & Settlement

These interfaces should use consistent shared records for products, transactions, customer IDs, inventory, permissions, and audit trails. The separate MLM App is outside this repository and project scope.

### Delivery priorities

1. Android APK
2. Web
3. Desktop

### MVP approach

- Phase 1: simple, traditional grocery operations first.
- Flutter / Dart, Android-first.
- Local SQLite and offline-first operation for one device / one shop.
- Advanced crypto modules must not delay the ordinary grocery MVP.

## 2. Current verified status

| Area | Status | Evidence / notes |
|---|---|---|
| GitHub repository | **Available** | This repository; default branch `main`. |
| Android CI workflow | **Implemented** | [Build workflow](.github/workflows/build-android.yml). |
| Recorded Android workflow run | **Passed (historical)** | [GitHub Actions runs](https://github.com/JasonScottCManalo12/grocery-business-app/actions). The latest run observed during the 2026-10-26 status review was successful on 2026-10-12. |
| Current downloadable APK artifact | **Not verified / unavailable** | No retained artifact was reported for the latest observed run. The workflow config sets artifact retention to 14 days, so an expired artifact does not mean the build failed. Run the workflow again to produce a fresh artifact. |
| Grocery product and inventory features | **Not implemented / not verified** | The last inspected `lib/main.dart` was still the default Flutter counter demo. |
| Offline POS and sales recording | **Not implemented / not verified** | No verified grocery POS implementation yet. |
| SQLite persistence | **Not implemented / not verified** | No verified grocery database implementation yet. |
| Automated feature tests | **Not verified** | The workflow runs `flutter test`; a successful historical workflow does not prove unimplemented grocery features work. |
| Web and desktop delivery | **Not started** | Prioritize after the Android MVP according to the delivery order. |
| Crypto-related modules | **Deferred** | Do not let these block the traditional grocery MVP. |

**Baseline commit observed during review:** `df7a6c50d90b0263f964d1f3bac011ce745907bb` — “Add GitHub Actions Android APK build” (2026-10-12). This is a historical reference; check the live branch and Actions page for newer changes.

## 3. Master checklist

Status meanings: **Not started** = no verified implementation; **In progress** = implementation underway; **Blocked** = cannot proceed pending a dependency; **Completed** = implemented and verified with evidence.

### Milestone 0 — Project foundation

- [x] GitHub repository exists.
- [x] Android APK build workflow is configured.
- [x] Workflow supports pushes to the main branches, pull requests, and manual runs.
- [ ] Re-run the workflow and confirm a fresh APK artifact is available.
- [ ] Confirm the current branch's Flutter analysis and tests pass.

### Milestone 1 — Traditional grocery MVP (Android-first)

- [ ] Define and implement the grocery home/navigation screen.
- [ ] Product catalogue: create, view, edit, and deactivate products.
- [ ] Inventory quantity and stock adjustments.
- [ ] Offline SQLite database and persistence.
- [ ] POS cart: add/remove items and change quantities.
- [ ] Calculate subtotal, totals, payment received, and change.
- [ ] Complete a sale and save a transaction record.
- [ ] Basic receipt / transaction history.
- [ ] Basic low-stock visibility.
- [ ] Validate core flows with automated tests and a real-device APK.

### Milestone 2 — Operational safeguards

- [ ] Validate inputs and prevent invalid quantities/prices.
- [ ] Add reliable transaction IDs and timestamps.
- [ ] Add backup / restore strategy appropriate for a single offline device.
- [ ] Record stock changes and sales consistently.
- [ ] Review error handling and data integrity.

### Milestone 3 — Shared ecosystem expansion

- [ ] Customer accounts and buyer categories, when scheduled for implementation.
- [ ] Owner / boss interface and permissions.
- [ ] Staff roles and access controls.
- [ ] Financial reports / accounting.
- [ ] Purchasing and supplier workflows.
- [ ] Payment and settlement workflows.
- [ ] Compliance records and audit trails.

### Milestone 4 — Later delivery targets

- [ ] Web version after the Android MVP.
- [ ] Desktop version after web.
- [ ] Evaluate and schedule crypto checkout, sponsorship/funding, buyer accounts, and Simple Earn modules only after the ordinary MVP is stable.

## 4. Next recommended actions

1. Inspect the current `main` branch before making implementation changes.
2. Re-run **Build Grocery Business App APKs** and confirm the run, tests, and fresh APK artifact.
3. Replace the default counter demo with the first small grocery milestone: product catalogue and local persistence.
4. Update this checklist only when the repository contains evidence for the changed status.

## 5. Evidence and working links

- [Repository](https://github.com/JasonScottCManalo12/grocery-business-app)
- [Android build workflow](.github/workflows/build-android.yml)
- [GitHub Actions runs and artifacts](https://github.com/JasonScottCManalo12/grocery-business-app/actions)
- [Source code](https://github.com/JasonScottCManalo12/grocery-business-app/tree/main/lib)

## 6. Update protocol

For each meaningful milestone:

1. Discuss and agree on the scope before making changes.
2. Implement the agreed change.
3. Run the relevant tests/build and inspect the actual result.
4. Update this file with the status, verification date, and evidence link.
5. Record important architecture decisions in the repository documentation when appropriate.

Keep this file concise enough to serve as the current dashboard. Use commit history, pull requests, workflow runs, and code for detailed evidence. Do not mark a feature complete merely because a plan exists or an APK builds.
