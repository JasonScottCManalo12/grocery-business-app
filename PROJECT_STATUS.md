# Grocery Business App — Project Status

**Last reviewed:** 2026-10-27  
**Repository:** `JasonScottCManalo12/grocery-business-app`  
**Default branch:** `main`

> This file is the project's current status and working checklist. Update it when a milestone is supported by repository code, tests, or other verifiable evidence. A successful build confirms packaging—not that grocery features are implemented.

## 1. Project direction

The Grocery Business App is **one shared business ecosystem** with specialized interfaces for Customer, Owner / Boss, POS / Staff, Financial Reports / Accounting, Compliance, Inventory & Purchasing, and Payments & Settlement. These interfaces should use consistent shared records for products, transactions, customer IDs, inventory, permissions, and audit trails. The separate MLM App is outside this repository and project scope.

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
| GitHub repository | **Available** | Repository exists; default branch is `main`. |
| Android CI workflow | **Implemented and operational** | Workflow successfully runs tests and Android release builds. |
| Workflow #8 | **Passed** | Run `40450412116` completed successfully after the product-catalogue implementation fix. |
| APK artifact | **Available from workflow #8** | Split APK artifact uploaded successfully for `armeabi-v7a`, `arm64-v8a`, and `x86_64`. |
| Product catalogue | **Implemented and CI-verified** | Create, view, edit, search, and deactivate product flows are implemented on `feature/product-catalogue-sqlite`; widget tests pass. |
| SQLite persistence | **Implemented and real-device verified** | Product persistence smoke test has been completed successfully on the target Android device, including create → restart → edit → deactivate. |
| Offline POS and sales recording | **Implemented; verification pending** | Cart, quantity controls, payment/change calculation, transaction records, and history are added on `feature/pos-cart-sales`; CI and real-device verification are pending. |
| Inventory movement tracking | **Needs repository verification** | User reports inventory smoke checks passed, but the current repository still needs a durable stock-movement ledger to independently verify movement history. |
| Transaction history / receipts | **Not implemented** | Pending POS and transaction milestones. |
| Web and desktop delivery | **Not started** | Follow Android MVP. |
| Stock quantity limit | **Implemented on feature branch** | App validation, repository validation, and SQLite triggers enforce quantities from 0 through 999,999. |\n| Crypto-related modules | **Deferred** | Must not block traditional grocery MVP. |

## 3. Master checklist

Status meanings: **Not started** = no verified implementation; **In progress** = implementation underway; **Blocked** = cannot proceed pending a dependency; **Completed** = implemented and verified with evidence.

### Milestone 0 — Project foundation
- [x] GitHub repository exists.
- [x] Android APK build workflow is configured.
- [x] Workflow supports pushes to the main branches, pull requests, and manual runs.
- [x] Fresh APK artifact verified in workflow #8.
- [x] Current feature branch Flutter tests pass in workflow #8.
- [x] Current feature branch release split APK build passes in workflow #8.
- [x] Real-device APK smoke test completed.

### Milestone 1 — Traditional grocery MVP (Android-first)
- [ ] Define and implement the grocery home/navigation screen.
- [x] Product catalogue: create, view, edit, search, and deactivate products.
- [ ] Product categories, units, cost price, SKU/barcode fields.
- [ ] Inventory quantity and stock adjustments.
- [x] Local SQLite product persistence implementation.
- [x] Verify SQLite persistence across a real app restart on Android.
- [x] POS cart: add/remove items and change quantities (user-reported device smoke test; code on feature branch).
- [x] Calculate subtotal, totals, payment received, and change (user-reported device smoke test; code on feature branch).
- [x] Complete a sale and save a transaction record (user-reported device smoke test; code on feature branch).
- [x] Basic transaction history UI and persisted sale records (user-reported restart smoke test; recheck on confirmation build).
- [x] Confirm sale details before committing the transaction (new implementation; CI pending).
- [ ] Basic low-stock visibility.
- [ ] Validate the updated confirmation flow and complete core flow with the fresh CI APK on a real device.

### Milestone 2 — Operational safeguards
- [x] Basic product input validation for name, price, and stock quantity.
- [ ] Reliable transaction IDs and timestamps.
- [ ] Backup / restore strategy appropriate for a single offline device.
- [ ] Record stock changes and sales consistently.
- [ ] Review broader error handling and data integrity.

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

1. Confirm the new pre-sale confirmation dialog and cancellation behavior pass CI; install the resulting APK and re-run POS smoke tests.
2. Complete the remaining physical stock-cap test: reject quantities above 999999.
3. Verify that a durable stock-movement ledger exists in the repository and add integration tests for stock-in, stock-out, adjustments, and history persistence if needed.
4. Add/confirm SQLite integration tests proving sale commit, stock deduction, insufficient-stock rejection, and rollback are atomic.
5. Keep `feature/pos-cart-sales` isolated until the updated APK is tested and stable.

## 5. Evidence and working links
- [Repository](https://github.com/JasonScottCManalo12/grocery-business-app)
- [Android build workflow](.github/workflows/build-android.yml)
- [Workflow #8](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40450412116)
- [GitHub Actions runs and artifacts](https://github.com/JasonScottCManalo12/grocery-business-app/actions)
- [Source code](https://github.com/JasonScottCManalo12/grocery-business-app/tree/feature/product-catalogue-sqlite/lib)

## 6. Update protocol

For each meaningful milestone:
1. Discuss and agree on the scope before making changes.
2. Implement the agreed change.
3. Run the relevant tests/build and inspect the actual result.
4. Update this file with the status, verification date, and evidence link.
5. Record important architecture decisions in repository documentation when appropriate.

Keep this file concise enough to serve as the current dashboard. Use commit history, pull requests, workflow runs, and code for detailed evidence. Do not mark a feature complete merely because a plan exists or an APK builds.
