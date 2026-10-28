# KEEP_IN_MIND — Grocery Business App

## Inventory costing decision (current direction)

**Use Weighted Average Cost (WAC) for now.** This is the current working choice for inventory costing in the Grocery Business App. Record it as the active direction, but keep the design adaptable if the owner later reviews or changes the accounting policy.

### WAC behavior to preserve

- Recalculate the weighted-average unit cost when a valid stock receipt is recorded.
- Base the calculation on the value and quantity of existing inventory plus the value and quantity of the newly received inventory.
- Conceptually: **new average unit cost = (existing inventory value + incoming inventory cost) ÷ (existing quantity + received quantity)**.
- Example: 10 units at ₱20 plus 10 received units at ₱25 gives 20 units valued at ₱450, for a WAC of ₱22.50 per unit.
- Do not average unit prices without weighting them by their quantities.
- Record supplier deliveries and their actual quantities and costs. An order or expected delivery alone must not increase on-hand stock or inventory value; record stock only when goods are actually received.
- Keep inventory acquisition cost separate from the product's current selling price. Receiving stock must not silently change the selling price.
- Keep stock movements, receipt details, cost changes, and relevant adjustments traceable through transaction records/audit history.
- Define and test handling for returns, purchase discounts, freight/other directly attributable costs, damaged goods, stock adjustments, and rounding before relying on WAC for formal financial reports.
- Prevent invalid quantities, negative stock, and division by zero. A zero-quantity inventory balance needs an explicit, tested rule for initializing cost on the next receipt.

## Alternatives considered

- **FIFO (First In, First Out):** retain as a possible future alternative if batch-level cost layers and traceability become important.
- **LIFO (Last In, First Out):** do not adopt for ordinary IFRS-based financial reporting; it is not permitted under IFRS.
- **WAC:** current working choice for the initial direction because it can simplify costing when the same products are repeatedly purchased at different costs.

## Product catalogue, purchasing, and receiving

Keep these concepts distinct:

1. **Product catalogue:** product identity, SKU/barcode, description, unit of measure, and current selling price.
2. **Purchasing/incoming inventory:** supplier, order, expected quantities, purchase cost, and delivery status.
3. **Goods receiving:** actual received quantities, discrepancies, receipt date, and accepted cost; only a confirmed receipt updates on-hand inventory.
4. **Inventory costing:** WAC-based inventory value and cost of goods sold.
5. **Price management:** the owner decides whether a change in supplier cost should trigger a selling-price review. The app may show margin warnings, but should not silently change prices.

## Implementation guardrails

- Treat WAC as the current policy choice, not a reason to discard original purchase and movement records.
- Preserve enough receipt-level history to audit calculations and support a future policy review.
- Keep the costing calculation in a testable business/domain layer, separate from UI formatting.
- Add tests for multiple receipts at different costs, unequal receipt quantities, stock-outs, zero-stock re-entry, returns/adjustments, decimal rounding, and offline persistence.
- Do not claim the costing engine is implemented or tested merely because this note exists.
- This decision does not authorize merging to `main`; continue work on the active feature branch unless explicitly instructed otherwise.

## Status

- **Decision:** WAC for now.
- **Implementation:** to be verified separately against the actual code and tests.
- **Policy review:** revisit before relying on reports for formal accounting or tax filings.
