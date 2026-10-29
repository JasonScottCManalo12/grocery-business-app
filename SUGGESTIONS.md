# Grocery Business App — Suggestions List

**Last reviewed:** 2026-10-29  
**Branch:** `feature/supplier-purchase-receiving`  
**Rule:** Do not merge to `main` without explicit approval. Mark an item complete only when code/CI evidence or user-reported device verification supports that status.

## Product catalogue

- [x] Add optional product descriptions to the model, form, catalogue, SQLite persistence, and search.
- [x] Reject new or renamed products whose names duplicate another product after trimming and case-folding.
- [x] Format displayed prices and stock counts with thousands separators (example: `₱1,234.56`, `1,234`).
- [x] Accept correctly grouped comma-formatted price and quantity inputs (example: `1,234.56`, `1,234`) and reject malformed grouping.
- [x] CI-verify numeric formatting/parsing helpers and comma-formatted checkout: workflow #78's `flutter test` logs explicitly show passing `test/number_format_test.dart` cases for integer/PHP formatting, grouped in-progress decimals, grouped whole quantities with malformed-grouping rejection, comma-grouped money parsing, and the POS comma-formatted-payment sale regression. Workflow #84 later passed after stock-movement quantity-limit changes. User also confirmed relevant device checks.
- [ ] Add a database-level uniqueness strategy only after auditing legacy records and validating a safe upgrade path. Never silently delete, merge, rename, or deactivate duplicates.
- [x] Add a read-only repository audit for legacy product-name collisions using the current `lower(trim(name))` rule; integration test covers a legacy duplicate and confirms both records remain unchanged. CI passed in workflow #95 (20 tests passed; see [run #95](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40653105485)).
- [ ] Smoke-test the duplicate audit specifically if/when a user-facing audit path is added; no user-facing audit screen is currently documented.
- [ ] Consider optional SKU/barcode support in a later phase.

## POS and checkout

- [x] Search products by name or description.
- [x] Use a bounded, scrollable product picker showing name, description, price, and available stock.
- [x] Keep cart state separate from search filtering so searching does not clear cart items.
- [x] Preserve checkout confirmation and transactional sale/stock movement safeguards.
- [x] Format POS prices, totals, payment, change, stock, and quantities with thousands separators.
- [x] Parse payment amounts containing valid thousands separators.
- [x] Format valid payment input with thousands separators during the input/change event.
- [x] Correct live formatting for values longer than four digits and preserve incomplete decimal input while typing.
- [x] Add regression coverage for multi-group payment input and completing checkout with comma-formatted payment.
- [x] Refresh POS product/stock data after returning from the Inventory screen.
- [x] CI-verify live payment formatting and comma-formatted Complete Sale; workflow #78 passed and user confirmed device checks. Inventory-to-POS refresh had prior green CI coverage in run #71 and user-reported device checks.

## Inventory and sales integrity

- [x] Record stock-in, stock-out, adjustments, and sale deductions in the stock-movement ledger.
- [x] Write sale header, sale items, stock deduction, and sale movement inside one SQLite transaction.
- [x] Add Inventory & Movement History screen with reasons, balances, and movement history.
- [x] Format inventory counts and movement deltas/balances with thousands separators.
- [x] Reload inventory data after stock-in/out/adjustment operations.
- [x] Refresh the product catalogue after returning from Inventory, so the new stock balance is displayed automatically.
- [x] User-reported device verification on the current inventory build: comma-formatted stock-in quantity (e.g. `1,234`), stock-out with available-stock cap, adjustment range `0–999,999`, formatted movement history, and persistence after navigating away and returning all passed. This is user-reported device evidence, separate from CI.
- [x] Enforce stock-movement quantity limits (stock-in capped by the remaining capacity to 999,999; stock-out capped by current stock; adjustments restricted to 0–999,999); latest workflow #84 passed. User-reported over-cap device verification is recorded in `PROJECT_STATUS.md`.

## Phase 1 accounting

- [x] Define the minimum Phase 1 accounting scope in `PHASE1_ACCOUNTING_SCOPE.md`.
- [x] Implement supplier/purchase receiving form and repository: capture supplier name, product, received quantity, and actual acquisition cost separately from selling price; record receipt header/items and stock movement in one transaction. Workflow #107 passed and user confirmed all purchase-receiving device smoke-test items checked.
- [ ] Implement WAC from receipt cost and quantity; do not use selling price as acquisition cost.
- [ ] Implement inventory valuation from on-hand quantity × WAC.
- [ ] Implement COGS and transactionally consistent sale-cost posting.
- [ ] Implement gross-profit reporting (sales revenue − COGS).
- [ ] Decide whether operating expenses and net-profit reporting belong in Phase 1.
- [ ] Add accounting acceptance tests for repeated receipts, different costs/quantities, zero stock, rounding, restart persistence, completed sales, and failed checkout rollback.
- [ ] Add backup/restore acceptance before declaring financial records release-ready.

## Release and project management

- [x] Keep work isolated on feature branches; current accounting work is on `feature/supplier-purchase-receiving`.
- [x] Update `PROJECT_STATUS.md` and this suggestions list.
- [x] User reports the six latest APK smoke checks passed before the comma-formatting changes.
- [x] Confirm CI passes after the latest payment-formatting changes: [run #78](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40634553997).
- [x] Confirm CI passes after stock-movement quantity-limit changes: [run #84](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40639896925), commit `1c92a66c8d043252f02d6f781a37d25926b3279d`.
- [x] User confirmed workflow #95 APK installed successfully and reported **ALL GREEN**.
- [x] User confirmed all five inventory device-verification checks passed: grouped stock-in quantity, stock-out and available-stock cap, valid adjustment range, formatted movement history, and persistence after navigation. Do not merge without explicit approval.
- [x] Keep web, desktop, and crypto modules from delaying the traditional Android MVP.

## Latest workflow evidence

- Previous verified baseline: [run #95](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40653105485), commit `6fa2e53bfc94890f7a156df6073c635ae8641c4d`; 20 tests passed and split APKs were built and uploaded. This is CI evidence, not physical-device verification.
- Purchase receiving is on branch `feature/supplier-purchase-receiving`; [workflow #107](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40867505101) succeeded, including integration tests and APK build/upload. User confirmed all on-device purchase-receiving smoke-test items checked. New tests cover receipt cost capture, stock increase, preserved selling price, and rollback when stock capacity would be exceeded.
- Earlier payment-formatting/checkout regression workflow passed: [run #78](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40634553997), commit `3f3505ec1d68ccd357db4a836e46b63f4a760584`.
- Workflow #95 artifact `grocery-business-app-apks` was reported available until 2026-11-11 07:58 UTC; the user subsequently confirmed the APK was installed and reported ALL GREEN.
- User reports all five inventory device checks passed: comma-grouped stock-in, stock-out respecting available stock, adjustment range `0–999,999`, formatted movement history, and persistence after navigation. Record these as user-reported device verification; do not imply CI independently proves device behavior.

## Next implementation action

**Next: verify the WAC/COGS APK on-device** once workflow #119 finishes. Then implement inventory valuation and gross-profit reporting/reconciliation. Tests cover multiple receipts at different costs, checkout COGS, gross-profit arithmetic, and rollback; more rounding, restart/migration, and edge-case tests remain advisable.
