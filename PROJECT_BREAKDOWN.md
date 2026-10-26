# Grocery Business App — Complete Milestone Breakdown

**Last reviewed:** 2026-10-26

This document defines the complete milestone hierarchy for the Grocery Business App. The project is one shared business ecosystem with specialized interfaces, not a collection of unrelated apps.

## Architecture principles

- One shared business core.
- Consistent records for products, transactions, customer IDs, inventory, permissions, and audit trails.
- Android-first delivery, followed by web, then desktop.
- Traditional grocery operations come before advanced financial/crypto modules.
- Crypto modules must not delay or become dependencies of the ordinary grocery MVP.
- Features are considered complete only when implemented and verified with evidence.

---

## Phase 0 — Foundation & Engineering

### M0.1 — Repository foundation
- GitHub repository
- Flutter project
- Branch strategy
- Project documentation
- `PROJECT_STATUS.md`
- README
- `.gitignore`

### M0.2 — Build infrastructure
- Flutter CI
- Automated `flutter test`
- Android release build
- Split APK generation
- APK artifact retention
- Later: web build
- Later: desktop build

### M0.3 — Application architecture
- Shared business-core structure
- Feature/module boundaries
- Navigation architecture
- State management
- Error handling
- Configuration
- Environment separation

### M0.4 — Local data architecture
- SQLite integration
- Database initialization
- Schema versioning
- Migrations
- Repository/data-access layer
- Local transaction handling
- Backup/restore foundation

**Phase 0 exit:** Stable technical foundation for the grocery system.

---

## Phase 1 — Traditional Grocery MVP

**MVP goal:** One grocery shop can reliably sell products, maintain stock, record transactions, and operate offline from one Android device.

### M1.1 — Product Catalogue
- Product creation
- Product editing
- Product deactivation
- Product search
- Categories
- Units
- Selling price
- Cost price
- Product code/SKU
- Barcode field
- Product status

### M1.2 — Inventory
- Stock quantities
- Stock-in
- Stock-out
- Manual adjustment
- Stock movement history
- Low-stock threshold
- Low-stock alerts
- Inventory valuation foundation

### M1.3 — Basic POS
- Product selection
- Cart
- Quantity changes
- Remove item
- Subtotal
- Total
- Payment received
- Change calculation
- Complete sale
- Cancel sale

### M1.4 — Sales Transactions
Every completed transaction should have:
- Transaction ID
- Timestamp
- Items
- Quantities
- Prices
- Discounts, if applicable
- Total
- Payment method
- Amount received
- Change
- Staff/device information where applicable

### M1.5 — Transaction History
- Today's transactions
- Search transactions
- Transaction details
- Void/cancel handling
- Basic sales totals
- Daily sales summary

### M1.6 — Offline Operation
- Local product database
- Local inventory
- Local transactions
- Local customer records where applicable
- Local transaction IDs
- Recovery after app restart

### M1.7 — Basic Receipt
- Store information
- Transaction ID
- Date/time
- Items
- Quantities
- Prices
- Total
- Payment
- Change

Initially this may be a screen/PDF/shareable receipt before thermal printing becomes a dedicated milestone.

### M1.8 — MVP Validation
Validate the complete flow:

**Product → Stock → POS → Payment → Transaction → Inventory deduction → History**

**Phase 1 exit:** A small grocery store can record inventory and sales using one Android device, including offline operation.

---

## Phase 2 — Grocery Operations

### M2.1 — Purchasing
- Suppliers
- Purchase orders
- Purchase records
- Received stock
- Purchase cost
- Partial receiving
- Supplier history

### M2.2 — Inventory Management
- Stock adjustments
- Damaged goods
- Expired goods
- Returns
- Stock transfers
- Inventory counts
- Stock reconciliation

### M2.3 — Pricing
- Cost price
- Selling price
- Wholesale price
- Promotional price
- Effective dates
- Price history

### M2.4 — Discounts & Promotions
- Item discounts
- Percentage discounts
- Fixed discounts
- Promotional pricing
- Customer-specific promotions
- Exclusive-buyer promotions

### M2.5 — Returns
- Customer returns
- Supplier returns
- Returned quantity
- Refund/credit handling
- Inventory reversal

