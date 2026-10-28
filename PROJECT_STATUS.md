# Grocery Business App — Project Status

**Last reviewed:** 2026-10-28  
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
| Product catalogue | Implemented; comma-formatting update pending CI | Create, view, edit, search by name/description, deactivate. Prices and stock display with thousands separators; comma-grouped inputs are parsed. New helper tests are pending CI. |
| Product SQLite persistence | User-reported device verification complete | Create/edit/deactivate and restart persistence passed. |
| POS cart and checkout | Implemented; comma-formatting update pending CI | Cart, quantities, total/payment/change, checkout confirmation, sale history. Prices, payment, change, stock, and quantities now use thousands separators; payment input accepts valid comma grouping; live formatter now groups arbitrarily long values and regression tests cover comma-formatted checkout. |
| Stock quantity cap | Implemented on feature branch | UI/repository validation and SQLite constraints/triggers target 0–999,999; user reports the over-cap device test passed. |
| Stock movement ledger | Data layer and UI implemented on feature branch | SQLite `stock_movements` table and atomic stock-in/out, adjustment, and sale entries. Inventory counts, deltas, and balances display with thousands separators; comma-grouped quantity inputs are supported. Latest numeric-formatting CI pending. |
| Sale atomicity | Implemented and integration-tested in code | Sale header, line items, stock deduction, and sale movement ledger are written inside one SQLite transaction. Failure tests cover insufficient stock/payment rollback; see latest workflow for current status. |
| Web / desktop | Not started | After Android MVP. |
| Crypto modules | Deferred | Must not delay traditional grocery operations. |

### Latest workflow evidence

- Confirmation-flow baseline passed: [run 40469645532](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40469645532).
- Stock-ledger and SQLite integration-test baseline: [run 40474176723](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474176723).
- Dashboard build baseline: [run 40474375181](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474375181).
- Last known green baseline before comma-formatting changes: [run 40613572887](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40613572887). New comma-formatting changes are committed to `feature/pos-cart-sales`; their CI result is pending.

## 3. Smoke-test status (user-reported)

- [x] Product catalogue: 6/6.
- [x] Inventory: 6/6, including rejection above 999,999.
- [x] POS and sales, previous build: 7/7.
- [x] POS confirmation, latest build: 4/4.
- [x] User reports latest-build inventory movement history and POS/sale history regression checks passed.
- [x] User reports all six checks passed on the previous newest APK: description persistence, duplicate-name validation, POS search/scrolling, cart retention during search, stock limits/movements/sale deductions, and history persistence.
- [ ] Re-test comma-formatted price and quantity inputs and displayed values on the newest APK.
- [ ] Verify payment input formats beyond four digits and Complete Sale accepts grouped amounts such as `1,000.00`.

## 4. Current recommendations

1. Confirm CI passes and produces APK artifacts for the newest comma-formatting changes.
2. Install the newest APK and verify description create/edit/persistence, case-insensitive duplicate rejection, POS name/description search, cart retention during search, stock caps, sale atomicity, and history persistence.
3. Inventory UI entry point and stock movement screen have now been added; verify stock-in/out/adjustment forms and movement history in CI and on-device.
4. Keep `feature/pos-cart-sales` isolated; do not merge into `main` automatically.
5. Keep the Suggestions List current and update evidence after CI/device checks. The new `number_format_test.dart` covers grouped integer/money formatting, valid comma parsing, and malformed grouping rejection.

## 5. Key links

- [Repository](https://github.com/JasonScottCManalo12/grocery-business-app)
- [GitHub Actions](https://github.com/JasonScottCManalo12/grocery-business-app/actions)
- [Confirmation-flow workflow](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40469645532)
- [Current stock-ledger/integration-test workflow](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474176723)
- [Suggestions List](https://github.com/JasonScottCManalo12/grocery-business-app/blob/feature/pos-cart-sales/SUGGESTIONS.md)
- [POS feature branch](https://github.com/JasonScottCManalo12/grocery-business-app/tree/feature/pos-cart-sales)

## 6. Update protocol

For each milestone: implement the agreed scope, run tests/build, inspect actual results, update this dashboard with evidence, and keep unverified behavior marked as pending. Do not merge a feature branch without explicit approval.


Latest CI diagnosis: three POS tests failed because tests targeted the nested product list instead of the outer checkout list; the POS page now exposes a stable key for the outer list and tests scroll that list. Duplicate-name SQL validation no longer passes null arguments. Await fresh CI verification.


## 7. Numeric formatting recommendation

Requested by user: use thousands separators for displayed numeric values, including PHP prices and amounts (`₱1,234.56`) and quantities (`1,234`). Inputs should accept correctly grouped commas and reject malformed grouping. Implementation has been pushed to the feature branch; CI and device checks for this specific update remain pending.
