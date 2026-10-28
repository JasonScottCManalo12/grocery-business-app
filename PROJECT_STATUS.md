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
| Product catalogue | Implemented; numeric-formatting/parsing tests passed in workflow #78 | Create, view, edit, search by name/description, deactivate. Prices and stock display with thousands separators; comma-grouped inputs are parsed. |
| Product SQLite persistence | User-reported device verification complete | Create/edit/deactivate and restart persistence passed. |
| Legacy product-name duplicate audit | Implemented; CI passed in workflow #95 | Read-only repository audit and regression test passed; no database uniqueness constraint yet. |
| POS cart and checkout | Implemented; CI/device evidence green | Cart, quantities, total/payment/change, confirmation, sale history, search/scrolling, comma-formatted payment, and transactional safeguards. |
| Stock quantity cap | Implemented on feature branch | UI/repository validation and SQLite constraints/triggers target 0–999,999; user reports the over-cap device test passed. |
| Stock movement ledger | Implemented; CI/device evidence green | Stock-in/out, adjustments, sale entries, movement history, formatted quantities, and persistence. |
| Sale atomicity | Implemented and integration-tested | Sale header, line items, stock deduction, and sale movement are written inside one SQLite transaction; failure rollback is tested. |
| Phase 1 accounting scope | Defined; implementation pending | `PHASE1_ACCOUNTING_SCOPE.md` defines sales totals, acquisition cost, WAC, inventory valuation, COGS, and gross profit as the minimum accounting foundation. |
| Acquisition cost / WAC / COGS | Not implemented/verified | Current evidence covers selling price, quantity, stock movements, and sales, but not verified acquisition-cost or WAC/COGS records. |
| Web / desktop | Not started | After Android MVP. |
| Crypto modules | Deferred | Must not delay traditional grocery operations. |

### Latest workflow evidence

- **Latest CI passed:** [run #95](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40653105485), commit `6fa2e53bfc94890f7a156df6073c635ae8641c4d`; 20 tests passed, including the legacy duplicate-name audit test, and split APKs were built and uploaded.
- **Latest APK artifact:** `grocery-business-app-apks`, approximately 24.5 MB; the user confirmed the APK was installed and reported **ALL GREEN**.
- Earlier payment-formatting/checkout evidence: [workflow #78](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40634553997).
- Earlier stock-movement quantity-limit evidence: [workflow #84](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40639896925).

## 3. Smoke-test status (user-reported)

- [x] Product catalogue: 6/6.
- [x] Inventory: 6/6, including rejection above 999,999.
- [x] POS and sales, previous build: 7/7.
- [x] POS confirmation, latest build: 4/4.
- [x] Latest inventory movement-history and POS/sale-history regression checks passed.
- [x] Five inventory device-verification checks passed: comma-formatted stock-in; stock-out respecting available stock; adjustments within `0–999,999`; formatted movement quantities/balances; persistence after navigation.
- [x] Six earlier APK checks passed: description persistence, duplicate-name validation, POS search/scrolling, cart retention, stock limits/movements/sale deductions, and history persistence.
- [x] Latest comma-formatting and Complete Sale checks passed.
- [x] Offline/persistence acceptance: five reported checks passed, including offline operation, sale completion, reopening, and sale/stock/movement consistency.
- [x] Workflow #95 CI passed with 20 tests and produced a split-APK artifact.
- [x] User confirmed the workflow #95 APK was installed and reported **ALL GREEN**.

## 4. Current recommendations

1. **Next implementation: Supplier/Purchase Receiving.** Capture received quantity and actual acquisition/unit cost separately from product selling price. This is the required foundation for WAC.
2. **Implement WAC after receiving exists.** Do not use selling price as acquisition cost. Test repeated receipts, different costs/quantities, zero stock, rounding, restart persistence, and sale/rollback behavior.
3. **Implement inventory valuation, COGS, and gross profit** after WAC is reliable.
4. **Decide expense/net-profit scope** only if explicitly accepted for Phase 1.
5. **Backup/restore acceptance** remains required before treating financial records as release-ready.
6. Product-name database uniqueness remains open until legacy records and a safe migration path are handled.
7. Keep `feature/pos-cart-sales` isolated; do not merge into `main` without explicit approval.

## 5. Phase 1 accounting scope

See [`PHASE1_ACCOUNTING_SCOPE.md`](https://github.com/JasonScottCManalo12/grocery-business-app/blob/feature/pos-cart-sales/PHASE1_ACCOUNTING_SCOPE.md).

Dependency order:

**Supplier/Purchase Receipt → Acquisition Cost → WAC → Inventory Value → COGS → Gross Profit**

## 6. Key links

- [Repository](https://github.com/JasonScottCManalo12/grocery-business-app)
- [GitHub Actions](https://github.com/JasonScottCManalo12/grocery-business-app/actions)
- [Suggestions List](https://github.com/JasonScottCManalo12/grocery-business-app/blob/feature/pos-cart-sales/SUGGESTIONS.md)
- [Phase 1 accounting scope](https://github.com/JasonScottCManalo12/grocery-business-app/blob/feature/pos-cart-sales/PHASE1_ACCOUNTING_SCOPE.md)
- [POS feature branch](https://github.com/JasonScottCManalo12/grocery-business-app/tree/feature/pos-cart-sales)

## 7. Update protocol

For each milestone: implement the agreed scope, run tests/build, inspect actual results, update this dashboard with evidence, and keep unverified behavior marked as pending. Do not merge a feature branch without explicit approval.