### M2.6 — Basic Reporting
- Daily sales
- Weekly sales
- Monthly sales
- Sales by product
- Sales by category
- Inventory report
- Low-stock report
- Purchase report
- Gross-margin estimate

---

## Phase 3 — Customer System

### M3.1 — Customer Accounts
- Customer ID
- Name
- Contact information
- Account status
- Transaction history

### M3.2 — Buyer Types
**Ordinary Buyer**
- Standard pricing
- Standard promotions
- Standard rewards

**Exclusive Buyer**
- Account-based benefits
- Exclusive pricing
- Exclusive promotions
- Additional rewards/entitlements

**Guest**
- A genuinely unidentified customer without an account.

### M3.3 — Customer Transaction Traceability
Where applicable:

**Customer ID + Transaction ID + timestamp + amount + items**

### M3.4 — Customer Rewards
- Points/rewards ledger
- Earn rules
- Redemption
- Reward history
- Expiration rules where applicable

---

## Phase 4 — POS / Staff Interface

### M4.1 — Staff Accounts
- Staff ID
- Login/authentication
- Roles
- Active/inactive status

### M4.2 — Permissions
Examples:
- Sell
- Discount
- Void
- Refund
- Inventory adjustment
- Price modification
- View reports
- Manage products

### M4.3 — Shift Management
- Clock-in
- Clock-out
- Opening cash
- Closing cash
- Cash movements
- Shift totals

### M4.4 — POS Audit Trail
Record:
- Who performed the action
- What changed
- When
- Transaction affected
- Previous value
- New value where applicable

---

## Phase 5 — Owner / Boss Interface

### M5.1 — Business Dashboard
- Sales today
- Sales this week
- Sales this month
- Inventory value
- Low-stock products
- Outstanding purchases
- Cash position

### M5.2 — Management Controls
- Product management
- Pricing
- Staff
- Customers
- Suppliers
- Promotions
- Business configuration

### M5.3 — Approval System
Potential owner approval for:
- Large discounts
- Refunds
- Voids
- Inventory adjustments
- Price changes
- Sensitive financial operations

---

## Phase 6 — Financial Reports & Accounting

### M6.1 — Sales Accounting
- Sales revenue
- Discounts
- Returns
- Net sales

### M6.2 — Cost Tracking
- Purchase costs
- Cost of goods sold
- Inventory valuation

### M6.3 — Profitability
- Gross sales
- Net sales
- COGS
- Gross profit
- Operating expenses
- Net income

### M6.4 — Cash Management
- Cash sales
- Cash withdrawals
- Cash deposits
- Cash adjustments
- Cash reconciliation

### M6.5 — Financial Reports
- Daily report
- Monthly report
- Profit/loss
- Cash-flow summary
- Inventory valuation
- Sales analysis

---

## Phase 7 — Inventory & Purchasing Management

### M7.1 — Supplier Management
- Supplier profiles
- Supplier contacts
- Supplier products
- Supplier pricing
- Supplier history

### M7.2 — Purchase Workflow
**Request → Purchase Order → Receive → Verify → Inventory Update → Payment**

### M7.3 — Reordering
- Minimum stock
- Reorder point
- Suggested quantities
- Supplier selection
- Purchase recommendations

### M7.4 — Inventory Intelligence
- Fast-moving products
- Slow-moving products
- Dead stock
- Stock aging
- Margin analysis

---

## Phase 8 — Payment & Settlement

### M8.1 — Payment Methods
- Cash
- Digital payment
- Bank/e-wallet records
- Other supported methods

### M8.2 — Payment Ledger
Every payment receives:
- Payment ID
- Transaction ID
- Amount
- Method
- Timestamp
- Status

### M8.3 — Settlement
- Pending
- Confirmed
- Failed
- Reversed
- Settled

### M8.4 — Reconciliation
**POS transactions ↔ payment records ↔ settlement records ↔ accounting records**

---

## Phase 9 — Compliance & Audit

### M9.1 — Audit Trail
Track sensitive business actions.

### M9.2 — Record Integrity
- Immutable transaction references
- Timestamping
- User attribution
- Change history

### M9.3 — Business Records
- Sales records
- Purchase records
- Inventory records
- Customer records
- Payment records
- Financial records

### M9.4 — Reporting / Export
- CSV
- Excel-compatible reports
- PDF reports
- Backup packages

---

## Phase 10 — Multi-Interface Ecosystem

