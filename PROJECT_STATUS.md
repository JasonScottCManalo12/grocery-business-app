# Grocery Business App — Project Status

**Last reviewed:** 2026-10-27  
**Repository:** `JasonScottCManalo12/grocery-business-app`  
**Working branch:** `feature/pos-cart-sales`  
**Default branch:** `main`

> This dashboard distinguishes repository/CI evidence from physical-device checks reported by the user. A successful build confirms packaging, not every business behavior.

## 1. Product direction

The Grocery Business App is one shared business ecosystem with specialized interfaces for Customer, Owner/Boss, POS/Staff, Financial Reports/Accounting, Compliance, Inventory & Purchasing, and Payments & Settlement. These interfaces should share consistent product, transaction, customer, inventory, permission, and audit records. The independent MLM App is outside this repository.

Delivery order: **Android APK → web → desktop**. Phase 1 is traditional grocery operations using Flutter/Dart, local SQLite, offline-first, one device/shop. Crypto modules must not delay the ordinary MVP.

## 2. Current status

| Area | Status | Evidence |
|---|---|---|
| Android CI | Operational | Workflow runs Flutter tests, builds split release APKs, and uploads artifacts. |
| Product catalogue | Implemented | Create, view, edit, search, deactivate; user reports all 6 catalogue smoke tests passed. |
| Product SQLite persistence | User-reported device verification complete | Create/edit/deactivate and restart persistence passed. |
| POS cart and checkout | Implemented on feature branch | Cart, quantities, total/payment/change, checkout confirmation, sale history. User reports all 7 previous POS checks and 4 confirmation-build checks passed on device. |
| Stock quantity cap | Implemented on feature branch | UI/repository validation and SQLite constraints/triggers target 0–999,999; user reports the over-cap device test passed. |
| Stock movement ledger | Data layer implemented on feature branch | SQLite `stock_movements` table, stock-in/out and adjustment methods, plus sale deduction entries; integration tests added. Inventory movement screen/UI still needs source-level confirmation and wiring if absent. |
| Sale atomicity | Implemented and integration-tested in code; CI pending final result | Sale header, line items, stock deduction, and sale movement ledger are written inside one SQLite transaction. Failure tests cover insufficient stock/payment rollback. |
| Web / desktop | Not started | After Android MVP. |
| Crypto modules | Deferred | Must not delay traditional grocery operations. |

### Latest workflow evidence

- Confirmation-flow baseline passed: [run 40469645532](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40469645532).
- New stock-ledger and SQLite integration-test code is on `feature/pos-cart-sales`. Latest run for commit `dd82eae8`: [run 40474176723](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474176723). Tests passed; split APK build was still running at last check.

## 3. Smoke-test status (user-reported)

- [x] Product catalogue: 6/6.
- [x] Inventory: 6/6, including rejection above 999,999.
- [x] POS and sales, previous build: 7/7.
- [x] POS confirmation, latest build: 4/4.
- [ ] Re-test inventory ledger behavior on an APK built from the current source changes.
- [ ] Re-test POS and sale history on the APK built from the current source changes.

## 4. Current recommendations

1. Confirm the latest workflow finishes successfully and produces APK artifacts.
2. Inspect and test the inventory UI wiring: the data layer now records stock-in, stock-out, adjustments, and sale deductions, but the repository tree does not currently contain a dedicated inventory screen file.
3. After installing the newest artifact, verify movement history and sale history survive restart.
4. Keep `feature/pos-cart-sales` isolated until CI and device checks pass. Do not merge into `main` automatically.
5. Once verified, update this dashboard with final run/artifact links and the new device results.

## 5. Key links

- [Repository](https://github.com/JasonScottCManalo12/grocery-business-app)
- [GitHub Actions](https://github.com/JasonScottCManalo12/grocery-business-app/actions)
- [Confirmation-flow workflow](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40469645532)
- [Current stock-ledger/integration-test workflow](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474176723)
- [POS feature branch](https://github.com/JasonScottCManalo12/grocery-business-app/tree/feature/pos-cart-sales)

## 6. Update protocol

For each milestone: implement the agreed scope, run tests/build, inspect actual results, update this dashboard with evidence, and keep unverified behavior marked as pending. Do not merge a feature branch without explicit approval.
