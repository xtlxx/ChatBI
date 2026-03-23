# ChatBI 数据库 Schema 深度分析报告

## 📊 分析概述

- **数据库类型**: MySQL 8.0
- **表总数**: 484 张
- **业务核心表**: ~120 张（排除临时/备份/系统表后）
- **行业**: 鞋服制造 MES/ERP 系统

## 🏗️ 表分组架构

### 核心业务表（按前缀分类）

| 前缀 | 表数量 | 业务域 | 主键 | 软删除字段 |
|------|--------|--------|------|-----------|
| `acc_` | 5 | 应收账款/出货对账 | `seq` | `del_flag = '0'` |
| `bas_` | 25 | 基础数据（公司/客户/供应商） | `id` 或 `seq` | `is_delete = 0` |
| `od_` | 19 | 正式订单 & 生产订单 | `seq` | `is_deleted = 0` |
| `om_` | 41 | 产品资料/型体管理 | `seq` | `is_deleted = 0` |
| `proc_` | 65 | 采购/领料/仓储/品检 | `seq` | `is_deleted = 0` |
| `mat_` | 21 | 物料询价 | `seq` | `is_deleted = 0` |
| `mx_` | 15 | 物料分类/物料信息 | `id`/`seq` | 混合 |
| `store_` | 8 | 仓库/库存管理 | `id` | `is_deleted = '0'` |
| `sop_` | 28 | SOP 工艺管理 | `seq` | 混合 |
| `sample_` | 12 | 样品管理 | `id`/`seq` | 混合 |

### 非业务表（应排除）

| 前缀 | 表数量 | 用途 |
|------|--------|------|
| `act_` | 39 | Flowable 工作流引擎系统表 |
| `flw_` | 8 | Flowable 事件引擎 |
| `sz_` | 54 | 临时/中间表 |
| `tb_` | 4 | 未知临时表 |
| `*_copy1`/`*_bak1`/`*_日期后缀` | ~30 | 备份/副本表 |

## ⚠️ 软删除规则完整映射

### 规则 1: `del_flag = '0'` (char/int)
```
acc_product_shipment, acc_reconciliation, acc_reconciliation_deduction,
acc_reconciliation_deduction_attachment, acc_reconciliation_detail,
sop_manufacturing_process, sop_working_procedure, sop_workshop_section,
sys_user_copy1
```

### 规则 2: `is_delete = 0` (int)
```
bas_company*, bas_custom*, bas_supplier*, bas_supplier_attachment,
bas_supplier_bank, bas_supplier_contact,
batch_list, bill_setting, depm_prog*, formwork, knife,
material_batch*, material_receive*,
mx_material_attribute*, mx_material_class_attribute,
output_feedback, proc_material_list_prod*, procurement_sample,
purchases, stock*, storehouse
```

### 规则 3: `is_deleted = 0` (int/tinyint/char)
```
od_* (全部), proc_* (大部分), om_* (全部), mx_material_category*,
mx_material_info*, mx_material_outsouring*,
bas_money_type(!), bas_money_type_rate(!), bas_money_type_rate_history(!),
bas_unit_no(!),
store*, store_transfer*, customer, mat_price_inquiry*,
material_replenishment, material_return_materials*,
material_warehouse_out, omp_sys_coding*, position*,
sample_order*, sop_expand*, sop_operation_*, sop_page_setting,
sop_resource, sop_size_comparison, sop_sku_manufacturing_process,
sys_dict*, sys_process, t_material_ledger_info, t_standard_cost_budget,
pdm_roll_store, working_procedure
```

### 无软删除字段
265 张表无软删除字段，主要是系统表、子表和临时表。

## 🔗 表关系图

### 核心关系链

```
[订单全链路]
bas_custom.id → od_order_doc.customer_seq → od_order_doc_article.od_order_doc_seq
                                           → om_article.seq (via art_seq)
od_order_doc.seq → od_product_order_order.order_seq → od_product_order_doc.seq
od_order_doc.seq → acc_product_shipment.order_seq (出货)

[采购全链路]
proc_material_procurement → proc_material_procurement_info
                          → proc_material_list → proc_material_list_info
                          → proc_material_temporarily_receiving → proc_material_warehousing

[对账链路]
acc_reconciliation → acc_reconciliation_detail → od_order_doc
                   → acc_product_shipment

[产品资料]
om_article → om_art_position → om_art_position_material
           → om_aritcle_size → om_colour + om_colour_info

[物料体系]
mx_material_category → mx_material_info → mx_material_outsouring

[供应商对账]
proc_supplier_statement → proc_supplier_statement_info + proc_supplier_statement_deduction
```

## 🔧 已修正的问题

### 1. prompts.py - BUSINESS_LOGIC_NOTES (已修正)
- **问题**: 原始版本只有 2 条查询路径
- **修正**: 扩展到 8 大业务场景的完整表关系路径 + 软删除例外规则 + 备份表排除清单

### 2. prompts.py - SQL_GEN_SYSTEM (已修正)
- **问题**: 软删除规则不精确，缺少例外表说明
- **修正**: 
  - 增加了 `bas_money_type*` 用 `is_deleted` 的例外
  - 增加了 `sop_` 表混用 `del_flag` 的说明
  - 增加了 `store_*` 用 char 类型 `is_deleted` 的说明
  - 增加了备份表排除规则

### 3. 前端 ChartRenderer.tsx (已增强)
- 添加全屏查看、下载 PNG、刷新图表功能
- 添加暗色主题适配
- 添加图表配置验证和错误展示
- 添加 ESC 键退出全屏

### 4. 前端 SqlBlock.tsx (已增强)
- 添加内置 SQL 语法高亮（关键字/函数/字符串/数字/注释/标识符）
- 支持暗色模式
- 优化折叠动画和行数显示

### 5. 前端 ChatMessage.tsx (已优化)
- 调整展示顺序：思考 → SQL → 执行结果 → 分析内容 → 图表
- 增大图表容器高度从 h-64 到 h-80
- 本地化错误消息
- 添加渐变分隔线