The application becomes a unified grocery business ecosystem with specialized interfaces sharing the same business core.

### Customer Interface
- Account
- Purchases
- Rewards
- Promotions
- Exclusive benefits
- Payment options

### POS / Staff Interface
- Sales
- Inventory lookup
- Payments
- Returns
- Shifts

### Owner Interface
- Business dashboard
- Staff
- Customers
- Inventory
- Purchasing
- Financials

### Accounting Interface
- Revenue
- COGS
- Profit
- Cash
- Settlement
- Reports

### Inventory Interface
- Stock
- Suppliers
- Purchasing
- Receiving
- Reordering

### Compliance Interface
- Audit
- Records
- Permissions
- Reports
- Business history

### Payment Interface
- Payments
- Settlement
- Reconciliation
- Payment accounts

---

## Phase 11 — Web Version

Only after the Android MVP and operational foundation are stable.

### M11.1
- Web authentication
- Responsive interfaces
- Shared business database/API architecture
- Owner dashboard
- Reporting
- Customer portal

### M11.2
- Web POS
- Inventory management
- Purchasing
- Accounting
- Compliance

---

## Phase 12 — Desktop Version

After web.

Potential uses:
- Main office workstation
- Accounting
- Inventory management
- Reporting
- Owner dashboard
- Administrative operations

The desktop interface should emphasize large-screen workflows rather than simply copying mobile UI.

---

## Phase 13 — Advanced Payment / Crypto Layer

This layer is deliberately late. The traditional grocery business must work without it.

### M13.1 — Crypto Checkout
- Supported crypto asset
- Exchange-rate calculation
- Payment request
- Payment confirmation
- Transaction association

### M13.2 — Crypto Buyer Accounts
- Customer crypto account
- KYC where legally required
- Crypto transaction records
- Reward accounting

### M13.3 — Crypto Sponsorship / Funding
- Funding pools
- Sponsorship records
- Allocation tracking
- Business/customer separation

### M13.4 — Crypto Simple Earn Group
- Grocery sales → eligible net-income portion → crypto Earn allocation
- USDT rewards
- Category formulas
- PHP conversion
- Customer reward allocation
- Business yield allocation
- Queue settlement
- Separate emergency fund

The previously defined **“Mirror Amount, Different Purpose”** principle may be used as an accounting/allocation rule rather than being mixed into ordinary POS operations.

---

## Phase 14 — Business Ecosystem Optimization & Scale

### M14.1 — Analytics
- Business analytics
- Sales analytics
- Customer analytics
- Inventory analytics

### M14.2 — Automation
- Automated reorder recommendations
- Workflow automation
- Reporting automation

### M14.3 — Forecasting
- Demand forecasting
- Inventory forecasting
- Cash-flow forecasting

### M14.4 — Optimization
- Customer segmentation
- Promotion optimization
- Profitability analysis
- Inventory optimization

### M14.5 — Scale
- Multi-device synchronization
- Multi-store support
- Centralized business ecosystem

**Long-term progression:** One store → multiple devices → multiple stores → centralized business ecosystem.

---

# Master Roadmap

```text
GROCERY BUSINESS APP
│
├── 0. Foundation & Engineering
├── 1. TRADITIONAL GROCERY MVP ⭐
├── 2. Grocery Operations
├── 3. Customer System
├── 4. POS / Staff
├── 5. Owner / Boss
├── 6. Financial Reports & Accounting
├── 7. Inventory & Purchasing
├── 8. Payment & Settlement
├── 9. Compliance & Audit
├── 10. Multi-Interface Ecosystem
├── 11. Web
├── 12. Desktop
├── 13. Advanced Payment / Crypto
└── 14. Optimization & Scale
```

## Definition of MVP completion

The MVP is complete when a small grocery shop can reliably:

**Product → Stock → POS → Payment → Transaction → Inventory deduction → History**

using one Android device and continuing to operate offline.

The complete Grocery Business App is the larger ecosystem built progressively on that foundation:

**Grocery operations → Customers → Staff → Owner → Purchasing → Accounting → Payments → Compliance → Web → Desktop → Advanced financial/crypto services → Optimization and scale.**

This hierarchy is the project's roadmap; detailed implementation evidence belongs in `PROJECT_STATUS.md`, while code, commits, tests, and workflow runs remain the technical evidence.
