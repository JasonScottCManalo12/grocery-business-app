# Grocery Business App — Suggestions List

**Last reviewed:** 2026-10-28  
**Branch:** `feature/pos-cart-sales`  
**Rule:** Do not merge to `main` without explicit approval. Mark an item complete only when code/CI evidence or user-reported device verification supports that status.

## Product catalogue

- [x] Add an optional product description field to the model, form, and catalogue.
- [x] Persist descriptions using SQLite schema version 4 migration; existing rows receive an empty description by default.
- [x] Search catalogue products by name or description.
- [x] Reject new/renamed products whose names duplicate another product after trimming and case-folding; preserve existing records and require more specific names for distinct variants.
- [ ] Add a database-level uniqueness strategy after reviewing any existing duplicate names; do not silently delete or merge legacy records.
- [ ] Consider optional SKU/barcode support in a later phase.

## POS and checkout

- [x] Add POS product search by name or description.
- [x] Use a bounded, scrollable product picker that shows product name, description, price, and available stock.
- [x] Keep cart state separate from search filtering so searching does not intentionally clear cart items.
- [x] Keep checkout confirmation and sale/stock movement transaction safeguards.
- [ ] Device-test description search, scrolling, cart retention, and quantity limits on the newest APK.

## Inventory and sales integrity

- [x] Stock-movement data layer records stock-in, stock-out, adjustments, and sale deductions.
- [x] Sale records, line items, stock deductions, and sale movements use one SQLite transaction.
- [x] Reviewed inventory UI entry points; added an Inventory & Movement History screen with stock-in, stock-out, adjustments, reason capture, balance display, and movement history, connected from the catalogue.
- [ ] CI-verify the new inventory screen and test stock operations/history on the newest APK.
- [ ] Reconfirm inventory movement and transaction history survive restart on the newest APK.

## Release and project management

- [x] Keep the work isolated on `feature/pos-cart-sales`.
- [x] Update `PROJECT_STATUS.md` with current scope and outstanding verification.
- [ ] Confirm CI passes after the latest product/POS/inventory changes and save the artifact/run links here.
- [ ] Install and smoke-test the newest APK before requesting any merge.
- [x] Keep web, desktop, and crypto modules from delaying the traditional Android MVP.

## Latest known baselines

- Stock-ledger/integration-test workflow: [run 40474176723](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474176723)
- Dashboard build baseline: [run 40474375181](https://github.com/JasonScottCManalo12/grocery-business-app/actions/runs/40474375181)

The baseline links above predate the newest description, POS search, and inventory UI commits. Latest run 48 failed in POS widget tests because the payment field is lazily built below the scroll position; tests were updated to scroll the outer POS list until the field is built. Latest retry pending: [GitHub Actions](https://github.com/JasonScottCManalo12/grocery-business-app/actions). The SQLite integration-test fixture was updated to include the description column, and tests were added for description persistence and case-insensitive duplicate rejection; all remain pending CI verification.
