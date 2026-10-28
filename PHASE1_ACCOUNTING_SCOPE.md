# Grocery Business App — Phase 1 Accounting Scope

**Date:** 2026-10-28  
**Branch:** `feature/pos-cart-sales`  
**Status:** Scope defined; implementation pending

## Purpose

Define the minimum accounting foundation required for the traditional Android grocery MVP without turning Phase 1 into a full accounting package.

## Phase 1 accounting scope

### Required

1. **Sales totals** — derive revenue from completed transaction records; failed/cancelled checkouts are not revenue.
2. **Acquisition cost** — incoming inventory records actual acquisition/unit cost separately from selling price.
3. **Weighted Average Cost (WAC)** — receipts update weighted-average unit cost from existing inventory value plus incoming inventory cost.
4. **Inventory valuation** — on-hand quantity and current WAC provide the basis for inventory value.
5. **Cost of Goods Sold (COGS)** — completed sales use the applicable inventory cost and remain transactionally consistent with stock deduction.
6. **Gross profit** — sales revenue minus COGS.

### Deferred

- Full general ledger / double-entry accounting
- Tax filing or tax-compliance reports
- Payroll
- Accounts receivable/payable
- Supplier payment settlement
- Crypto accounting and settlement
- Advanced financial statements

### Decision still required

Operating-expense tracking and net-profit reporting are not assumed to be Phase 1 requirements until explicitly accepted.

## Dependency order

**Supplier/Purchase Receipt → Acquisition Cost → WAC → Inventory Value → COGS → Gross Profit**

## WAC acceptance requirements

Before WAC is marked implemented, tests must cover:

- first receipt into zero/empty stock
- second receipt at a different unit cost
- multiple receipts at different quantities and costs
- inventory reaching zero
- subsequent receipt after zero stock
- decimal/rounding policy
- persistence after restart
- sale deducting quantity and recording COGS consistently
- failed checkout leaving inventory value and COGS unchanged

## Current evidence

The existing app has product selling price, stock quantities, stock movements, completed sales, and atomic sale/stock transactions. Acquisition-cost/WAC/COGS implementation is not yet verified.
