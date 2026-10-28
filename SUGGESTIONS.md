# Grocery Business App — Suggestions List

**Last reviewed:** 2026-10-28  
**Branch:** `feature/pos-cart-sales`  
**Rule:** Do not merge to `main` without explicit approval. Mark an item complete only when code/CI evidence or user-reported device verification supports that status.

## Product catalogue

- [x] Add optional product descriptions to the model, form, catalogue, SQLite persistence, and search.
- [x] Reject new or renamed products whose names duplicate another product after trimming and case-folding.
- [x] Format displayed prices and stock counts with thousands separators (example: `₱1,234.56`, `1,234`).
- [x] Accept correctly grouped comma-formatted price and quantity inputs (example: `1,234.56`, `1,234`) and reject malformed grouping.
- [x] CI-verify the new numeric formatting/parsing helpers and retest comma-formatted inputs on device; workflow #78 passed and user confirmed checks; later workflow #84 also passed after stock-movement quantity-limit changes.
- [ ] Add a database-level uniqueness strategy after reviewing legacy duplicates; do not silently delete or merge records.
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
- [ ] Re-test comma-formatted stock-in/out/adjustment quantities and formatted history on the newest APK; automatic catalogue/POS refresh is covered by prior green CI runs #69–71.
- [x] Enforce stock-movement quantity limits (stock-in capped by the remaining capacity to 999,999; stock-out capped by current stock; adjustments restricted to 0–999,999); latest workflow #84 passed. User-reported over-cap device verification is recorded in `PROJECT_STATUS.md`.

## Release and project management

- [x] Keep work isolated on `feature/pos-cart-sales`.
- [x] Update `PROJECT_STATUS.md` and this suggestions list.
- [x] User reports the six latest APK smoke checks passed before the comma-formatting changes.
- [x] Confirm CI passes after the latest payment-formatting changes: [run #78](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40634553997).
- [x] Confirm CI passes after stock-movement quantity-limit changes: [run #84](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40639896925), commit `1c92a66c8d043252f02d6f781a37d25926b3279d`.
- [x] User confirmed the latest APK/device checklist is all checked; do not merge without explicit approval.
- [x] Keep web, desktop, and crypto modules from delaying the traditional Android MVP.

## Latest workflow evidence

- Latest workflow passed: [run #84](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40639896925), commit `1c92a66c8d043252f02d6f781a37d25926b3279d` (`Enforce stock movement quantity limits`).
- Earlier payment-formatting/checkout regression workflow passed: [run #78](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40634553997), commit `3f3505ec1d68ccd357db4a836e46b63f4a760584`.
- Run #78 artifact `grocery-business-app-apks` was approximately 24.5 MB and had an availability window ending 2026-11-11 04:54 UTC; check run #84 for its own current artifact status.
- User confirmed the latest device checks for the previous APK were all checked. Keep the comma-formatted stock-in/out/adjustment and formatted movement-history test unchecked until verified on the newest APK.
