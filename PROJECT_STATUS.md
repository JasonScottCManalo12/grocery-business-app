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
| Product catalogue | Implemented; numeric-formatting/parsing tests passed in workflow #78 | Create, view, edit, search by name/description, deactivate. Prices and stock display with thousands separators; comma-grouped inputs are parsed. Run #78 `flutter test` logs explicitly show passing `test/number_format_test.dart` cases for integer/PHP formatting, grouped in-progress decimal input, grouped quantities with malformed-grouping rejection, and comma-grouped decimal money parsing. The POS comma-formatted-payment sale regression also passed. Run #84 later passed after stock-movement quantity-limit changes. |
| Product SQLite persistence | User-reported device verification complete | Create/edit/deactivate and restart persistence passed. |
| Legacy product-name duplicate audit | Implemented on feature branch; CI pending | Read-only repository method groups rows colliding under `lower(trim(name))`; integration test inserts a legacy duplicate directly and asserts both records remain intact. This does not yet enforce a database uniqueness constraint. |
| POS cart and checkout | Implemented; latest payment-formatting/checkout CI green | Cart, quantities, total/payment/change, checkout confirmation, sale history. Prices, payment, change, stock, and quantities now use thousands separators; payment input accepts valid comma grouping; live formatter now groups arbitrarily long values and regression tests cover comma-formatted checkout. |
| Stock quantity cap | Implemented on feature branch | UI/repository validation and SQLite constraints/triggers target 0–999,999; user reports the over-cap device test passed. |
| Stock movement ledger | Implemented; latest CI green; user-reported device checks passed | SQLite `stock_movements` table and atomic stock-in/out, adjustment, and sale entries. Inventory counts, deltas, and balances display with thousands separators; comma-grouped quantity inputs are supported. User reports grouped stock-in, stock-out respecting available stock, adjustments within `0–999,999`, formatted movement history, and persistence after navigation all passed on device. |
| Sale atomicity | Implemented and integration-tested in code | Sale header, line items, stock deduction, and sale movement ledger are written inside one SQLite transaction. Failure tests cover insufficient stock/payment rollback; see latest workflow for current status. |
| Web / desktop | Not started | After Android MVP. |
| Crypto modules | Deferred | Must not delay traditional grocery operations. |

### Latest workflow evidence

- **Latest CI passed:** [run #84](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40639896925), commit `1c92a66c8d043252f02d6f781a37d25926b3279d` (`Enforce stock movement quantity limits`). Earlier payment-formatting/checkout CI also passed in [run #78](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40634553997).
- **APK artifact:** `grocery-business-app-apks`, 24,516,655 bytes (~24.5 MB), available until 2026-11-11 04:54 UTC.
- Confirmation-flow baseline passed: [run 40469645532](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40469645532).
- Stock-ledger and SQLite integration-test baseline: [run 40474176723](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474176723).
- Dashboard build baseline: [run 40474375181](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474375181).
- Numeric-formatting/parsing and comma-formatted checkout tests passed in [workflow #78](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40634553997), commit `3f3505ec1d68ccd357db4a836e46b63f4a760584`. The `flutter test` log explicitly names the relevant cases in `test/number_format_test.dart` and `test/pos_page_test.dart`. Workflow #84 subsequently passed after the stock-movement quantity-limit changes. The run #78 APK artifact was uploaded; check the specific run for current availability.

## 3. Smoke-test status (user-reported)

- [x] Product catalogue: 6/6.
- [x] Inventory: 6/6, including rejection above 999,999.
- [x] POS and sales, previous build: 7/7.
- [x] POS confirmation, latest build: 4/4.
- [x] User reports latest-build inventory movement history and POS/sale history regression checks passed.
- [x] User reports all five inventory device-verification checks passed: comma-formatted stock-in (e.g. `1,234`); stock-out respecting available stock; adjustments within `0–999,999`; formatted movement quantities/balances in history; and inventory persistence after navigating away and returning.
- [x] User reports all six checks passed on the previous newest APK: description persistence, duplicate-name validation, POS search/scrolling, cart retention during search, stock limits/movements/sale deductions, and history persistence.
- [x] User confirmed all latest device checks, including live comma grouping beyond four digits and Complete Sale accepting comma-formatted payment.
- [x] Latest GitHub Actions workflow passed on commit `3f3505ec1d68ccd357db4a836e46b63f4a760584` and produced the APK artifact above.

## 4. Current recommendations

1. Latest CI is green: [run #84](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40639896925), including the stock-movement quantity-limit change. Verify the run's artifact before treating it as the newest installable APK.
2. Inventory device verification: user reports all five checks passed—comma-formatted stock-in, stock-out within available stock, adjustments within `0–999,999`, formatted movement history, and persistence after navigation. Treat this as user-reported device evidence; CI status remains independently tracked.
3. Product-name uniqueness: added a read-only legacy duplicate audit and a regression test that confirms no records are deleted or merged; CI is pending. Next, run CI and determine how to inspect any duplicates on existing device databases. Only add a database-level unique index after a safe migration path is proven; optional SKU/barcode support remains a later-phase consideration.
4. Inventory costing direction: WAC is the provisional working choice documented in [`KEEP_IN_MIND.md`](https://github.com/JasonScottCManalo12/grocery-business-app/blob/feature/pos-cart-sales/KEEP_IN_MIND.md); costing implementation and tests still require separate verification.
5. Keep `feature/pos-cart-sales` isolated; do not merge into `main` without explicit approval.
6. Keep this dashboard and `SUGGESTIONS.md` aligned with current CI/device evidence. The latest duplicate-audit helper/test is not CI-verified until its workflow completes.

## 5. Key links

- [Repository](https://github.com/JasonScottCManalo12/grocery-business-app)
- [GitHub Actions](https://github.com/JasonScottCManalo12/grocery-business-app/actions)
- [Confirmation-flow workflow](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40469645532)
- [Current stock-ledger/integration-test workflow](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474176723)
- [Suggestions List](https://github.com/JasonScottCManalo12/grocery-business-app/blob/feature/pos-cart-sales/SUGGESTIONS.md)
- [POS feature branch](https://github.com/JasonScottCManalo12/grocery-business-app/tree/feature/pos-cart-sales)

## 6. Update protocol

For each milestone: implement the agreed scope, run tests/build, inspect actual results, update this dashboard with evidence, and keep unverified behavior marked as pending. Do not merge a feature branch without explicit approval.


Latest CI follow-up: runs #75–77 failed during iterative changes; run #78 passed after the comma-formatted checkout regression test was placed inside the test suite. Its logs explicitly confirm the numeric-formatting/parsing helper tests and comma-formatted checkout regression passed. Newer run #84 passed after stock-movement quantity-limit changes. User reports the five inventory device-verification checks passed: grouped stock-in, stock-out respecting available stock, adjustment range, formatted movement history, and persistence after navigation. These are user-reported device results, not a substitute for CI evidence.


## 7. Numeric formatting recommendation

Requested by user: use thousands separators for displayed numeric values, including PHP prices and amounts (`₱1,234.56`) and quantities (`1,234`). Inputs should accept correctly grouped commas and reject malformed grouping. Implementation is on the feature branch; numeric-formatting/parsing helper tests and comma-formatted checkout regression passed in run #78. The later run #84 passed after stock-movement quantity-limit changes. User-confirmed payment-formatting checks are complete. User also reports grouped stock-in/out/adjustment, formatted movement history, and persistence checks passed on device; CI evidence is tracked separately.
