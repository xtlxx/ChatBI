# Data Lineage & Impact Analysis Report

## 1. Schema Summary
- Total Tables: 484
- Total Views: 0
- Explicit Relationships: 0
- Implicit Relationships (inferred from comments): 2

## 2. High Risk Impact Analysis
The following fields are critical integration points. Modifications here require synchronized updates downstream.

### 🔴 Table: od_order_doc
**Impact Score**: 2 downstream dependencies.
**Affected Downstream Objects**:
- acc_product_shipment (order_seq->od_order_doc.seq)
- acc_reconciliation_detail (order_seq->od_order_doc.seq)

**Critical Columns (High Lineage Impact)**:
- `seq` (INT): Affects 2 downstream fields.

---
