# Grocery Business App — Suggestions List

**Last reviewed:** 2026-10-28  
**Branch:** `feature/pos-cart-sales`  
**Rule:** Do not merge to `main` without explicit approval. Mark an item complete only when code/CI evidence or user-reported device verification supports that status.

## Product catalogue

- [x] Add optional product descriptions to the model, form, catalogue, SQLite persistence, and search.
- [x] Reject new or renamed products whose names duplicate another product after trimming and case-folding.
- [x] Format displayed prices and stock counts with thousands separators (example: `₱1,234.56`, `1,234`).
- [x] Accept correctly grouped comma-formatted price and quantity inputs (example: `1,234.56`, `1,234`) and reject malformed grouping.
- [ ] CI-verify the new numeric formatting/parsing helpers and retest comma-formatted inputs on device.
- [ ] Add a database-level uniqueness strategy after reviewing legacy duplicates; do not silently delete or merge records.
- [ ] Consider optional SKU/barcode support in a later phase.

## POS and checkout

- [x] Search products by name or description.
- [x] Use a bounded, scrollable product picker showing name, description, price, and available stock.
- [x] Keep cart state separate from search filtering so searching does not clear cart items.
- [x] Preserve checkout confirmation and transactional sale/stock movement safeguards.
- [x] Format POS prices, totals, payment, change, stock, and quantities with thousands separators.
- [x] Parse payment amounts containing valid thousands separators.
- [ ] CI-verify comma formatting and parsing; verify the latest APK on device.

## Inventory and sales integrity

- [x] Record stock-in, stock-out, adjustments, and sale deductions in the stock-movement ledger.
- [x] Write sale header, sale items, stock deduction, and sale movement inside one SQLite transaction.
- [x] Add Inventory & Movement History screen with reasons, balances, and movement history.
- [x] Format inventory counts and movement deltas/balances with thousands separators.
- [ ] Re-test comma-formatted stock-in/out/adjustment quantities and formatted history on the newest APK.

## Release and project management

- [x] Keep work isolated on `feature/pos-cart-sales`.
- [x] Update `PROJECT_STATUS.md` and this suggestions list.
- [x] User reports the six latest APK smoke checks passed before the comma-formatting changes.
- [ ] Confirm CI passes after the comma-formatting changes and save the new run/artifact link.
- [ ] Install and smoke-test the newest APK before requesting any merge.
- [x] Keep web, desktop, and crypto modules from delaying the traditional Android MVP.

## Latest workflow evidence

- Last known green baseline before comma-formatting changes: [run 40613572887](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40613572887).
- Latest source changes add `lib/utils/number_format.dart`, update product/POS/inventory displays and input parsing, and add `test/number_format_test.dart`.
- The baseline above predates these comma-formatting changes. Check [GitHub Actions](https://github.com/JasonScottCManalo12/grocery-business-app/actions) for the new run; do not treat the prior green run as verification of the new changes.
