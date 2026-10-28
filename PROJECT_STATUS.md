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
| Product catalogue | Implemented; description enhancement added | Create, view, edit, search by name/description, deactivate. Product descriptions now persist through schema v4 migration; widget test updated. Latest enhancement CI/device verification pending. |
| Product SQLite persistence | User-reported device verification complete | Create/edit/deactivate and restart persistence passed. |
| POS cart and checkout | Implemented; usability enhancement added | Cart, quantities, total/payment/change, checkout confirmation, sale history. Searchable, scrollable product picker now matches name/description and displays price/stock. Latest enhancement CI/device verification pending. |
| Stock quantity cap | Implemented on feature branch | UI/repository validation and SQLite constraints/triggers target 0–999,999; user reports the over-cap device test passed. |
| Stock movement ledger | Data layer and initial UI implemented on feature branch | SQLite `stock_movements` table and atomic stock-in/out, adjustment, and sale entries. New Inventory & Movement History screen is wired from the catalogue; CI and device verification pending. |
| Sale atomicity | Implemented and integration-tested in code | Sale header, line items, stock deduction, and sale movement ledger are written inside one SQLite transaction. Failure tests cover insufficient stock/payment rollback; see latest workflow for current status. |
| Web / desktop | Not started | After Android MVP. |
| Crypto modules | Deferred | Must not delay traditional grocery operations. |

### Latest workflow evidence

- Confirmation-flow baseline passed: [run 40469645532](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40469645532).
- Stock-ledger and SQLite integration-test baseline: [run 40474176723](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474176723).
- Dashboard build baseline: [run 40474375181](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474375181).
- Product description persistence, duplicate-name guard, POS search/list, inventory UI, and integration-test updates are committed to `feature/pos-cart-sales`. Workflow run 48 fixed the inventory compile error but failed three POS widget tests because the payment field was not yet built by the lazy outer ListView; tests now scroll until it is visible. Retry and device verification remain pending.

## 3. Smoke-test status (user-reported)

- [x] Product catalogue: 6/6.
- [x] Inventory: 6/6, including rejection above 999,999.
- [x] POS and sales, previous build: 7/7.
- [x] POS confirmation, latest build: 4/4.
- [x] User reports latest-build inventory movement history and POS/sale history regression checks passed.
- [ ] Re-test product descriptions, duplicate-name validation, and POS search on an APK built from the newest source changes.

## 4. Current recommendations

1. Confirm CI passes and produces APK artifacts for the newest description/duplicate-guard/POS-search changes.
2. Install the newest APK and verify description create/edit/persistence, case-insensitive duplicate rejection, POS name/description search, cart retention during search, stock caps, sale atomicity, and history persistence.
3. Inventory UI entry point and stock movement screen have now been added; verify stock-in/out/adjustment forms and movement history in CI and on-device.
4. Keep `feature/pos-cart-sales` isolated; do not merge into `main` automatically.
5. Keep the Suggestions List current and update evidence after CI/device checks. The integration test fixture now includes the product description column and tests description persistence plus case-insensitive duplicate rejection.

## 5. Key links

- [Repository](https://github.com/JasonScottCManalo12/grocery-business-app)
- [GitHub Actions](https://github.com/JasonScottCManalo12/grocery-business-app/actions)
- [Confirmation-flow workflow](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40469645532)
- [Current stock-ledger/integration-test workflow](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474176723)
- [Suggestions List](https://github.com/JasonScottCManalo12/grocery-business-app/blob/feature/pos-cart-sales/SUGGESTIONS.md)
- [POS feature branch](https://github.com/JasonScottCManalo12/grocery-business-app/tree/feature/pos-cart-sales)

## 6. Update protocol

For each milestone: implement the agreed scope, run tests/build, inspect actual results, update this dashboard with evidence, and keep unverified behavior marked as pending. Do not merge a feature branch without explicit approval.
