CREATE DATABASE  IF NOT EXISTS `test` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `test`;
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: test
-- ------------------------------------------------------
-- Server version	8.0.43

--
-- Table structure for table `acc_product_shipment`
--

DROP TABLE IF EXISTS `acc_product_shipment`;

CREATE TABLE `acc_product_shipment` (
  `seq` int(18) unsigned zerofill NOT NULL AUTO_INCREMENT COMMENT 'id',
  `order_seq` int DEFAULT NULL COMMENT '正式订单号--od_order_doc.seq',
  `po_no` varchar(50) NOT NULL COMMENT '正式订单行号 po',
  `prou_order_seq` varchar(64) DEFAULT NULL COMMENT '生产指令号',
  `customer_id` int DEFAULT NULL COMMENT '客户Id',
  `customer_code` varchar(255) DEFAULT NULL COMMENT '客户编码',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号 ',
  `sku` varchar(64) DEFAULT NULL COMMENT 'sku',
  `basic_size_code` varchar(64) DEFAULT NULL COMMENT '尺码（基本码）',
  `art_quarter_code` varchar(64) DEFAULT NULL COMMENT '季度',
  `art_code` varchar(64) DEFAULT NULL COMMENT '工厂型体号',
  `art_name` varchar(64) DEFAULT NULL COMMENT '工厂型体名称',
  `art_color` varchar(50) DEFAULT NULL COMMENT '产品资料颜色序号',
  `art_color_name` varchar(50) DEFAULT NULL COMMENT '产品资料颜色名称',
  `warehouse` varchar(255) DEFAULT NULL COMMENT '配码收货地址',
  `shipment_quantity` decimal(18,0) DEFAULT NULL COMMENT '出货数量',
  `shipment_at` datetime DEFAULT NULL COMMENT '出货时间',
  `shipment_code` varchar(64) DEFAULT NULL COMMENT '出库单号',
  `delivery_code` varchar(64) DEFAULT NULL COMMENT '送货单号',
  `del_flag` char(1) DEFAULT '0' COMMENT '是否删除：0-否,1-是',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `is_available` char(1) DEFAULT '0' COMMENT '是否可用：0可用;1不可用',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  PRIMARY KEY (`seq`) USING BTREE,
  UNIQUE KEY `key` (`po_no`,`basic_size_code`,`shipment_code`,`shipment_at`,`prou_order_seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='成品出库信息表。mes同步资料';


--
-- Table structure for table `acc_reconciliation`
--

DROP TABLE IF EXISTS `acc_reconciliation`;

CREATE TABLE `acc_reconciliation` (
  `seq` bigint(18) unsigned zerofill NOT NULL AUTO_INCREMENT COMMENT 'seq',
  `bill_no` varchar(64) NOT NULL COMMENT '应收款对账单号',
  `customer_id` int DEFAULT NULL COMMENT '客户id',
  `customer_code` varchar(11) DEFAULT NULL COMMENT '客户编号',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `transaction_amount` decimal(18,2) DEFAULT NULL COMMENT '成交金额',
  `receivable_amount` decimal(18,0) DEFAULT NULL COMMENT '应收金额',
  `currency_type` varchar(10) DEFAULT NULL COMMENT '币种',
  `payment_type` varchar(255) DEFAULT NULL COMMENT '付款方式',
  `inventory_code` varchar(125) DEFAULT NULL COMMENT '出库单号',
  `accounting` datetime DEFAULT NULL COMMENT '取年月日2025-04-01，计算的是4月',
  `bank_card_no` varchar(255) DEFAULT NULL COMMENT '公司银行账号/来源 bas_company_bank',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `status` varchar(3) DEFAULT NULL COMMENT '状态',
  `is_available` char(1) DEFAULT '0' COMMENT '是否可用：0可用，1不可用',
  `del_flag` char(1) DEFAULT '0' COMMENT '是否删除：0-否,1-是',
  `created_by` varchar(64) DEFAULT '0' COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  `created_by_name` varchar(255) DEFAULT NULL COMMENT '创建人姓名',
  PRIMARY KEY (`seq`) USING BTREE,
  UNIQUE KEY `idx` (`bill_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='会计--对账表';


--
-- Table structure for table `acc_reconciliation_deduction`
--

DROP TABLE IF EXISTS `acc_reconciliation_deduction`;

CREATE TABLE `acc_reconciliation_deduction` (
  `seq` bigint NOT NULL AUTO_INCREMENT COMMENT '扣款序号',
  `acc_reconciliation_seq` bigint NOT NULL COMMENT '表头seq',
  `parent_bill_no` varchar(64) NOT NULL COMMENT '对账单号',
  `deduction_item` varchar(11) DEFAULT NULL COMMENT '扣款项目',
  `deduction_amount` decimal(11,2) DEFAULT NULL COMMENT '扣款金额',
  `is_first` char(1) DEFAULT '0' COMMENT '是否先扣款再扣: 0-先扣，1-后扣',
  `remark` varchar(1000) DEFAULT NULL COMMENT '扣款说明',
  `del_flag` char(1) DEFAULT '0' COMMENT '是否删除：0-否,1-是',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_available` char(1) DEFAULT '0' COMMENT '是否可用：0-可用,1-不可用',
  PRIMARY KEY (`seq`) USING BTREE,
  UNIQUE KEY `idx1` (`parent_bill_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='会计--扣款';


--
-- Table structure for table `acc_reconciliation_deduction_attachment`
--

DROP TABLE IF EXISTS `acc_reconciliation_deduction_attachment`;

CREATE TABLE `acc_reconciliation_deduction_attachment` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `acc_reconciliation_seq` int DEFAULT NULL COMMENT '应付对账表主键',
  `acc_reconciliation_deduction_seq` int DEFAULT NULL COMMENT '应付对账扣款主键',
  `attachment` varchar(2000) DEFAULT NULL COMMENT '附件',
  `attachment_name` varchar(200) DEFAULT NULL COMMENT '附件名称',
  `del_flag` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='供应商对账扣款费用附件';


--
-- Table structure for table `acc_reconciliation_detail`
--

DROP TABLE IF EXISTS `acc_reconciliation_detail`;

CREATE TABLE `acc_reconciliation_detail` (
  `seq` bigint(11) unsigned zerofill NOT NULL AUTO_INCREMENT COMMENT 'id',
  `acc_reconciliation_seq` int DEFAULT NULL COMMENT '表头seq',
  `parent_bill_no` varchar(64) DEFAULT NULL COMMENT '应收款对账单号，父级',
  `acc_product_shipment_seq` int DEFAULT NULL COMMENT '成品出库seq',
  `order_seq` int DEFAULT NULL COMMENT '正式订单号--od_order_doc.seq',
  `po_no` varchar(255) DEFAULT NULL COMMENT '正式订单行号',
  `prou_order_seq` varchar(255) DEFAULT NULL COMMENT '生产指令号',
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号 ',
  `sku` varchar(64) DEFAULT NULL COMMENT 'sku',
  `customer_id` int DEFAULT NULL COMMENT '客户id',
  `customer_code` varchar(255) DEFAULT NULL COMMENT '客户编码',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `art_code` varchar(255) DEFAULT NULL COMMENT '工厂型体号',
  `art_name` varchar(255) DEFAULT NULL COMMENT '工厂型体名称',
  `basic_size_code` varchar(255) DEFAULT NULL COMMENT '尺码（基本码）',
  `art_quarter_code` varchar(255) DEFAULT NULL COMMENT '季度',
  `art_color` varchar(255) DEFAULT NULL COMMENT '产品资料颜色序号',
  `art_color_name` varchar(255) DEFAULT NULL COMMENT '产品资料颜色名称',
  `warehouse` varchar(255) DEFAULT NULL COMMENT '配码收货地址',
  `shipment_quantity` decimal(18,0) DEFAULT NULL COMMENT '出货数量',
  `shipment_at` datetime DEFAULT NULL COMMENT '出货时间',
  `shipment_code` varchar(64) DEFAULT NULL COMMENT '出库单号',
  `delivery_code` varchar(255) DEFAULT NULL COMMENT '送货单号',
  `reconciliation_quantity` decimal(18,0) DEFAULT NULL COMMENT '对账数量；出货数量',
  `reconciliation_price` decimal(18,2) DEFAULT NULL COMMENT '对账单价;   客户报价',
  `settlement_quantity` decimal(18,0) DEFAULT NULL COMMENT '结算数量；页面修改',
  `settlement_price` decimal(18,2) DEFAULT NULL COMMENT '结算单价；页面修改',
  `settlement_amount` decimal(18,2) DEFAULT NULL COMMENT '金额； 结算数量*结算单价',
  `del_flag` char(1) DEFAULT '0' COMMENT '是否删除：0-否,1-是',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_available` char(1) DEFAULT '0' COMMENT '是否可用：0-可用,1-不可用',
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  UNIQUE KEY `id1` (`parent_bill_no`,`order_seq`,`po_no`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='会计--对账表明细';


--
-- Table structure for table `act_evt_log`
--

DROP TABLE IF EXISTS `act_evt_log`;

CREATE TABLE `act_evt_log` (
  `LOG_NR_` bigint NOT NULL AUTO_INCREMENT,
  `TYPE_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TIME_STAMP_` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DATA_` longblob,
  `LOCK_OWNER_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `LOCK_TIME_` timestamp(3) NULL DEFAULT NULL,
  `IS_PROCESSED_` tinyint DEFAULT '0',
  PRIMARY KEY (`LOG_NR_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ge_bytearray`
--

DROP TABLE IF EXISTS `act_ge_bytearray`;

CREATE TABLE `act_ge_bytearray` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `BYTES_` longblob,
  `GENERATED_` tinyint DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_FK_BYTEARR_DEPL` (`DEPLOYMENT_ID_`),
  CONSTRAINT `ACT_FK_BYTEARR_DEPL` FOREIGN KEY (`DEPLOYMENT_ID_`) REFERENCES `act_re_deployment` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Table structure for table `act_ge_property`
--

DROP TABLE IF EXISTS `act_ge_property`;


CREATE TABLE `act_ge_property` (
  `NAME_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `VALUE_` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REV_` int DEFAULT NULL,
  PRIMARY KEY (`NAME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Table structure for table `act_hi_actinst`
--

DROP TABLE IF EXISTS `act_hi_actinst`;


CREATE TABLE `act_hi_actinst` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `ACT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CALL_PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `ASSIGNEE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `START_TIME_` datetime(3) NOT NULL,
  `END_TIME_` datetime(3) DEFAULT NULL,
  `TRANSACTION_ORDER_` int DEFAULT NULL,
  `DURATION_` bigint DEFAULT NULL,
  `DELETE_REASON_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_ACT_INST_START` (`START_TIME_`),
  KEY `ACT_IDX_HI_ACT_INST_END` (`END_TIME_`),
  KEY `ACT_IDX_HI_ACT_INST_PROCINST` (`PROC_INST_ID_`,`ACT_ID_`),
  KEY `ACT_IDX_HI_ACT_INST_EXEC` (`EXECUTION_ID_`,`ACT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Table structure for table `act_hi_attachment`
--

DROP TABLE IF EXISTS `act_hi_attachment`;


CREATE TABLE `act_hi_attachment` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DESCRIPTION_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `URL_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CONTENT_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TIME_` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Table structure for table `act_hi_comment`
--

DROP TABLE IF EXISTS `act_hi_comment`;


CREATE TABLE `act_hi_comment` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TIME_` datetime(3) NOT NULL,
  `USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ACTION_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MESSAGE_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `FULL_MSG_` longblob,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Table structure for table `act_hi_detail`
--

DROP TABLE IF EXISTS `act_hi_detail`;

CREATE TABLE `act_hi_detail` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `VAR_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REV_` int DEFAULT NULL,
  `TIME_` datetime(3) NOT NULL,
  `BYTEARRAY_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DOUBLE_` double DEFAULT NULL,
  `LONG_` bigint DEFAULT NULL,
  `TEXT_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TEXT2_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_DETAIL_PROC_INST` (`PROC_INST_ID_`),
  KEY `ACT_IDX_HI_DETAIL_ACT_INST` (`ACT_INST_ID_`),
  KEY `ACT_IDX_HI_DETAIL_TIME` (`TIME_`),
  KEY `ACT_IDX_HI_DETAIL_NAME` (`NAME_`),
  KEY `ACT_IDX_HI_DETAIL_TASK_ID` (`TASK_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_hi_entitylink`
--

DROP TABLE IF EXISTS `act_hi_entitylink`;

CREATE TABLE `act_hi_entitylink` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `LINK_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_ELEMENT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HIERARCHY_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_ENT_LNK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_HI_ENT_LNK_REF_SCOPE` (`REF_SCOPE_ID_`,`REF_SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_HI_ENT_LNK_ROOT_SCOPE` (`ROOT_SCOPE_ID_`,`ROOT_SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_HI_ENT_LNK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`,`LINK_TYPE_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_hi_identitylink`
--

DROP TABLE IF EXISTS `act_hi_identitylink`;

CREATE TABLE `act_hi_identitylink` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `GROUP_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_IDENT_LNK_USER` (`USER_ID_`),
  KEY `ACT_IDX_HI_IDENT_LNK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_IDENT_LNK_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_IDENT_LNK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_IDENT_LNK_TASK` (`TASK_ID_`),
  KEY `ACT_IDX_HI_IDENT_LNK_PROCINST` (`PROC_INST_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_hi_procinst`
--

DROP TABLE IF EXISTS `act_hi_procinst`;

CREATE TABLE `act_hi_procinst` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `BUSINESS_KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `START_TIME_` datetime(3) NOT NULL,
  `END_TIME_` datetime(3) DEFAULT NULL,
  `DURATION_` bigint DEFAULT NULL,
  `START_USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `START_ACT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `END_ACT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUPER_PROCESS_INSTANCE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DELETE_REASON_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CALLBACK_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CALLBACK_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REFERENCE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REFERENCE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROPAGATED_STAGE_INST_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `BUSINESS_STATUS_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `PROC_INST_ID_` (`PROC_INST_ID_`),
  KEY `ACT_IDX_HI_PRO_INST_END` (`END_TIME_`),
  KEY `ACT_IDX_HI_PRO_I_BUSKEY` (`BUSINESS_KEY_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_hi_taskinst`
--

DROP TABLE IF EXISTS `act_hi_taskinst`;

CREATE TABLE `act_hi_taskinst` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_DEF_KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROPAGATED_STAGE_INST_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DESCRIPTION_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `OWNER_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ASSIGNEE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `START_TIME_` datetime(3) NOT NULL,
  `CLAIM_TIME_` datetime(3) DEFAULT NULL,
  `END_TIME_` datetime(3) DEFAULT NULL,
  `DURATION_` bigint DEFAULT NULL,
  `DELETE_REASON_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PRIORITY_` int DEFAULT NULL,
  `DUE_DATE_` datetime(3) DEFAULT NULL,
  `FORM_KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  `LAST_UPDATED_TIME_` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_TASK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_TASK_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_TASK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_TASK_INST_PROCINST` (`PROC_INST_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_hi_tsk_log`
--

DROP TABLE IF EXISTS `act_hi_tsk_log`;

CREATE TABLE `act_hi_tsk_log` (
  `ID_` bigint NOT NULL AUTO_INCREMENT,
  `TYPE_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `TIME_STAMP_` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DATA_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_hi_varinst`
--

DROP TABLE IF EXISTS `act_hi_varinst`;

CREATE TABLE `act_hi_varinst` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `VAR_TYPE_` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `BYTEARRAY_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DOUBLE_` double DEFAULT NULL,
  `LONG_` bigint DEFAULT NULL,
  `TEXT_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TEXT2_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `LAST_UPDATED_TIME_` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_PROCVAR_NAME_TYPE` (`NAME_`,`VAR_TYPE_`),
  KEY `ACT_IDX_HI_VAR_SCOPE_ID_TYPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_VAR_SUB_ID_TYPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_PROCVAR_PROC_INST` (`PROC_INST_ID_`),
  KEY `ACT_IDX_HI_PROCVAR_TASK_ID` (`TASK_ID_`),
  KEY `ACT_IDX_HI_PROCVAR_EXE` (`EXECUTION_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_id_bytearray`
--

DROP TABLE IF EXISTS `act_id_bytearray`;

CREATE TABLE `act_id_bytearray` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `BYTES_` longblob,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_id_group`
--

DROP TABLE IF EXISTS `act_id_group`;


CREATE TABLE `act_id_group` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_id_info`
--

DROP TABLE IF EXISTS `act_id_info`;

CREATE TABLE `act_id_info` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `USER_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `VALUE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PASSWORD_` longblob,
  `PARENT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_id_membership`
--

DROP TABLE IF EXISTS `act_id_membership`;

CREATE TABLE `act_id_membership` (
  `USER_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `GROUP_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`USER_ID_`,`GROUP_ID_`),
  KEY `ACT_FK_MEMB_GROUP` (`GROUP_ID_`),
  CONSTRAINT `ACT_FK_MEMB_GROUP` FOREIGN KEY (`GROUP_ID_`) REFERENCES `act_id_group` (`ID_`),
  CONSTRAINT `ACT_FK_MEMB_USER` FOREIGN KEY (`USER_ID_`) REFERENCES `act_id_user` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_id_priv`
--

DROP TABLE IF EXISTS `act_id_priv`;


CREATE TABLE `act_id_priv` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_UNIQ_PRIV_NAME` (`NAME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_id_priv_mapping`
--

DROP TABLE IF EXISTS `act_id_priv_mapping`;


CREATE TABLE `act_id_priv_mapping` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `PRIV_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `GROUP_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_FK_PRIV_MAPPING` (`PRIV_ID_`),
  KEY `ACT_IDX_PRIV_USER` (`USER_ID_`),
  KEY `ACT_IDX_PRIV_GROUP` (`GROUP_ID_`),
  CONSTRAINT `ACT_FK_PRIV_MAPPING` FOREIGN KEY (`PRIV_ID_`) REFERENCES `act_id_priv` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_id_property`
--

DROP TABLE IF EXISTS `act_id_property`;


CREATE TABLE `act_id_property` (
  `NAME_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `VALUE_` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REV_` int DEFAULT NULL,
  PRIMARY KEY (`NAME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_id_token`
--

DROP TABLE IF EXISTS `act_id_token`;


CREATE TABLE `act_id_token` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `TOKEN_VALUE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TOKEN_DATE_` timestamp(3) NULL DEFAULT NULL,
  `IP_ADDRESS_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `USER_AGENT_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TOKEN_DATA_` varchar(2000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_id_user`
--

DROP TABLE IF EXISTS `act_id_user`;


CREATE TABLE `act_id_user` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `FIRST_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `LAST_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DISPLAY_NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EMAIL_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PWD_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PICTURE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_procdef_info`
--

DROP TABLE IF EXISTS `act_procdef_info`;


CREATE TABLE `act_procdef_info` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `INFO_JSON_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_UNIQ_INFO_PROCDEF` (`PROC_DEF_ID_`),
  KEY `ACT_IDX_INFO_PROCDEF` (`PROC_DEF_ID_`),
  KEY `ACT_FK_INFO_JSON_BA` (`INFO_JSON_ID_`),
  CONSTRAINT `ACT_FK_INFO_JSON_BA` FOREIGN KEY (`INFO_JSON_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_INFO_PROCDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_re_deployment`
--

DROP TABLE IF EXISTS `act_re_deployment`;


CREATE TABLE `act_re_deployment` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  `DEPLOY_TIME_` timestamp(3) NULL DEFAULT NULL,
  `DERIVED_FROM_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DERIVED_FROM_ROOT_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_DEPLOYMENT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ENGINE_VERSION_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_re_model`
--

DROP TABLE IF EXISTS `act_re_model`;


CREATE TABLE `act_re_model` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LAST_UPDATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `VERSION_` int DEFAULT NULL,
  `META_INFO_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EDITOR_SOURCE_VALUE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EDITOR_SOURCE_EXTRA_VALUE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_FK_MODEL_SOURCE` (`EDITOR_SOURCE_VALUE_ID_`),
  KEY `ACT_FK_MODEL_SOURCE_EXTRA` (`EDITOR_SOURCE_EXTRA_VALUE_ID_`),
  KEY `ACT_FK_MODEL_DEPLOYMENT` (`DEPLOYMENT_ID_`),
  CONSTRAINT `ACT_FK_MODEL_DEPLOYMENT` FOREIGN KEY (`DEPLOYMENT_ID_`) REFERENCES `act_re_deployment` (`ID_`),
  CONSTRAINT `ACT_FK_MODEL_SOURCE` FOREIGN KEY (`EDITOR_SOURCE_VALUE_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_MODEL_SOURCE_EXTRA` FOREIGN KEY (`EDITOR_SOURCE_EXTRA_VALUE_ID_`) REFERENCES `act_ge_bytearray` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_re_procdef`
--

DROP TABLE IF EXISTS `act_re_procdef`;


CREATE TABLE `act_re_procdef` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `VERSION_` int NOT NULL,
  `DEPLOYMENT_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `RESOURCE_NAME_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DGRM_RESOURCE_NAME_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DESCRIPTION_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HAS_START_FORM_KEY_` tinyint DEFAULT NULL,
  `HAS_GRAPHICAL_NOTATION_` tinyint DEFAULT NULL,
  `SUSPENSION_STATE_` int DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  `ENGINE_VERSION_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DERIVED_FROM_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DERIVED_FROM_ROOT_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DERIVED_VERSION_` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_UNIQ_PROCDEF` (`KEY_`,`VERSION_`,`DERIVED_VERSION_`,`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_actinst`
--

DROP TABLE IF EXISTS `act_ru_actinst`;


CREATE TABLE `act_ru_actinst` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `ACT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CALL_PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `ASSIGNEE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `START_TIME_` datetime(3) NOT NULL,
  `END_TIME_` datetime(3) DEFAULT NULL,
  `DURATION_` bigint DEFAULT NULL,
  `TRANSACTION_ORDER_` int DEFAULT NULL,
  `DELETE_REASON_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_RU_ACTI_START` (`START_TIME_`),
  KEY `ACT_IDX_RU_ACTI_END` (`END_TIME_`),
  KEY `ACT_IDX_RU_ACTI_PROC` (`PROC_INST_ID_`),
  KEY `ACT_IDX_RU_ACTI_PROC_ACT` (`PROC_INST_ID_`,`ACT_ID_`),
  KEY `ACT_IDX_RU_ACTI_EXEC` (`EXECUTION_ID_`),
  KEY `ACT_IDX_RU_ACTI_EXEC_ACT` (`EXECUTION_ID_`,`ACT_ID_`),
  KEY `ACT_IDX_RU_ACTI_TASK` (`TASK_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_deadletter_job`
--

DROP TABLE IF EXISTS `act_ru_deadletter_job`;


CREATE TABLE `act_ru_deadletter_job` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_DEADLETTER_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_DEADLETTER_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_DEADLETTER_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_DJOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_DJOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_DJOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_DEADLETTER_JOB_EXECUTION` (`EXECUTION_ID_`),
  KEY `ACT_FK_DEADLETTER_JOB_PROCESS_INSTANCE` (`PROCESS_INSTANCE_ID_`),
  KEY `ACT_FK_DEADLETTER_JOB_PROC_DEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_EXECUTION` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_PROC_DEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_PROCESS_INSTANCE` FOREIGN KEY (`PROCESS_INSTANCE_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_entitylink`
--

DROP TABLE IF EXISTS `act_ru_entitylink`;


CREATE TABLE `act_ru_entitylink` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `LINK_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_ELEMENT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HIERARCHY_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_ENT_LNK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_ENT_LNK_REF_SCOPE` (`REF_SCOPE_ID_`,`REF_SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_ENT_LNK_ROOT_SCOPE` (`ROOT_SCOPE_ID_`,`ROOT_SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_ENT_LNK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`,`LINK_TYPE_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_event_subscr`
--

DROP TABLE IF EXISTS `act_ru_event_subscr`;


CREATE TABLE `act_ru_event_subscr` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `EVENT_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `EVENT_NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ACTIVITY_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CONFIGURATION_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATED_` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_EVENT_SUBSCR_CONFIG_` (`CONFIGURATION_`),
  KEY `ACT_FK_EVENT_EXEC` (`EXECUTION_ID_`),
  CONSTRAINT `ACT_FK_EVENT_EXEC` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_execution`
--

DROP TABLE IF EXISTS `act_ru_execution`;


CREATE TABLE `act_ru_execution` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `BUSINESS_KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUPER_EXEC_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `IS_ACTIVE_` tinyint DEFAULT NULL,
  `IS_CONCURRENT_` tinyint DEFAULT NULL,
  `IS_SCOPE_` tinyint DEFAULT NULL,
  `IS_EVENT_SCOPE_` tinyint DEFAULT NULL,
  `IS_MI_ROOT_` tinyint DEFAULT NULL,
  `SUSPENSION_STATE_` int DEFAULT NULL,
  `CACHED_ENT_STATE_` int DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `START_ACT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `START_TIME_` datetime(3) DEFAULT NULL,
  `START_USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `LOCK_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `IS_COUNT_ENABLED_` tinyint DEFAULT NULL,
  `EVT_SUBSCR_COUNT_` int DEFAULT NULL,
  `TASK_COUNT_` int DEFAULT NULL,
  `JOB_COUNT_` int DEFAULT NULL,
  `TIMER_JOB_COUNT_` int DEFAULT NULL,
  `SUSP_JOB_COUNT_` int DEFAULT NULL,
  `DEADLETTER_JOB_COUNT_` int DEFAULT NULL,
  `EXTERNAL_WORKER_JOB_COUNT_` int DEFAULT NULL,
  `VAR_COUNT_` int DEFAULT NULL,
  `ID_LINK_COUNT_` int DEFAULT NULL,
  `CALLBACK_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CALLBACK_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REFERENCE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `REFERENCE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROPAGATED_STAGE_INST_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `BUSINESS_STATUS_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_EXEC_BUSKEY` (`BUSINESS_KEY_`),
  KEY `ACT_IDC_EXEC_ROOT` (`ROOT_PROC_INST_ID_`),
  KEY `ACT_IDX_EXEC_REF_ID_` (`REFERENCE_ID_`),
  KEY `ACT_FK_EXE_PROCINST` (`PROC_INST_ID_`),
  KEY `ACT_FK_EXE_PARENT` (`PARENT_ID_`),
  KEY `ACT_FK_EXE_SUPER` (`SUPER_EXEC_`),
  KEY `ACT_FK_EXE_PROCDEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_EXE_PARENT` FOREIGN KEY (`PARENT_ID_`) REFERENCES `act_ru_execution` (`ID_`) ON DELETE CASCADE,
  CONSTRAINT `ACT_FK_EXE_PROCDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_EXE_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ACT_FK_EXE_SUPER` FOREIGN KEY (`SUPER_EXEC_`) REFERENCES `act_ru_execution` (`ID_`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_external_job`
--

DROP TABLE IF EXISTS `act_ru_external_job`;


CREATE TABLE `act_ru_external_job` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `LOCK_EXP_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_EXTERNAL_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_EXTERNAL_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_EXTERNAL_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_EJOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_EJOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_EJOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  CONSTRAINT `ACT_FK_EXTERNAL_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_EXTERNAL_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_history_job`
--

DROP TABLE IF EXISTS `act_ru_history_job`;


CREATE TABLE `act_ru_history_job` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `LOCK_EXP_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ADV_HANDLER_CFG_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_identitylink`
--

DROP TABLE IF EXISTS `act_ru_identitylink`;


CREATE TABLE `act_ru_identitylink` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `GROUP_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `USER_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_IDENT_LNK_USER` (`USER_ID_`),
  KEY `ACT_IDX_IDENT_LNK_GROUP` (`GROUP_ID_`),
  KEY `ACT_IDX_IDENT_LNK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_IDENT_LNK_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_IDENT_LNK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_ATHRZ_PROCEDEF` (`PROC_DEF_ID_`),
  KEY `ACT_FK_TSKASS_TASK` (`TASK_ID_`),
  KEY `ACT_FK_IDL_PROCINST` (`PROC_INST_ID_`),
  CONSTRAINT `ACT_FK_ATHRZ_PROCEDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_IDL_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_TSKASS_TASK` FOREIGN KEY (`TASK_ID_`) REFERENCES `act_ru_task` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_job`
--

DROP TABLE IF EXISTS `act_ru_job`;


CREATE TABLE `act_ru_job` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `LOCK_EXP_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_JOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_JOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_JOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_JOB_EXECUTION` (`EXECUTION_ID_`),
  KEY `ACT_FK_JOB_PROCESS_INSTANCE` (`PROCESS_INSTANCE_ID_`),
  KEY `ACT_FK_JOB_PROC_DEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_JOB_EXECUTION` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_JOB_PROC_DEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_JOB_PROCESS_INSTANCE` FOREIGN KEY (`PROCESS_INSTANCE_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_suspended_job`
--

DROP TABLE IF EXISTS `act_ru_suspended_job`;


CREATE TABLE `act_ru_suspended_job` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_SUSPENDED_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_SUSPENDED_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_SUSPENDED_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_SJOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_SJOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_SJOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_SUSPENDED_JOB_EXECUTION` (`EXECUTION_ID_`),
  KEY `ACT_FK_SUSPENDED_JOB_PROCESS_INSTANCE` (`PROCESS_INSTANCE_ID_`),
  KEY `ACT_FK_SUSPENDED_JOB_PROC_DEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_EXECUTION` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_PROC_DEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_PROCESS_INSTANCE` FOREIGN KEY (`PROCESS_INSTANCE_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_task`
--

DROP TABLE IF EXISTS `act_ru_task`;


CREATE TABLE `act_ru_task` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROPAGATED_STAGE_INST_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DESCRIPTION_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_DEF_KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `OWNER_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ASSIGNEE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DELEGATION_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PRIORITY_` int DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `DUE_DATE_` datetime(3) DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUSPENSION_STATE_` int DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  `FORM_KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CLAIM_TIME_` datetime(3) DEFAULT NULL,
  `IS_COUNT_ENABLED_` tinyint DEFAULT NULL,
  `VAR_COUNT_` int DEFAULT NULL,
  `ID_LINK_COUNT_` int DEFAULT NULL,
  `SUB_TASK_COUNT_` int DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_TASK_CREATE` (`CREATE_TIME_`),
  KEY `ACT_IDX_TASK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_TASK_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_TASK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_TASK_EXE` (`EXECUTION_ID_`),
  KEY `ACT_FK_TASK_PROCINST` (`PROC_INST_ID_`),
  KEY `ACT_FK_TASK_PROCDEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_TASK_EXE` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_TASK_PROCDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_TASK_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_timer_job`
--

DROP TABLE IF EXISTS `act_ru_timer_job`;


CREATE TABLE `act_ru_timer_job` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `LOCK_EXP_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_TIMER_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_TIMER_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_TIMER_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_TIMER_JOB_DUEDATE` (`DUEDATE_`),
  KEY `ACT_IDX_TJOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_TJOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_TJOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_TIMER_JOB_EXECUTION` (`EXECUTION_ID_`),
  KEY `ACT_FK_TIMER_JOB_PROCESS_INSTANCE` (`PROCESS_INSTANCE_ID_`),
  KEY `ACT_FK_TIMER_JOB_PROC_DEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_EXECUTION` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_PROC_DEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_PROCESS_INSTANCE` FOREIGN KEY (`PROCESS_INSTANCE_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `act_ru_variable`
--

DROP TABLE IF EXISTS `act_ru_variable`;


CREATE TABLE `act_ru_variable` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `NAME_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `EXECUTION_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `BYTEARRAY_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `DOUBLE_` double DEFAULT NULL,
  `LONG_` bigint DEFAULT NULL,
  `TEXT_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TEXT2_` varchar(4000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_RU_VAR_SCOPE_ID_TYPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_RU_VAR_SUB_ID_TYPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_VAR_BYTEARRAY` (`BYTEARRAY_ID_`),
  KEY `ACT_IDX_VARIABLE_TASK_ID` (`TASK_ID_`),
  KEY `ACT_FK_VAR_EXE` (`EXECUTION_ID_`),
  KEY `ACT_FK_VAR_PROCINST` (`PROC_INST_ID_`),
  CONSTRAINT `ACT_FK_VAR_BYTEARRAY` FOREIGN KEY (`BYTEARRAY_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_VAR_EXE` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_VAR_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `andy_test`
--

DROP TABLE IF EXISTS `andy_test`;


CREATE TABLE `andy_test` (
  `sku` varchar(255) DEFAULT NULL COMMENT 'Stock Keeping Unit',
  `po` varchar(255) DEFAULT NULL COMMENT 'Purchase Order'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='This table stores SKU and PO information';


--
-- Table structure for table `anta_bom_api`
--

DROP TABLE IF EXISTS `anta_bom_api`;


CREATE TABLE `anta_bom_api` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `business_no` varchar(100) DEFAULT NULL,
  `encrypted_type` varchar(100) DEFAULT NULL,
  `interface_code` varchar(100) DEFAULT NULL,
  `req_time` varchar(100) DEFAULT NULL,
  `target_system` varchar(100) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=557 DEFAULT CHARSET=utf8mb3 COMMENT='安踏bom  api接口';


--
-- Table structure for table `anta_bom_api_info`
--

DROP TABLE IF EXISTS `anta_bom_api_info`;


CREATE TABLE `anta_bom_api_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `anta_bom_api_seq` int DEFAULT NULL,
  `business_key` varchar(200) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=694 DEFAULT CHARSET=utf8mb3 COMMENT='安踏bom api接口信息';


--
-- Table structure for table `anta_bom_combination_detail`
--

DROP TABLE IF EXISTS `anta_bom_combination_detail`;


CREATE TABLE `anta_bom_combination_detail` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `anta_bom_api_seq` int DEFAULT NULL COMMENT 'api接口seq',
  `anta_bom_api_info_seq` int DEFAULT NULL COMMENT 'api接口信息seq',
  `anta_bom_list_info_seq` int DEFAULT NULL COMMENT 'bom清单主表seq',
  `create_user_id` varchar(50) DEFAULT NULL COMMENT '创建人ID',
  `modify_user_id` varchar(50) DEFAULT NULL COMMENT '修改人id',
  `create_user_name` varchar(50) DEFAULT NULL COMMENT '创建人姓名',
  `modify_user_name` varchar(50) DEFAULT NULL COMMENT '修改人姓名',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL COMMENT '同步时间',
  `is_delete` int DEFAULT NULL COMMENT '是否删除',
  `constituteitemno` varchar(50) DEFAULT NULL COMMENT '组合编码',
  `skucode` varchar(50) DEFAULT NULL COMMENT ' 货号',
  `compositetype` varchar(50) DEFAULT NULL COMMENT '组合类型',
  `version` int DEFAULT NULL COMMENT '版本号',
  `bomversionnumber` varchar(50) DEFAULT NULL COMMENT 'BOM版本号',
  `bomarea` varchar(50) DEFAULT NULL COMMENT 'BOM区域',
  `remarks` varchar(255) DEFAULT NULL,
  `id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='安踏bom 订单组合表';


--
-- Table structure for table `anta_bom_detail_info`
--

DROP TABLE IF EXISTS `anta_bom_detail_info`;


CREATE TABLE `anta_bom_detail_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `anta_bom_api_seq` int DEFAULT NULL COMMENT 'api接口seq',
  `anta_bom_api_info_seq` int DEFAULT NULL COMMENT 'api接口信息seq',
  `anta_bom_list_info_seq` int DEFAULT NULL COMMENT 'bom清单主表seq',
  `create_user_id` varchar(255) DEFAULT NULL COMMENT '创建人ID',
  `modify_user_id` varchar(255) DEFAULT NULL COMMENT '修改人id',
  `create_user_name` varchar(255) DEFAULT NULL COMMENT '创建人姓名',
  `modify_user_name` varchar(255) DEFAULT NULL COMMENT '修改人姓名',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_time` datetime DEFAULT NULL,
  `is_delete` int DEFAULT NULL COMMENT '是否删除',
  `created_at` datetime DEFAULT NULL COMMENT '同步时间',
  `bomdetailinfoid_str` varchar(255) DEFAULT NULL,
  `wide_unit` varchar(255) DEFAULT NULL,
  `thickness` varchar(255) DEFAULT NULL COMMENT '厚度',
  `constituteitemno` varchar(255) DEFAULT NULL COMMENT '组合明细编码',
  `processtype` varchar(255) DEFAULT NULL,
  `changefield` varchar(500) DEFAULT NULL,
  `materialmiddletype` varchar(255) DEFAULT NULL,
  `itemcategory` varchar(255) DEFAULT NULL,
  `collocationtype` varchar(255) DEFAULT NULL,
  `edit_vendor` tinyint DEFAULT NULL,
  `bomno` varchar(255) DEFAULT NULL COMMENT '大底编号',
  `zmatcate` varchar(255) DEFAULT NULL,
  `workmanship_name` varchar(255) DEFAULT NULL,
  `sourcetype` varchar(255) DEFAULT NULL,
  `modifyflag` varchar(255) DEFAULT NULL,
  `constitutepartno` varchar(255) DEFAULT NULL COMMENT '部位组合编码',
  `solestype` varchar(255) DEFAULT NULL,
  `partno` varchar(255) DEFAULT NULL COMMENT '部位编码',
  `partname` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `foamtype` varchar(255) DEFAULT NULL,
  `vendercode` varchar(255) DEFAULT NULL COMMENT '供应商',
  `param_sort_by` varchar(255) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `version` int DEFAULT NULL,
  `hardness` varchar(255) DEFAULT NULL,
  `materialbigtype` varchar(255) DEFAULT NULL,
  `bomdetailinfoid` varchar(255) DEFAULT NULL,
  `partnamesuffix` varchar(255) DEFAULT NULL,
  `belongs` varchar(255) DEFAULT NULL,
  `forecastqty` varchar(255) DEFAULT NULL COMMENT '预估用量',
  `vendorname` varchar(255) DEFAULT NULL,
  `propertycode` varchar(255) DEFAULT NULL,
  `otherrequirementsbz` varchar(255) DEFAULT NULL,
  `vendername` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `materialname` varchar(500) DEFAULT NULL COMMENT '材料名称',
  `itmetype` varchar(255) DEFAULT NULL COMMENT '材料项目类型:\r\n1-材料项，2-复合模型，3-加工模型，4-工艺类，5-委外加工，6-贴合',
  `partnosuffix` varchar(255) DEFAULT NULL,
  `enabled` varchar(255) DEFAULT NULL,
  `bomversionnumber` varchar(255) DEFAULT NULL COMMENT 'BOM版本编号',
  `materialdesc` varchar(255) DEFAULT NULL,
  `materialsmalltype` varchar(255) DEFAULT NULL,
  `vendorcode` varchar(255) DEFAULT NULL,
  `trillion` varchar(255) DEFAULT NULL,
  `wide` varchar(255) DEFAULT NULL COMMENT '宽幅',
  `material_code` varchar(255) DEFAULT NULL COMMENT '材料编号',
  `lineno` varchar(255) DEFAULT NULL COMMENT 'BOM行号',
  `bomarea` varchar(255) DEFAULT NULL COMMENT 'BOM区域',
  `baseunitcode` varchar(255) DEFAULT NULL,
  `formula` varchar(255) DEFAULT NULL,
  `processeffect` varchar(255) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `vendor_short_name` varchar(255) DEFAULT NULL,
  `status` int DEFAULT '0' COMMENT '是否已处理',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=39097 DEFAULT CHARSET=utf8mb3 COMMENT='部位信息';


--
-- Table structure for table `anta_bom_itemnocolor`
--

DROP TABLE IF EXISTS `anta_bom_itemnocolor`;


CREATE TABLE `anta_bom_itemnocolor` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `anta_bom_api_seq` int DEFAULT NULL COMMENT 'api接口seq',
  `anta_bom_api_info_seq` int DEFAULT NULL COMMENT 'api接口信息seq',
  `anta_bom_list_info_seq` int DEFAULT NULL COMMENT 'bom清单主表seq',
  `create_user_id` varchar(50) DEFAULT NULL COMMENT '创建人ID',
  `modify_user_id` varchar(50) DEFAULT NULL COMMENT '修改人id',
  `create_user_name` varchar(50) DEFAULT NULL COMMENT '创建人姓名',
  `modify_user_name` varchar(50) DEFAULT NULL COMMENT '修改人姓名',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_time` datetime DEFAULT NULL,
  `is_delete` int DEFAULT NULL COMMENT '是否删除',
  `created_at` datetime DEFAULT NULL COMMENT '同步时间',
  `color` varchar(255) DEFAULT NULL COMMENT '颜色 ',
  `skucode` varchar(255) DEFAULT NULL COMMENT '货号',
  `colorcode` varchar(255) DEFAULT NULL COMMENT '颜色编码',
  `actualqty` varchar(255) DEFAULT NULL,
  `version` int DEFAULT NULL COMMENT '版本号',
  `enabled` int DEFAULT NULL COMMENT '是否生效',
  `colorname` varchar(255) DEFAULT NULL,
  `bomversionnumber` varchar(255) DEFAULT NULL COMMENT 'BOM版本编号',
  `lineno` varchar(255) DEFAULT NULL COMMENT 'BOM行号',
  `id` varchar(255) DEFAULT NULL COMMENT 'id',
  `remarks` varchar(255) DEFAULT NULL COMMENT '描述',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=106708 DEFAULT CHARSET=utf8mb3 COMMENT='安踏BOM货号材料颜色表';


--
-- Table structure for table `anta_bom_itemnorelation`
--

DROP TABLE IF EXISTS `anta_bom_itemnorelation`;


CREATE TABLE `anta_bom_itemnorelation` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `anta_bom_api_seq` int DEFAULT NULL COMMENT 'api接口seq',
  `anta_bom_api_info_seq` int DEFAULT NULL COMMENT 'api接口信息seq',
  `anta_bom_list_info_seq` int DEFAULT NULL COMMENT 'bom清单主表seq',
  `create_user_id` varchar(50) DEFAULT NULL COMMENT '创建人ID',
  `modify_user_id` varchar(50) DEFAULT NULL COMMENT '修改人id',
  `create_user_name` varchar(50) DEFAULT NULL COMMENT '创建人姓名',
  `modify_user_name` varchar(50) DEFAULT NULL COMMENT '修改人姓名',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_time` datetime DEFAULT NULL,
  `is_delete` int DEFAULT NULL COMMENT '是否删除',
  `created_at` datetime DEFAULT NULL COMMENT '同步时间',
  `skucode` varchar(255) DEFAULT NULL COMMENT '货号',
  `version` int DEFAULT NULL COMMENT '版本号',
  `colorname` varchar(255) DEFAULT NULL,
  `bomversionnumber` varchar(255) DEFAULT NULL COMMENT 'BOM版本编号',
  `id` varchar(255) DEFAULT NULL COMMENT 'id',
  `remarks` varchar(255) DEFAULT NULL COMMENT '描述',
  `status` int DEFAULT '0' COMMENT '是否已处理',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1294 DEFAULT CHARSET=utf8mb3 COMMENT='安踏BOM组合关系表（安踏产品资料配色）';


--
-- Table structure for table `anta_bom_list_info`
--

DROP TABLE IF EXISTS `anta_bom_list_info`;


CREATE TABLE `anta_bom_list_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `anta_bom_api_seq` int DEFAULT NULL COMMENT 'api接口seq',
  `anta_bom_api_info_seq` int DEFAULT NULL COMMENT 'api接口信息seq',
  `waistheight` varchar(255) DEFAULT NULL COMMENT '外腰高度',
  `vrevlength` varchar(255) DEFAULT NULL COMMENT '鞋头长度',
  `trialstage` varchar(255) DEFAULT NULL,
  `typeexterior` varchar(255) DEFAULT NULL COMMENT '面材质类型',
  `bomname` varchar(255) DEFAULT NULL COMMENT 'BOM描述',
  `heelheight` varchar(255) DEFAULT NULL COMMENT '后跟高度',
  `accountingcode` varchar(255) DEFAULT NULL COMMENT '核算码',
  `producttype` varchar(255) DEFAULT NULL COMMENT '型体类别',
  `bomversionnumber` varchar(255) DEFAULT NULL COMMENT 'BOM版本号',
  `zsex` varchar(255) DEFAULT NULL COMMENT '性别',
  `bomno` varchar(255) DEFAULT NULL COMMENT '大底编号',
  `neistheight` varchar(255) DEFAULT NULL COMMENT '内腰高度',
  `zstagcode` varchar(255) DEFAULT NULL COMMENT '样品阶段',
  `stylename` varchar(255) DEFAULT NULL COMMENT '鞋名',
  `sampleqty` int DEFAULT NULL COMMENT '样品数量',
  `bomstatus` int DEFAULT NULL COMMENT 'BOM版本状态',
  `brand` varchar(255) DEFAULT NULL COMMENT '品牌',
  `developseason` varchar(255) DEFAULT NULL COMMENT '季节',
  `remarksbom` varchar(255) DEFAULT NULL COMMENT 'BOM备注',
  `shoetreeno` varchar(255) DEFAULT NULL COMMENT '楦头编号',
  `middletypecode` varchar(255) DEFAULT NULL COMMENT '中类',
  `sizerun` varchar(255) DEFAULT NULL COMMENT '码段',
  `idslumenlength` varchar(255) DEFAULT NULL,
  `stylenumber` varchar(255) DEFAULT NULL COMMENT '款号',
  `developmentfactory` varchar(255) DEFAULT NULL COMMENT '工厂名称',
  `colorschemenumber` varchar(255) DEFAULT NULL COMMENT '配色数量',
  `send_system` varchar(255) DEFAULT NULL,
  `developmentplantcode` varchar(255) DEFAULT NULL COMMENT '工厂',
  `category` varchar(255) DEFAULT NULL COMMENT '品类',
  `samplesize` varchar(255) DEFAULT NULL COMMENT '样品码',
  `created_at` datetime DEFAULT NULL COMMENT '同步时间',
  `status` int DEFAULT '0' COMMENT '是否已处理(1为已处理）',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=694 DEFAULT CHARSET=utf8mb3 COMMENT='安踏bom清单--产品资料基础信息';


--
-- Table structure for table `api_cbd_order_info`
--

DROP TABLE IF EXISTS `api_cbd_order_info`;


CREATE TABLE `api_cbd_order_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `unique_id` varchar(100) DEFAULT NULL COMMENT '一组BOM的唯一码   CBD版本号',
  `finished_product_factory` varchar(100) DEFAULT NULL COMMENT '成品工厂   取CBD抬头-工厂',
  `price_doc_num` varchar(100) DEFAULT NULL COMMENT '价格文件编号',
  `item_number` varchar(100) DEFAULT NULL COMMENT '成品款/货号  CBD抬头-货号',
  `season` varchar(100) DEFAULT NULL COMMENT '季节   CBD抬头-季节',
  `phase` varchar(100) DEFAULT NULL COMMENT '阶段  取CBD抬头-阶段为确认样',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `status` int DEFAULT '1' COMMENT '状态（0已删除1未处理2已处理3处理失败）',
  `message` varchar(5000) DEFAULT NULL COMMENT '失败原因',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=707 DEFAULT CHARSET=utf8mb3 COMMENT='cbd Api接口订单信息表';


--
-- Table structure for table `api_cbd_order_info_detail`
--

DROP TABLE IF EXISTS `api_cbd_order_info_detail`;


CREATE TABLE `api_cbd_order_info_detail` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `api_cbd_order_info_seq` int DEFAULT NULL COMMENT 'CBD api接口订单信息主表seq',
  `category` varchar(50) DEFAULT NULL COMMENT '大类（区域编码）10-鞋面，20-内里，30-补强，40-搭配，50-底部，60-车线胶水，70-包装， 80-工艺， 90-人工管销， 100-其他, 110-利润',
  `component_code` varchar(100) DEFAULT NULL COMMENT '部位编码  CBD-部位编码',
  `component_name` varchar(100) DEFAULT NULL COMMENT '部位名称  CBD-部位名称',
  `material_code` varchar(100) DEFAULT NULL COMMENT '材料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '材料名称',
  `specification` varchar(100) DEFAULT NULL COMMENT '材料规格',
  `thickness` varchar(100) DEFAULT NULL COMMENT '厚度',
  `width` varchar(100) DEFAULT NULL COMMENT '宽幅',
  `color` varchar(100) DEFAULT NULL COMMENT '颜色',
  `usage` varchar(100) DEFAULT NULL COMMENT '使用量 小数4位',
  `vendor` varchar(100) DEFAULT NULL COMMENT '厂商名称',
  `remark` varchar(2000) DEFAULT NULL COMMENT '备注',
  `lossrate` varchar(100) DEFAULT NULL COMMENT '耗损  小数2位',
  `totaluse` varchar(100) DEFAULT NULL COMMENT '毛用量  小数4位',
  `dosageusage` varchar(100) DEFAULT NULL COMMENT '用量使用率  小数2位',
  `unitprice` varchar(100) DEFAULT NULL COMMENT '材料单价 小数4位',
  `materialamount` varchar(100) DEFAULT NULL COMMENT '金额  小数4位',
  `unitfee` varchar(100) DEFAULT NULL COMMENT '运费单价 小数4位',
  `materfee` varchar(100) DEFAULT NULL COMMENT '材料运费 小数4位',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `message` varchar(5000) DEFAULT NULL COMMENT '失败原因',
  `status` int DEFAULT '1' COMMENT '状态（0已删除1未处理2已处理3处理失败）',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=45285 DEFAULT CHARSET=utf8mb3 COMMENT='cbd Api接口订单信息明细表';


--
-- Table structure for table `bar_code`
--

DROP TABLE IF EXISTS `bar_code`;


CREATE TABLE `bar_code` (
  `seq` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `sample_order_code` varchar(50) DEFAULT NULL COMMENT '样品单号',
  `om_article_code` varchar(50) DEFAULT NULL COMMENT '型体单号',
  `bar_code` varchar(255) DEFAULT NULL COMMENT '条形码',
  `is_delete` char(1) DEFAULT NULL COMMENT '是否删除：0-否,1-是',
  `sample_size` varchar(50) DEFAULT NULL COMMENT '样品size',
  `sample_type` varchar(50) DEFAULT NULL COMMENT '样品类型',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='产品条码管理';


--
-- Table structure for table `bas_company`
--

DROP TABLE IF EXISTS `bas_company`;


CREATE TABLE `bas_company` (
  `id` int NOT NULL AUTO_INCREMENT,
  `seq` int DEFAULT NULL,
  `code` varchar(50) DEFAULT NULL COMMENT '编号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `company_name` varchar(200) DEFAULT NULL,
  `simple_name` varchar(50) DEFAULT NULL COMMENT '简称',
  `duty_paragraph` varchar(50) DEFAULT NULL COMMENT '税号',
  `legal_person` varchar(50) DEFAULT NULL COMMENT '法人',
  `register_address` varchar(50) DEFAULT NULL COMMENT '注册地址',
  `website` varchar(50) DEFAULT NULL COMMENT '网址',
  `fax` varchar(50) DEFAULT NULL COMMENT '传真',
  `email` varchar(50) DEFAULT NULL COMMENT '邮编',
  `besiness_range` varchar(500) DEFAULT NULL COMMENT '经营范围',
  `country_address` varchar(255) DEFAULT NULL COMMENT '办公地-国家',
  `province_address` varchar(255) DEFAULT NULL COMMENT '办公地-省份',
  `city_address` varchar(255) DEFAULT NULL COMMENT '办公地-市',
  `area_address` varchar(255) DEFAULT NULL COMMENT '办公地-区/县',
  `detail_address` varchar(255) DEFAULT NULL COMMENT '办公地-详细地址',
  `office_address` varchar(50) DEFAULT NULL COMMENT '办公地址(不要了)',
  `company_phone` varchar(50) DEFAULT NULL COMMENT '公司电话',
  `logo_image` varchar(500) DEFAULT NULL COMMENT 'logo图片',
  `set_date` datetime DEFAULT NULL COMMENT '成立日期',
  `organization_code` varchar(50) DEFAULT NULL COMMENT '组织机构代码',
  `business_regist_no` varchar(50) DEFAULT NULL COMMENT '工商注册号',
  `business_state` varchar(50) DEFAULT NULL COMMENT '经营状态',
  `company_type` int DEFAULT NULL COMMENT '企业类型',
  `is_product_unit` int DEFAULT NULL COMMENT '是否生产单位',
  `mes_company_id` varchar(40) DEFAULT NULL COMMENT 'mes公司id',
  `remark` text COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  `nice_name` varchar(255) DEFAULT NULL,
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COMMENT='公司基础信息';


--
-- Table structure for table `bas_company_attachment`
--

DROP TABLE IF EXISTS `bas_company_attachment`;


CREATE TABLE `bas_company_attachment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int DEFAULT NULL COMMENT '公司ID',
  `loc_path` varchar(500) DEFAULT NULL COMMENT '路径',
  `old_name` varchar(50) DEFAULT NULL COMMENT '旧文件名',
  `url` varchar(500) DEFAULT NULL COMMENT '文件路径',
  `name` varchar(50) DEFAULT NULL COMMENT '新文件名',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='公司信息附件';


--
-- Table structure for table `bas_company_bank`
--

DROP TABLE IF EXISTS `bas_company_bank`;


CREATE TABLE `bas_company_bank` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键自增列',
  `company_id` int DEFAULT NULL COMMENT '公司id',
  `bank_name` varchar(50) DEFAULT NULL COMMENT '银行名称',
  `open_bank` varchar(50) DEFAULT NULL COMMENT '开户行',
  `bank_card_no` varchar(50) DEFAULT NULL COMMENT '银行账号',
  `united_bank_no` varchar(50) DEFAULT NULL COMMENT '联行号',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='公司银行账号';


--
-- Table structure for table `bas_company_contact`
--

DROP TABLE IF EXISTS `bas_company_contact`;


CREATE TABLE `bas_company_contact` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` int DEFAULT NULL COMMENT '公司id',
  `type` int DEFAULT NULL COMMENT '联系人类型（从字典表获取）',
  `name` varchar(50) DEFAULT NULL COMMENT '姓名',
  `sex` int DEFAULT NULL COMMENT '性别',
  `department` varchar(50) DEFAULT NULL COMMENT '部门',
  `post` varchar(50) DEFAULT NULL COMMENT '职务',
  `mobile_phone` varchar(50) DEFAULT NULL COMMENT '移动电话',
  `fixed_phone` varchar(50) DEFAULT NULL COMMENT '固定电话',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `receipt_address_abb` varchar(255) DEFAULT NULL COMMENT '收货地简称',
  `receipt_address` varchar(50) DEFAULT NULL COMMENT '收货地址详细地址',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COMMENT='公司联系人信息';


--
-- Table structure for table `bas_company_warehouse`
--

DROP TABLE IF EXISTS `bas_company_warehouse`;


CREATE TABLE `bas_company_warehouse` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` int DEFAULT NULL COMMENT '公司ID',
  `level` int DEFAULT NULL COMMENT '层级',
  `serial_no` int DEFAULT NULL COMMENT '同层级顺序号',
  `parent_id` int DEFAULT NULL COMMENT '父级id',
  `code` varchar(50) DEFAULT NULL COMMENT '编号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `path_name` varchar(50) DEFAULT NULL COMMENT '路径全称',
  `warehouse_type_id` int DEFAULT NULL COMMENT '仓库类型id',
  `warehouse_type_name` varchar(50) DEFAULT NULL COMMENT '仓库类型名称',
  `charge_person_id` int DEFAULT NULL COMMENT '负责人id',
  `charge_person_name` varchar(50) DEFAULT NULL COMMENT '负责人名称',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  `node_type_name` varchar(10) DEFAULT NULL COMMENT '节点类型名称',
  `location_type_id` varchar(10) DEFAULT NULL COMMENT '储位类型ID',
  `location_type_name` varchar(10) DEFAULT NULL COMMENT '储位类型名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1623 DEFAULT CHARSET=utf8mb3 COMMENT='公司仓库';


--
-- Table structure for table `bas_company_warehouse_copy1`
--

DROP TABLE IF EXISTS `bas_company_warehouse_copy1`;


CREATE TABLE `bas_company_warehouse_copy1` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` int DEFAULT NULL COMMENT '公司ID',
  `level` int DEFAULT NULL COMMENT '层级',
  `serial_no` int DEFAULT NULL COMMENT '同层级顺序号',
  `parent_id` int DEFAULT NULL COMMENT '父级id',
  `code` varchar(50) DEFAULT NULL COMMENT '编号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `path_name` varchar(50) DEFAULT NULL COMMENT '路径全称',
  `warehouse_type_id` int DEFAULT NULL COMMENT '仓库类型id',
  `warehouse_type_name` varchar(50) DEFAULT NULL COMMENT '仓库类型名称',
  `charge_person_id` int DEFAULT NULL COMMENT '负责人id',
  `charge_person_name` varchar(50) DEFAULT NULL COMMENT '负责人名称',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  `node_type_name` varchar(10) DEFAULT NULL COMMENT '节点类型名称',
  `location_type_id` varchar(10) DEFAULT NULL COMMENT '储位类型ID',
  `location_type_name` varchar(10) DEFAULT NULL COMMENT '储位类型名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1219 DEFAULT CHARSET=utf8mb3 COMMENT='公司仓库';


--
-- Table structure for table `bas_company_warehouse_zqs20240725`
--

DROP TABLE IF EXISTS `bas_company_warehouse_zqs20240725`;


CREATE TABLE `bas_company_warehouse_zqs20240725` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` int DEFAULT NULL COMMENT '公司ID',
  `level` int DEFAULT NULL COMMENT '层级',
  `serial_no` int DEFAULT NULL COMMENT '同层级顺序号',
  `parent_id` int DEFAULT NULL COMMENT '父级id',
  `code` varchar(50) DEFAULT NULL COMMENT '编号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `path_name` varchar(50) DEFAULT NULL COMMENT '路径全称',
  `warehouse_type_id` int DEFAULT NULL COMMENT '仓库类型id',
  `warehouse_type_name` varchar(50) DEFAULT NULL COMMENT '仓库类型名称',
  `charge_person_id` int DEFAULT NULL COMMENT '负责人id',
  `charge_person_name` varchar(50) DEFAULT NULL COMMENT '负责人名称',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  `node_type_name` varchar(10) DEFAULT NULL COMMENT '节点类型名称',
  `location_type_id` varchar(10) DEFAULT NULL COMMENT '储位类型ID',
  `location_type_name` varchar(10) DEFAULT NULL COMMENT '储位类型名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1486 DEFAULT CHARSET=utf8mb3 COMMENT='公司仓库';


--
-- Table structure for table `bas_company_workshop`
--

DROP TABLE IF EXISTS `bas_company_workshop`;


CREATE TABLE `bas_company_workshop` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` int DEFAULT NULL COMMENT '公司id',
  `company_name` varchar(200) DEFAULT NULL COMMENT '公司昵称',
  `company_seq` int DEFAULT NULL,
  `level` int DEFAULT NULL COMMENT '层级',
  `serial_no` int DEFAULT NULL COMMENT '同层级顺序号',
  `parent_id` int DEFAULT NULL COMMENT '父级id',
  `code` varchar(50) DEFAULT NULL COMMENT '编号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `process_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `process_id` int DEFAULT NULL COMMENT '制程Id',
  `mes_process_name` varchar(255) DEFAULT NULL,
  `mes_process_id` int DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL COMMENT '组别名称',
  `group_id` int DEFAULT NULL COMMENT '组别Id',
  `mes_group_name` varchar(255) DEFAULT NULL,
  `mes_group_id` int DEFAULT NULL,
  `dept_name` varchar(255) DEFAULT NULL COMMENT '部门名称',
  `dept_id` int DEFAULT NULL COMMENT '部门id',
  `path_name` varchar(50) DEFAULT NULL COMMENT '路径全称',
  `charge_person_id` int DEFAULT NULL COMMENT '负责人id',
  `charge_person_name` varchar(50) DEFAULT NULL COMMENT '负责人名称',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='公司车间';


--
-- Table structure for table `bas_custom`
--

DROP TABLE IF EXISTS `bas_custom`;


CREATE TABLE `bas_custom` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(50) DEFAULT NULL COMMENT '编号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `simple_name` varchar(50) DEFAULT NULL COMMENT '简称',
  `duty_paragraph` varchar(50) DEFAULT NULL COMMENT '税号',
  `legal_person` varchar(50) DEFAULT NULL COMMENT '法人',
  `register_address` varchar(255) DEFAULT NULL COMMENT '注册地址',
  `website` varchar(200) DEFAULT NULL COMMENT '网址',
  `fax` varchar(50) DEFAULT NULL COMMENT '传真',
  `email` varchar(50) DEFAULT NULL COMMENT '邮编',
  `besiness_range` varchar(500) DEFAULT NULL COMMENT '经营范围',
  `country_address` varchar(255) DEFAULT NULL COMMENT '办公地-国家',
  `province_address` varchar(255) DEFAULT NULL COMMENT '办公地-省份',
  `city_address` varchar(255) DEFAULT NULL COMMENT '办公地-市',
  `area_address` varchar(255) DEFAULT NULL COMMENT '办公地-区/县',
  `detail_address` varchar(255) DEFAULT NULL COMMENT '办公地-详细地址',
  `office_address` varchar(50) DEFAULT NULL COMMENT '办公地址（不要了）',
  `company_phone` varchar(50) DEFAULT NULL COMMENT '公司电话',
  `logo_image` varchar(500) DEFAULT NULL COMMENT 'logo图片',
  `set_date` datetime DEFAULT NULL COMMENT '成立日期',
  `organization_code` varchar(50) DEFAULT NULL COMMENT '组织机构代码',
  `business_regist_no` varchar(50) DEFAULT NULL COMMENT '工商注册号',
  `business_state` varchar(50) DEFAULT NULL COMMENT '经营状态',
  `company_type` int DEFAULT NULL COMMENT '企业类型',
  `payment_type` varchar(50) DEFAULT NULL COMMENT '付款方式',
  `remark` text COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  `rate` decimal(18,3) DEFAULT NULL COMMENT '税率',
  `start_collaboration_at` datetime DEFAULT NULL COMMENT '开始合作日期',
  `nice_name` varchar(255) DEFAULT NULL,
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8mb3 COMMENT='客户基础资料';


--
-- Table structure for table `bas_custom_attachment`
--

DROP TABLE IF EXISTS `bas_custom_attachment`;


CREATE TABLE `bas_custom_attachment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `custom_id` int DEFAULT NULL COMMENT '公司ID',
  `loc_path` varchar(500) DEFAULT NULL COMMENT '路径',
  `old_name` varchar(50) DEFAULT NULL COMMENT '旧文件名',
  `url` varchar(500) DEFAULT NULL COMMENT '文件路径',
  `name` varchar(50) DEFAULT NULL COMMENT '新文件名',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `file_type` varchar(500) DEFAULT NULL COMMENT '文件类型',
  `file_size` varchar(500) DEFAULT NULL COMMENT '文件大小',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='客户信息附件';


--
-- Table structure for table `bas_custom_bank`
--

DROP TABLE IF EXISTS `bas_custom_bank`;


CREATE TABLE `bas_custom_bank` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `custom_id` int DEFAULT NULL COMMENT '客户id',
  `bank_name` varchar(50) DEFAULT NULL COMMENT '银行名称',
  `open_bank` varchar(50) DEFAULT NULL COMMENT '开户行',
  `bank_card_no` varchar(50) DEFAULT NULL COMMENT '银行账号',
  `united_bank_no` varchar(50) DEFAULT NULL COMMENT '联行号',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COMMENT='客户银行账号';


--
-- Table structure for table `bas_custom_contact`
--

DROP TABLE IF EXISTS `bas_custom_contact`;


CREATE TABLE `bas_custom_contact` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `custom_id` int DEFAULT NULL COMMENT '客户id',
  `type` int DEFAULT NULL COMMENT '联系人类型（从字典表获取）',
  `name` varchar(50) DEFAULT NULL COMMENT '姓名',
  `sex` int DEFAULT NULL COMMENT '性别',
  `department` varchar(50) DEFAULT NULL COMMENT '部门',
  `post` varchar(50) DEFAULT NULL COMMENT '职务',
  `mobile_phone` varchar(50) DEFAULT NULL COMMENT '移动电话',
  `fixed_phone` varchar(50) DEFAULT NULL COMMENT '固定电话',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `receipt_address_abb` varchar(255) DEFAULT NULL COMMENT '收货地简称',
  `receipt_address` varchar(50) DEFAULT NULL COMMENT '收货地址',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COMMENT='客户联系人';


--
-- Table structure for table `bas_custom_product_class`
--

DROP TABLE IF EXISTS `bas_custom_product_class`;


CREATE TABLE `bas_custom_product_class` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `custom_id` int DEFAULT NULL COMMENT '客户ID',
  `level` int DEFAULT NULL COMMENT '层级',
  `serial_no` int DEFAULT NULL COMMENT '同层级顺序号',
  `parent_id` int DEFAULT NULL COMMENT '父级id',
  `code` varchar(50) DEFAULT NULL COMMENT '编号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `brand_name` varchar(50) DEFAULT NULL COMMENT '品名',
  `implement_standed` varchar(50) DEFAULT NULL COMMENT '执行标准',
  `product_bar_code` varchar(50) DEFAULT NULL COMMENT '商品条码',
  `grading_type_id` int DEFAULT NULL COMMENT '级放类型id',
  `grading_type_name` varchar(200) DEFAULT NULL COMMENT '级放类型',
  `grading_rate` decimal(18,2) DEFAULT NULL COMMENT '级放比率',
  `grading_count` decimal(18,2) DEFAULT NULL COMMENT '级放数量',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb3 COMMENT='客户产品类型';


--
-- Table structure for table `bas_money_type`
--

DROP TABLE IF EXISTS `bas_money_type`;


CREATE TABLE `bas_money_type` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `currency_seq` int DEFAULT NULL COMMENT '币种seq(字典表seq)',
  `currency_name` varchar(255) DEFAULT NULL COMMENT '币种名称(字典表名称)',
  `currency_code` varchar(255) DEFAULT NULL COMMENT '币种code(字典表code)',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `enable` int unsigned DEFAULT '1' COMMENT '是否可用',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COMMENT='币种';


--
-- Table structure for table `bas_money_type_rate`
--

DROP TABLE IF EXISTS `bas_money_type_rate`;


CREATE TABLE `bas_money_type_rate` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `money_type_seq` int DEFAULT NULL COMMENT '币种',
  `source_currency_name` varchar(255) DEFAULT NULL COMMENT '源币种名称',
  `source_currency_code` varchar(255) DEFAULT NULL COMMENT '源币种名称',
  `currency_code` varchar(255) DEFAULT NULL COMMENT '目标币种名称',
  `currency_name` varchar(255) DEFAULT NULL COMMENT '目标币种名称',
  `exchange_rate` decimal(18,2) DEFAULT NULL COMMENT '汇率',
  `rate_update_time` varchar(50) DEFAULT NULL COMMENT '汇率更新时间',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `enable` int unsigned DEFAULT '1' COMMENT '是否可用',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=321 DEFAULT CHARSET=utf8mb3 COMMENT='币种汇率';


--
-- Table structure for table `bas_money_type_rate_history`
--

DROP TABLE IF EXISTS `bas_money_type_rate_history`;


CREATE TABLE `bas_money_type_rate_history` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `money_type_seq` int DEFAULT NULL COMMENT '币种',
  `currency_seq` int DEFAULT NULL COMMENT '币种(字典表seq)',
  `source_currency_name` varchar(255) DEFAULT NULL COMMENT '源币种名称',
  `currency_name` varchar(255) DEFAULT NULL COMMENT '币种名称(字典表名称)',
  `source_currency_code` varchar(255) DEFAULT NULL COMMENT '源币种名称',
  `currency_code` varchar(255) DEFAULT NULL COMMENT '目标币种名称',
  `batch_number` varchar(255) DEFAULT NULL COMMENT '批次号',
  `exchange_rate` decimal(18,2) DEFAULT NULL COMMENT '汇率',
  `rate_update_time` datetime DEFAULT NULL COMMENT '汇率更新时间',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `enable` int unsigned DEFAULT '1' COMMENT '是否可用',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='币种汇率';


--
-- Table structure for table `bas_supplier`
--

DROP TABLE IF EXISTS `bas_supplier`;


CREATE TABLE `bas_supplier` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(255) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `simple_name` varchar(255) DEFAULT NULL COMMENT '简称',
  `duty_paragraph` varchar(255) DEFAULT NULL COMMENT '统一社会信用代码',
  `legal_person` varchar(50) DEFAULT NULL COMMENT '法人',
  `register_address` varchar(255) DEFAULT NULL COMMENT '注册地',
  `website` varchar(255) DEFAULT NULL COMMENT '网址',
  `fax` varchar(24) DEFAULT NULL COMMENT '传真',
  `email` varchar(255) DEFAULT NULL COMMENT '邮编',
  `business_nature` text COMMENT '经营范围',
  `currency` varchar(255) DEFAULT NULL COMMENT '币别',
  `supplier_category` varchar(255) DEFAULT NULL COMMENT '厂商类别',
  `office_address` varchar(255) DEFAULT NULL COMMENT '办公室地址',
  `company_phone` varchar(255) DEFAULT NULL COMMENT '供应商电话',
  `logo_image` varchar(255) DEFAULT NULL COMMENT 'logo',
  `set_date` datetime DEFAULT NULL COMMENT '成立日期',
  `organization_code` varchar(255) DEFAULT NULL COMMENT '组织机构代码',
  `business_regist_no` varchar(255) DEFAULT NULL COMMENT '工商注册号',
  `business_state` varchar(255) DEFAULT NULL COMMENT '经营状态',
  `status` int DEFAULT NULL COMMENT '状态(10提交, null草稿, 20待审批, 21审批中, 22转办, 23委派, 24抄送, 25退回, 26驳回, 1撤回)',
  `country_address` varchar(255) DEFAULT NULL COMMENT '办公地-国家',
  `province_address` varchar(255) DEFAULT NULL COMMENT '办公地-省份',
  `city_address` varchar(255) DEFAULT NULL COMMENT '办公地-市',
  `area_address` varchar(255) DEFAULT NULL COMMENT '办公地-区/县',
  `detail_address` varchar(255) DEFAULT NULL COMMENT '办公地-详细地址',
  `company_type` int DEFAULT NULL COMMENT '企业类型',
  `company_scale` varchar(255) DEFAULT NULL COMMENT '企业规模',
  `cooperation_level` varchar(255) DEFAULT NULL COMMENT '合作等级',
  `cooperation_type` varchar(50) DEFAULT NULL COMMENT '合作类型',
  `cooperation_state` varchar(255) DEFAULT NULL COMMENT '合作状态',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `updated_at` datetime DEFAULT NULL,
  `update_by` varchar(50) DEFAULT NULL,
  `is_delete` int DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `remark` text COMMENT '备注',
  `enable` int DEFAULT NULL COMMENT '是否生效',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `rate` decimal(18,3) DEFAULT NULL COMMENT '税率',
  `created_name` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1352 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='供应商';


--
-- Table structure for table `bas_supplier_0723`
--

DROP TABLE IF EXISTS `bas_supplier_0723`;


CREATE TABLE `bas_supplier_0723` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(255) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `simple_name` varchar(255) DEFAULT NULL COMMENT '简称',
  `duty_paragraph` varchar(255) DEFAULT NULL COMMENT '统一社会信用代码',
  `legal_person` varchar(50) DEFAULT NULL COMMENT '法人',
  `register_address` varchar(255) DEFAULT NULL COMMENT '注册地',
  `website` varchar(255) DEFAULT NULL COMMENT '网址',
  `fax` varchar(24) DEFAULT NULL COMMENT '传真',
  `email` varchar(255) DEFAULT NULL COMMENT '邮编',
  `business_nature` text COMMENT '经营范围',
  `currency` varchar(255) DEFAULT NULL COMMENT '币别',
  `supplier_category` varchar(255) DEFAULT NULL COMMENT '厂商类别',
  `office_address` varchar(255) DEFAULT NULL COMMENT '办公室地址',
  `company_phone` varchar(255) DEFAULT NULL COMMENT '供应商电话',
  `logo_image` varchar(255) DEFAULT NULL COMMENT 'logo',
  `set_date` datetime DEFAULT NULL COMMENT '成立日期',
  `organization_code` varchar(255) DEFAULT NULL COMMENT '组织机构代码',
  `business_regist_no` varchar(255) DEFAULT NULL COMMENT '工商注册号',
  `business_state` varchar(255) DEFAULT NULL COMMENT '经营状态',
  `status` int DEFAULT NULL COMMENT '状态(10提交, null草稿, 20待审批, 21审批中, 22转办, 23委派, 24抄送, 25退回, 26驳回, 1撤回)',
  `country_address` varchar(255) DEFAULT NULL COMMENT '办公地-国家',
  `province_address` varchar(255) DEFAULT NULL COMMENT '办公地-省份',
  `city_address` varchar(255) DEFAULT NULL COMMENT '办公地-市',
  `area_address` varchar(255) DEFAULT NULL COMMENT '办公地-区/县',
  `detail_address` varchar(255) DEFAULT NULL COMMENT '办公地-详细地址',
  `company_type` int DEFAULT NULL COMMENT '企业类型',
  `company_scale` varchar(255) DEFAULT NULL COMMENT '企业规模',
  `cooperation_level` varchar(255) DEFAULT NULL COMMENT '合作等级',
  `cooperation_type` varchar(50) DEFAULT NULL COMMENT '合作类型',
  `cooperation_state` varchar(255) DEFAULT NULL COMMENT '合作状态',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `updated_at` datetime DEFAULT NULL,
  `update_by` varchar(50) DEFAULT NULL,
  `is_delete` int DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `remark` text COMMENT '备注',
  `enable` int DEFAULT NULL COMMENT '是否生效',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `rate` decimal(18,3) DEFAULT NULL COMMENT '税率',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1177 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='供应商';


--
-- Table structure for table `bas_supplier_20250624`
--

DROP TABLE IF EXISTS `bas_supplier_20250624`;


CREATE TABLE `bas_supplier_20250624` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(255) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `simple_name` varchar(255) DEFAULT NULL COMMENT '简称',
  `duty_paragraph` varchar(255) DEFAULT NULL COMMENT '统一社会信用代码',
  `legal_person` varchar(50) DEFAULT NULL COMMENT '法人',
  `register_address` varchar(255) DEFAULT NULL COMMENT '注册地',
  `website` varchar(255) DEFAULT NULL COMMENT '网址',
  `fax` varchar(24) DEFAULT NULL COMMENT '传真',
  `email` varchar(255) DEFAULT NULL COMMENT '邮编',
  `business_nature` text COMMENT '经营范围',
  `currency` varchar(255) DEFAULT NULL COMMENT '币别',
  `supplier_category` varchar(255) DEFAULT NULL COMMENT '厂商类别',
  `office_address` varchar(255) DEFAULT NULL COMMENT '办公室地址',
  `company_phone` varchar(255) DEFAULT NULL COMMENT '供应商电话',
  `logo_image` varchar(255) DEFAULT NULL COMMENT 'logo',
  `set_date` datetime DEFAULT NULL COMMENT '成立日期',
  `organization_code` varchar(255) DEFAULT NULL COMMENT '组织机构代码',
  `business_regist_no` varchar(255) DEFAULT NULL COMMENT '工商注册号',
  `business_state` varchar(255) DEFAULT NULL COMMENT '经营状态',
  `status` int DEFAULT NULL COMMENT '状态(10提交, null草稿, 20待审批, 21审批中, 22转办, 23委派, 24抄送, 25退回, 26驳回, 1撤回)',
  `country_address` varchar(255) DEFAULT NULL COMMENT '办公地-国家',
  `province_address` varchar(255) DEFAULT NULL COMMENT '办公地-省份',
  `city_address` varchar(255) DEFAULT NULL COMMENT '办公地-市',
  `area_address` varchar(255) DEFAULT NULL COMMENT '办公地-区/县',
  `detail_address` varchar(255) DEFAULT NULL COMMENT '办公地-详细地址',
  `company_type` int DEFAULT NULL COMMENT '企业类型',
  `company_scale` varchar(255) DEFAULT NULL COMMENT '企业规模',
  `cooperation_level` varchar(255) DEFAULT NULL COMMENT '合作等级',
  `cooperation_type` varchar(50) DEFAULT NULL COMMENT '合作类型',
  `cooperation_state` varchar(255) DEFAULT NULL COMMENT '合作状态',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `updated_at` datetime DEFAULT NULL,
  `update_by` varchar(50) DEFAULT NULL,
  `is_delete` int DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `remark` text COMMENT '备注',
  `enable` int DEFAULT NULL COMMENT '是否生效',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `rate` decimal(18,3) DEFAULT NULL COMMENT '税率',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1118 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='供应商';


--
-- Table structure for table `bas_supplier_attachment`
--

DROP TABLE IF EXISTS `bas_supplier_attachment`;


CREATE TABLE `bas_supplier_attachment` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `supplier_seq` int DEFAULT NULL COMMENT '供应商ID',
  `loc_path` varchar(500) DEFAULT NULL COMMENT '路径',
  `old_name` varchar(50) DEFAULT NULL COMMENT '旧文件名',
  `url` varchar(500) DEFAULT NULL COMMENT '文件路径',
  `name` varchar(50) DEFAULT NULL COMMENT '新文件名',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `file_type` varchar(500) DEFAULT NULL COMMENT '文件类型',
  `file_size` varchar(500) DEFAULT NULL COMMENT '文件大小',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COMMENT='客户信息附件';


--
-- Table structure for table `bas_supplier_bak1`
--

DROP TABLE IF EXISTS `bas_supplier_bak1`;


CREATE TABLE `bas_supplier_bak1` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(255) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `simple_name` varchar(255) DEFAULT NULL COMMENT '简称',
  `duty_paragraph` varchar(255) DEFAULT NULL COMMENT '统一社会信用代码',
  `legal_person` varchar(50) DEFAULT NULL COMMENT '法人',
  `register_address` varchar(255) DEFAULT NULL COMMENT '注册地',
  `website` varchar(255) DEFAULT NULL COMMENT '网址',
  `fax` varchar(24) DEFAULT NULL COMMENT '传真',
  `email` varchar(255) DEFAULT NULL COMMENT '邮编',
  `business_nature` text COMMENT '经营范围',
  `currency` varchar(255) DEFAULT NULL COMMENT '币别',
  `supplier_category` varchar(255) DEFAULT NULL COMMENT '厂商类别',
  `office_address` varchar(255) DEFAULT NULL COMMENT '办公室地址',
  `company_phone` varchar(255) DEFAULT NULL COMMENT '供应商电话',
  `logo_image` varchar(255) DEFAULT NULL COMMENT 'logo',
  `set_date` datetime DEFAULT NULL COMMENT '成立日期',
  `organization_code` varchar(255) DEFAULT NULL COMMENT '组织机构代码',
  `business_regist_no` varchar(255) DEFAULT NULL COMMENT '工商注册号',
  `business_state` varchar(255) DEFAULT NULL COMMENT '经营状态',
  `status` int DEFAULT NULL COMMENT '状态(10提交, null草稿, 20待审批, 21审批中, 22转办, 23委派, 24抄送, 25退回, 26驳回, 1撤回)',
  `country_address` varchar(255) DEFAULT NULL COMMENT '办公地-国家',
  `province_address` varchar(255) DEFAULT NULL COMMENT '办公地-省份',
  `city_address` varchar(255) DEFAULT NULL COMMENT '办公地-市',
  `area_address` varchar(255) DEFAULT NULL COMMENT '办公地-区/县',
  `detail_address` varchar(255) DEFAULT NULL COMMENT '办公地-详细地址',
  `company_type` int DEFAULT NULL COMMENT '企业类型',
  `company_scale` varchar(255) DEFAULT NULL COMMENT '企业规模',
  `cooperation_level` varchar(255) DEFAULT NULL COMMENT '合作等级',
  `cooperation_type` varchar(50) DEFAULT NULL COMMENT '合作类型',
  `cooperation_state` varchar(255) DEFAULT NULL COMMENT '合作状态',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `updated_at` datetime DEFAULT NULL,
  `update_by` varchar(50) DEFAULT NULL,
  `is_delete` int DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `remark` text COMMENT '备注',
  `enable` int DEFAULT NULL COMMENT '是否生效',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `rate` decimal(18,3) DEFAULT NULL COMMENT '税率',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=401 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='供应商';


--
-- Table structure for table `bas_supplier_bank`
--

DROP TABLE IF EXISTS `bas_supplier_bank`;


CREATE TABLE `bas_supplier_bank` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `bank_name` varchar(50) DEFAULT NULL COMMENT '银行名称',
  `open_bank` varchar(50) DEFAULT NULL COMMENT '开户行',
  `bank_card_no` varchar(50) DEFAULT NULL COMMENT '银行账号',
  `united_bank_no` varchar(50) DEFAULT NULL COMMENT '联行号',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='供应商银行账号';


--
-- Table structure for table `bas_supplier_bank_20250624`
--

DROP TABLE IF EXISTS `bas_supplier_bank_20250624`;


CREATE TABLE `bas_supplier_bank_20250624` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `bank_name` varchar(50) DEFAULT NULL COMMENT '银行名称',
  `open_bank` varchar(50) DEFAULT NULL COMMENT '开户行',
  `bank_card_no` varchar(50) DEFAULT NULL COMMENT '银行账号',
  `united_bank_no` varchar(50) DEFAULT NULL COMMENT '联行号',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=131 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='供应商银行账号';


--
-- Table structure for table `bas_supplier_contact`
--

DROP TABLE IF EXISTS `bas_supplier_contact`;


CREATE TABLE `bas_supplier_contact` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `type` int DEFAULT NULL COMMENT '联系人类型（从字典表获取）',
  `name` varchar(50) DEFAULT NULL COMMENT '姓名',
  `sex` int DEFAULT NULL COMMENT '性别',
  `department` varchar(50) DEFAULT NULL COMMENT '部门',
  `post` varchar(50) DEFAULT NULL COMMENT '职务',
  `mobile_phone` varchar(50) DEFAULT NULL COMMENT '移动电话',
  `fixed_phone` varchar(50) DEFAULT NULL COMMENT '固定电话',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `receipt_address_abb` varchar(255) DEFAULT NULL COMMENT '收货地简称',
  `receipt_address` varchar(50) DEFAULT NULL COMMENT '收货地址',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=551 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='供应商联系人';


--
-- Table structure for table `bas_unit_no`
--

DROP TABLE IF EXISTS `bas_unit_no`;


CREATE TABLE `bas_unit_no` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL COMMENT '编号',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  `num_format` varchar(255) DEFAULT NULL COMMENT '数量格式化',
  `grading_type_seq` int DEFAULT NULL COMMENT '级放类型seq(字典表seq)',
  `grading_type_name` varchar(255) DEFAULT NULL COMMENT '级放类型名称(字典表名称)',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `enable` int unsigned DEFAULT '1' COMMENT '是否可用',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `created_name` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8mb3 COMMENT='单位';


--
-- Table structure for table `batch_list`
--

DROP TABLE IF EXISTS `batch_list`;


CREATE TABLE `batch_list` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `batch_seq` int DEFAULT NULL COMMENT '入库表seq',
  `material_seq` int DEFAULT NULL COMMENT '采购计划详情seq',
  `is_store` int DEFAULT NULL COMMENT '库存材料',
  `store_house` int DEFAULT NULL COMMENT '仓库',
  `stronge` int DEFAULT NULL COMMENT '储位',
  `in_stronge` double(3,0) DEFAULT NULL COMMENT '收货量',
  `sum_price` decimal(10,2) DEFAULT NULL COMMENT '金额',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  `is_delete` int DEFAULT '0',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;


--
-- Table structure for table `batch_pro_info`
--

DROP TABLE IF EXISTS `batch_pro_info`;


CREATE TABLE `batch_pro_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `materi_batch_seq` int DEFAULT NULL COMMENT '入库seq',
  `procurement_info_seq` int DEFAULT NULL COMMENT '采购计划详情seq',
  `income_num` double(7,2) DEFAULT NULL COMMENT '收货量',
  `storage` varchar(255) DEFAULT NULL COMMENT '储位',
  `storehouse` varchar(255) DEFAULT NULL COMMENT '仓库',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='入库/采购计划详情';


--
-- Table structure for table `bill_seq`
--

DROP TABLE IF EXISTS `bill_seq`;


CREATE TABLE `bill_seq` (
  `id` int NOT NULL AUTO_INCREMENT,
  `prefix` varchar(20) NOT NULL,
  `last_seq` int NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(200) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx` (`prefix`,`last_seq`) USING BTREE,
  KEY `u_idx` (`prefix`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=206 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;


--
-- Table structure for table `bill_setting`
--

DROP TABLE IF EXISTS `bill_setting`;


CREATE TABLE `bill_setting` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bill_name` varchar(255) NOT NULL COMMENT '单据类型',
  `prefix` varchar(255) NOT NULL COMMENT '单据标识',
  `year` varchar(4) DEFAULT NULL COMMENT '年份',
  `month` varchar(2) DEFAULT NULL COMMENT '月份',
  `day` varchar(2) DEFAULT NULL COMMENT '日',
  `serial_number` varchar(20) DEFAULT NULL COMMENT '单据流水码段断',
  `is_cost` char(1) DEFAULT NULL COMMENT '是否和成本计算有关，0无关系；1有关系',
  `is_price` char(1) DEFAULT NULL COMMENT '0无单价，1有单价；\r\n1）当成本为1的时候， 值为0或1 ；\r\n2）与成本无关, 本项不可用，默认是null',
  `is_check_accounts` char(1) DEFAULT NULL COMMENT '是否参与对账',
  `is_inventory` char(1) DEFAULT NULL COMMENT '是否与库存有关',
  `is_approve` char(1) DEFAULT NULL COMMENT '是否审批',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_delete` char(1) DEFAULT '0' COMMENT '是否删除，默认0不删除；1删除',
  `deleted_at` varchar(255) DEFAULT NULL,
  `deleted_by` datetime DEFAULT NULL,
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `pIdx` (`prefix`) USING BTREE COMMENT '单据前缀唯一',
  UNIQUE KEY `nameIdx` (`bill_name`) USING BTREE COMMENT '单据名称唯一'
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='单据配置表';


--
-- Table structure for table `business_file`
--

DROP TABLE IF EXISTS `business_file`;


CREATE TABLE `business_file` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `business_seq` int DEFAULT NULL COMMENT '业务seq\r\n例如：附件属于型体，business_seq=所属型体seq',
  `file_seq` int DEFAULT NULL COMMENT '附件seq',
  `type` varchar(22) DEFAULT NULL COMMENT '文件类型\r\n1：图片；\r\n2：文件；\r\n3：SKU(PDF)；\r\n4：logo',
  `business_type` varchar(2) DEFAULT NULL COMMENT '业务类型（10：型体,20：系统应用,30:材料暂收附件;40:应付对账单）',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11890 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='附件业务对应表';


--
-- Table structure for table `business_flowable`
--

DROP TABLE IF EXISTS `business_flowable`;


CREATE TABLE `business_flowable` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `business_type` varchar(255) DEFAULT NULL COMMENT '业务类型',
  `business_seq` int DEFAULT NULL COMMENT '业务序号',
  `flow_key` varchar(255) DEFAULT NULL COMMENT '流程标识',
  `deployment_id` varchar(255) DEFAULT NULL COMMENT '流程编号',
  `proc_def_id` varchar(255) DEFAULT NULL COMMENT '流程Id',
  `proc_ins_id` varchar(255) DEFAULT NULL COMMENT '流程实例Id',
  `deploy_id` varchar(255) DEFAULT NULL COMMENT '同流程编号',
  `task_id` varchar(255) DEFAULT NULL COMMENT '流程实例Id',
  `run_task_id` varchar(255) DEFAULT NULL COMMENT '运行中的流程实例Id',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=5296 DEFAULT CHARSET=utf8mb3 COMMENT='业务流程关联关系表';


--
-- Temporary view structure for view `caigousumview`
--

DROP TABLE IF EXISTS `caigousumview`;
/*!50001 DROP VIEW IF EXISTS `caigousumview`*/;
SET @saved_cs_client     = @@character_set_client;

/*!50001 CREATE VIEW `caigousumview` AS SELECT 
 1 AS `厂商名称`,
 1 AS `收料工厂`,
 1 AS `客户名称`,
 1 AS `收料仓库`,
 1 AS `鞋型季度`,
 1 AS `订单合同号`,
 1 AS `采购合同号`,
 1 AS `客户型体号`,
 1 AS `部位`,
 1 AS `手工排产单号`,
 1 AS `需求时间`,
 1 AS `厂商交期`,
 1 AS `物料名称`,
 1 AS `物料颜色`,
 1 AS `需求数量`,
 1 AS `本次计划量`,
 1 AS `采购数量`,
 1 AS `单位`,
 1 AS `累计采购量`,
 1 AS `建单人`,
 1 AS `建单时间`,
 1 AS `状态`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cdjtkjl`
--

DROP TABLE IF EXISTS `cdjtkjl`;


CREATE TABLE `cdjtkjl` (
  `DAYS` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `WKJ` bigint DEFAULT NULL,
  `KJ` bigint DEFAULT NULL,
  `KJL` decimal(20,0) DEFAULT NULL COMMENT 'kjl'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;


CREATE TABLE `customer` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `code` varchar(255) NOT NULL COMMENT '代号',
  `type` varchar(255) NOT NULL COMMENT '类型\r\n从常用类别获取客户类型',
  `abb` varchar(255) NOT NULL COMMENT '简称',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `delivery_method` char(6) DEFAULT NULL COMMENT '送货方式：获取基础数据sys_dict字典表code信息',
  `payment_method` char(6) DEFAULT NULL COMMENT '付款方式：获取基础数据sys_dict字典表code信息',
  `en_name` varchar(255) DEFAULT NULL COMMENT '英文名称',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(225) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='客户';


--
-- Table structure for table `customer_info`
--

DROP TABLE IF EXISTS `customer_info`;


CREATE TABLE `customer_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `fax_no` int DEFAULT NULL COMMENT '传真号',
  `phone1` varchar(255) DEFAULT NULL COMMENT '联系方式1',
  `phone2` varchar(255) DEFAULT NULL COMMENT '联系方式2',
  `contact` varchar(255) DEFAULT NULL COMMENT '联系人',
  `postal_code` varchar(255) DEFAULT NULL COMMENT '邮编',
  `business_name` varchar(255) DEFAULT NULL COMMENT '业务员',
  `addr` varchar(255) DEFAULT NULL COMMENT '地址',
  `en_address` varchar(255) DEFAULT NULL COMMENT '英文地址',
  `head` varchar(255) DEFAULT NULL COMMENT '负责人',
  `phone3` varchar(255) DEFAULT NULL COMMENT '报关电话',
  `fax2` varchar(255) DEFAULT NULL COMMENT '报关传真',
  `certificate_sno` varchar(18) DEFAULT NULL COMMENT '税号',
  `customs_seq` int DEFAULT NULL COMMENT '主管海关',
  `administer_customs_seq` int DEFAULT NULL COMMENT '管辖海关',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `customer_seq` (`customer_seq`) USING BTREE,
  CONSTRAINT `customer_info_ibfk_1` FOREIGN KEY (`customer_seq`) REFERENCES `customer` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='客户详情';


--
-- Table structure for table `customer_order_main`
--

DROP TABLE IF EXISTS `customer_order_main`;


CREATE TABLE `customer_order_main` (
  `seq` int NOT NULL,
  `firm_name` varchar(255) DEFAULT NULL COMMENT '工厂名称',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `brand_name` varchar(255) DEFAULT NULL COMMENT '品牌名称',
  `cj_time` varchar(255) DEFAULT NULL COMMENT '导单时间',
  `season` varchar(255) DEFAULT NULL COMMENT '季节',
  `customer_order` varchar(255) DEFAULT NULL COMMENT '客人订单号',
  `account_number` varchar(255) DEFAULT NULL COMMENT '订货款号',
  `item_number` varchar(255) DEFAULT NULL COMMENT '客人型体号',
  `erp_guide_code` varchar(255) DEFAULT NULL COMMENT 'ERP导单号',
  `po` varchar(255) DEFAULT NULL COMMENT 'po',
  `production_directives` varchar(255) DEFAULT NULL COMMENT '合并指令号',
  `production_date` varchar(255) DEFAULT NULL COMMENT '生产日期',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色',
  `order_count` varchar(255) DEFAULT NULL COMMENT '订单总数',
  `order_type` varchar(255) DEFAULT NULL COMMENT '订单类型',
  `delivery_address` varchar(255) DEFAULT NULL COMMENT '收货地',
  `order_stats` varchar(255) DEFAULT NULL COMMENT '订单属性',
  `taking_date` varchar(255) DEFAULT NULL COMMENT '接单日期',
  `delivery_time` varchar(255) DEFAULT NULL COMMENT '订单交期',
  `sign_time` varchar(255) DEFAULT NULL COMMENT '签字交期',
  `outsole_mold` varchar(255) DEFAULT NULL COMMENT '大底编号',
  `last_number` varchar(255) DEFAULT NULL COMMENT '楦头编号',
  `size_segment` varchar(255) DEFAULT NULL COMMENT '码段',
  `xg_time` varchar(255) DEFAULT NULL COMMENT '修改时间',
  `yesterday_in_stock_num_by_cx` double(11,2) DEFAULT NULL COMMENT '/成型昨日累计入库数量',
  `actual_out_date` varchar(255) DEFAULT NULL COMMENT '出货时间',
  `time_min_by_cx` varchar(255) DEFAULT NULL COMMENT '成型实际上线时间',
  `totalIn_stock_num_by_cx` double(255,0) DEFAULT NULL COMMENT '成型累计入库数量',
  `todayIn_stock_num_by_cx` double(255,0) DEFAULT NULL COMMENT '成型当天入库数量',
  `time_max_by_zc` varchar(255) DEFAULT NULL COMMENT '针车实际完成时间',
  `group_name_by_zc` varchar(255) DEFAULT NULL COMMENT '针车组别',
  `time_min_by_zc` varchar(255) DEFAULT NULL COMMENT '针车实际上线时间',
  `group_name_by_cx` varchar(255) DEFAULT NULL COMMENT '/成型组别',
  `await_out_num` double(11,2) DEFAULT NULL COMMENT '待出货数量',
  `plan_out_num` double(11,2) DEFAULT NULL COMMENT '计划出货数量',
  `yesterday_in_stock_num_by_zc` double(11,2) DEFAULT NULL COMMENT '针车昨日累计入库数量',
  `time_max_by_cx` varchar(255) DEFAULT NULL COMMENT '成型实际完成时间',
  `totalIn_stock_num_by_zc` double(11,2) DEFAULT NULL COMMENT '针车累计入库数量',
  `plan_out_date` varchar(255) DEFAULT NULL COMMENT '计划出货日期',
  `today_in_stock_num_by_zc` double(11,2) DEFAULT NULL COMMENT '针车当天入库数量',
  `total_out_num` double(11,2) DEFAULT NULL COMMENT '出货数量',
  PRIMARY KEY (`seq`),
  KEY `po` (`po`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='客户订单信息';


--
-- Table structure for table `demo_mail_schedule`
--

DROP TABLE IF EXISTS `demo_mail_schedule`;


CREATE TABLE `demo_mail_schedule` (
  `ID` varchar(36) NOT NULL,
  `RECEIVERS` varchar(512) DEFAULT NULL,
  `PATH` varchar(512) DEFAULT NULL,
  `NAME` varchar(50) DEFAULT NULL,
  `FORMAT` varchar(50) DEFAULT NULL,
  `ENABLED` varchar(2) DEFAULT NULL,
  `DELETED` varchar(2) DEFAULT NULL,
  `COMPRESSED` varchar(2) DEFAULT NULL,
  `MAIL_BODY` varchar(512) DEFAULT NULL,
  `CREATER` varchar(50) DEFAULT NULL,
  `CREATE_TIME` datetime DEFAULT NULL,
  `LASTER` varchar(50) DEFAULT NULL,
  `LASTUPDATE_TIME` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='邮箱发送';


--
-- Table structure for table `depm_prog`
--

DROP TABLE IF EXISTS `depm_prog`;


CREATE TABLE `depm_prog` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sample_order_seq` int DEFAULT NULL COMMENT '样品单序号',
  `customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `speed` varchar(24) DEFAULT NULL COMMENT '速度',
  `is_materials` char(1) DEFAULT '1' COMMENT '是否备料完成',
  `materials_status` varchar(255) DEFAULT NULL COMMENT '备料情况',
  `is_scheduling` char(1) DEFAULT '1' COMMENT '是否排产',
  `prod_quantity` varchar(255) DEFAULT NULL COMMENT '生产数量',
  `prod_date` timestamp NULL DEFAULT NULL COMMENT '生产安排日期',
  `director` varchar(255) DEFAULT NULL COMMENT '负责人',
  `is_delete` int DEFAULT '0' COMMENT '是否删除 0:未删除 1：删除',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `sample_order_seq` (`sample_order_seq`) USING BTREE,
  KEY `customer_seq` (`customer_seq`) USING BTREE,
  CONSTRAINT `depm_prog_ibfk_1` FOREIGN KEY (`sample_order_seq`) REFERENCES `sample_order` (`seq`),
  CONSTRAINT `depm_prog_ibfk_2` FOREIGN KEY (`customer_seq`) REFERENCES `customer` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品开发进度';


--
-- Table structure for table `depm_prog_properties`
--

DROP TABLE IF EXISTS `depm_prog_properties`;


CREATE TABLE `depm_prog_properties` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `depm_prog_seq` int DEFAULT NULL COMMENT '产品开发进度表序号',
  `type` varchar(255) DEFAULT NULL COMMENT '类型',
  `key` varchar(255) DEFAULT NULL COMMENT '类型key',
  `value` varchar(255) DEFAULT NULL COMMENT '类型value',
  `is_delete` int DEFAULT '0' COMMENT '未删除：0  删除：1',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `depm_prog_seq` (`depm_prog_seq`) USING BTREE,
  CONSTRAINT `depm_prog_properties_ibfk_1` FOREIGN KEY (`depm_prog_seq`) REFERENCES `depm_prog` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产品开发进度拓展表';


--
-- Table structure for table `dict_data`
--

DROP TABLE IF EXISTS `dict_data`;


CREATE TABLE `dict_data` (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int DEFAULT '0' COMMENT '字典排序',
  `dict_label` varchar(100) DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE,
  KEY `idx_dict_type_code` (`dict_type`,`dict_code`,`dict_value`)
) ENGINE=InnoDB AUTO_INCREMENT=450 DEFAULT CHARSET=utf8mb3 COMMENT='字典数据表';


--
-- Table structure for table `dict_type`
--

DROP TABLE IF EXISTS `dict_type`;


CREATE TABLE `dict_type` (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE KEY `dict_type` (`dict_type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3 COMMENT='字典类型表';


--
-- Table structure for table `equip_parameter`
--

DROP TABLE IF EXISTS `equip_parameter`;


CREATE TABLE `equip_parameter` (
  `id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '主键',
  `create_time` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'CREATE_TIME',
  `equip_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备名称',
  `equip_no` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备编号',
  `mac_address` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备地址',
  `current_sew_mode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '缝制模式',
  `current_speed` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '主轴转速',
  `network_state` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '网络状态',
  `power_on_time` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '开机时长',
  `preparing_time` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '准备时长',
  `runing_time` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '缝纫时长',
  `work_time` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '工作时间',
  `number` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '产量',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `file`
--

DROP TABLE IF EXISTS `file`;


CREATE TABLE `file` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `file_path` varchar(255) DEFAULT NULL COMMENT '文件路径',
  `new_file_name` varchar(255) DEFAULT NULL COMMENT '文件新名称',
  `old_file_name` varchar(255) DEFAULT NULL COMMENT '文件原名称',
  `file_key` varchar(255) DEFAULT NULL,
  `path_url` varchar(255) DEFAULT NULL COMMENT '文件全路径',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2192 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='文件表';


--
-- Table structure for table `flw_channel_definition`
--

DROP TABLE IF EXISTS `flw_channel_definition`;


CREATE TABLE `flw_channel_definition` (
  `ID_` varchar(255) NOT NULL,
  `NAME_` varchar(255) DEFAULT NULL,
  `VERSION_` int DEFAULT NULL,
  `KEY_` varchar(255) DEFAULT NULL,
  `CATEGORY_` varchar(255) DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(255) DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `TENANT_ID_` varchar(255) DEFAULT NULL,
  `RESOURCE_NAME_` varchar(255) DEFAULT NULL,
  `DESCRIPTION_` varchar(255) DEFAULT NULL,
  `TYPE_` varchar(255) DEFAULT NULL,
  `IMPLEMENTATION_` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_IDX_CHANNEL_DEF_UNIQ` (`KEY_`,`VERSION_`,`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `flw_ev_databasechangelog`
--

DROP TABLE IF EXISTS `flw_ev_databasechangelog`;


CREATE TABLE `flw_ev_databasechangelog` (
  `ID` varchar(255) NOT NULL,
  `AUTHOR` varchar(255) NOT NULL,
  `FILENAME` varchar(255) NOT NULL,
  `DATEEXECUTED` datetime NOT NULL,
  `ORDEREXECUTED` int NOT NULL,
  `EXECTYPE` varchar(10) NOT NULL,
  `MD5SUM` varchar(35) DEFAULT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `COMMENTS` varchar(255) DEFAULT NULL,
  `TAG` varchar(255) DEFAULT NULL,
  `LIQUIBASE` varchar(20) DEFAULT NULL,
  `CONTEXTS` varchar(255) DEFAULT NULL,
  `LABELS` varchar(255) DEFAULT NULL,
  `DEPLOYMENT_ID` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `flw_ev_databasechangeloglock`
--

DROP TABLE IF EXISTS `flw_ev_databasechangeloglock`;


CREATE TABLE `flw_ev_databasechangeloglock` (
  `ID` int NOT NULL,
  `LOCKED` bit(1) NOT NULL,
  `LOCKGRANTED` datetime DEFAULT NULL,
  `LOCKEDBY` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `flw_event_definition`
--

DROP TABLE IF EXISTS `flw_event_definition`;


CREATE TABLE `flw_event_definition` (
  `ID_` varchar(255) NOT NULL,
  `NAME_` varchar(255) DEFAULT NULL,
  `VERSION_` int DEFAULT NULL,
  `KEY_` varchar(255) DEFAULT NULL,
  `CATEGORY_` varchar(255) DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(255) DEFAULT NULL,
  `TENANT_ID_` varchar(255) DEFAULT NULL,
  `RESOURCE_NAME_` varchar(255) DEFAULT NULL,
  `DESCRIPTION_` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_IDX_EVENT_DEF_UNIQ` (`KEY_`,`VERSION_`,`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `flw_event_deployment`
--

DROP TABLE IF EXISTS `flw_event_deployment`;


CREATE TABLE `flw_event_deployment` (
  `ID_` varchar(255) NOT NULL,
  `NAME_` varchar(255) DEFAULT NULL,
  `CATEGORY_` varchar(255) DEFAULT NULL,
  `DEPLOY_TIME_` datetime(3) DEFAULT NULL,
  `TENANT_ID_` varchar(255) DEFAULT NULL,
  `PARENT_DEPLOYMENT_ID_` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `flw_event_resource`
--

DROP TABLE IF EXISTS `flw_event_resource`;


CREATE TABLE `flw_event_resource` (
  `ID_` varchar(255) NOT NULL,
  `NAME_` varchar(255) DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(255) DEFAULT NULL,
  `RESOURCE_BYTES_` longblob,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `flw_ru_batch`
--

DROP TABLE IF EXISTS `flw_ru_batch`;


CREATE TABLE `flw_ru_batch` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `TYPE_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `SEARCH_KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEARCH_KEY2_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) NOT NULL,
  `COMPLETE_TIME_` datetime(3) DEFAULT NULL,
  `STATUS_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `BATCH_DOC_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `flw_ru_batch_part`
--

DROP TABLE IF EXISTS `flw_ru_batch_part`;


CREATE TABLE `flw_ru_batch_part` (
  `ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `BATCH_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `SCOPE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEARCH_KEY_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEARCH_KEY2_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) NOT NULL,
  `COMPLETE_TIME_` datetime(3) DEFAULT NULL,
  `STATUS_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `RESULT_DOC_ID_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `FLW_IDX_BATCH_PART` (`BATCH_ID_`),
  CONSTRAINT `FLW_FK_BATCH_PART_PARENT` FOREIGN KEY (`BATCH_ID_`) REFERENCES `flw_ru_batch` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


--
-- Table structure for table `formwork`
--

DROP TABLE IF EXISTS `formwork`;


CREATE TABLE `formwork` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(22) DEFAULT NULL COMMENT '模板代号',
  `template` varchar(22) DEFAULT NULL COMMENT '模板说明',
  `matter` varchar(22) DEFAULT NULL COMMENT '物料类别',
  `material` varchar(22) DEFAULT NULL COMMENT '物料状态',
  `level` int DEFAULT NULL COMMENT '危险等级',
  `supervisory` varchar(22) DEFAULT NULL COMMENT '超收控制',
  `storehouse` varchar(22) DEFAULT NULL COMMENT '仓库类',
  `raw` varchar(22) DEFAULT NULL COMMENT '原料科目',
  `process` varchar(22) DEFAULT NULL COMMENT '在制科目',
  `safety_stock` varchar(22) DEFAULT NULL COMMENT '安全库存',
  `max_stock` varchar(22) DEFAULT NULL COMMENT '最大库存',
  `neg_stock` int DEFAULT '0' COMMENT '是否负库存 0:否 1：是',
  `warehouse_no` int DEFAULT NULL COMMENT '仓库',
  `place` int DEFAULT NULL COMMENT '储位',
  `delivery` int DEFAULT '0' COMMENT '允许快速收货 0:否 1：是''',
  `delivery_po` int DEFAULT '0' COMMENT '允许无po出货 0:否 1：是''',
  `materials` int DEFAULT '0' COMMENT '是否购买料 0:否 1：是''',
  `quoted` int DEFAULT '0' COMMENT '是否报价请求 0:否 1：是''',
  `requisition` int DEFAULT '0' COMMENT '是否先请购 0:否 1：是''',
  `purchases` int DEFAULT '0' COMMENT '采购用量控制 0:否 1：是''',
  `ectocyst` int DEFAULT '0' COMMENT '是否外包料 0:否 1：是''',
  `business` int DEFAULT '0' COMMENT '是否交易 0:否 1：是''',
  `max_purchases` int DEFAULT '0' COMMENT '最大采购量 0:否 1：是''',
  `safe` varchar(22) DEFAULT NULL COMMENT '采购安全期',
  `create_date` date DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(22) DEFAULT NULL COMMENT '创建人',
  `update_date` varchar(255) DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(255) DEFAULT NULL COMMENT '更新人',
  `is_delete` int DEFAULT '0' COMMENT '是否删除 0：否 1：是',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料模板';


--
-- Table structure for table `group_dispatch_order`
--

DROP TABLE IF EXISTS `group_dispatch_order`;


CREATE TABLE `group_dispatch_order` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dispatch_group_code` varchar(20) DEFAULT NULL COMMENT '组别派工单号',
  `firm_id` int DEFAULT NULL COMMENT '公司id',
  `firm_name` varchar(50) DEFAULT NULL COMMENT '公司名称',
  `department_id` int DEFAULT NULL COMMENT '部门id',
  `department_name` varchar(50) DEFAULT NULL COMMENT '部门名称',
  `group_id` int DEFAULT NULL COMMENT '组别id',
  `group_name` varchar(50) DEFAULT NULL COMMENT '组别名称',
  `produce_seq` int DEFAULT NULL,
  `produce_code` varchar(20) DEFAULT NULL COMMENT '生产单号',
  `start_time` date DEFAULT NULL COMMENT '派工单生产开始时间',
  `end_time` date DEFAULT NULL COMMENT '派工单生产结束时间',
  `process_id` int DEFAULT NULL COMMENT 'erp制程序号',
  `process` varchar(50) DEFAULT NULL COMMENT '制程名称',
  `po` varchar(50) DEFAULT NULL COMMENT 'po',
  `sku` varchar(50) DEFAULT NULL COMMENT 'sku',
  `customer_order` varchar(50) DEFAULT NULL COMMENT '客户订单',
  `brand_name` varchar(50) DEFAULT NULL COMMENT '品牌',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户',
  `item_number` varchar(50) DEFAULT NULL COMMENT '客户货号',
  `pid` varchar(20) DEFAULT NULL COMMENT '制程代号',
  `created_by` varchar(64) DEFAULT NULL COMMENT '同步人',
  `created_at` datetime DEFAULT NULL COMMENT '同步时间',
  `mes_firm_id` int DEFAULT NULL,
  `mes_firm_name` varchar(50) DEFAULT NULL,
  `mes_department_id` int DEFAULT NULL,
  `mes_department_name` varchar(50) DEFAULT NULL,
  `mes_group_id` int DEFAULT NULL,
  `mes_group_name` varchar(50) DEFAULT NULL,
  `quantity` int DEFAULT '0' COMMENT '总数量',
  `mes_customer_name` varchar(50) DEFAULT NULL COMMENT 'mes客户',
  `is_process` int DEFAULT '0' COMMENT '是否处理 0未处理 1已处理',
  `od_product_order_code` varchar(255) DEFAULT NULL COMMENT 'erp生产单号',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=1436 DEFAULT CHARSET=utf8mb3 COMMENT='组别派工单';


--
-- Table structure for table `group_dispatch_order_size`
--

DROP TABLE IF EXISTS `group_dispatch_order_size`;


CREATE TABLE `group_dispatch_order_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dispatch_group_code` varchar(20) NOT NULL COMMENT '组别派工单号',
  `size_key` varchar(20) DEFAULT NULL COMMENT '尺码',
  `size_value` int DEFAULT NULL COMMENT '数量',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=5022 DEFAULT CHARSET=utf8mb3 COMMENT='组别派工单尺码';


--
-- Table structure for table `group_dispatch_position_material`
--

DROP TABLE IF EXISTS `group_dispatch_position_material`;


CREATE TABLE `group_dispatch_position_material` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `dispatch_group_code` varchar(20) DEFAULT NULL COMMENT '派工单号',
  `po` varchar(255) DEFAULT NULL COMMENT '行标识也就是PO',
  `od_prod_order_seq` int DEFAULT NULL COMMENT '生产订单号',
  `od_prod_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `order_doc_aritcle_seq` varchar(255) DEFAULT NULL COMMENT '正式订单型体seq',
  `art_name` varchar(50) DEFAULT NULL COMMENT '型体名称',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编码',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `material_info_code` varchar(50) DEFAULT NULL COMMENT '物料编码',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料简码名称',
  `material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料编码颜色名称',
  `mx_material_category_purchase_unit_name` varchar(255) DEFAULT NULL COMMENT '采购单位',
  `demand_quantity` varchar(100) DEFAULT NULL COMMENT '需求数量',
  `size_code` varchar(50) DEFAULT NULL COMMENT '尺码code',
  `received_quantity` varchar(100) DEFAULT NULL COMMENT '已领数量',
  `please_material_factory` varchar(255) DEFAULT NULL COMMENT '请料工厂',
  `please_material_division` varchar(255) DEFAULT NULL COMMENT '请料部门',
  `please_material_workshop` varchar(255) DEFAULT NULL COMMENT '请料车间',
  `workshop_team` varchar(255) DEFAULT NULL COMMENT '车间小组',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=74459 DEFAULT CHARSET=utf8mb3 COMMENT='组别派工单部位物料信息表';


--
-- Table structure for table `group_dispatch_position_size_material_usage`
--

DROP TABLE IF EXISTS `group_dispatch_position_size_material_usage`;


CREATE TABLE `group_dispatch_position_size_material_usage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `group_dispatch_position_material_seq` int DEFAULT NULL COMMENT '组别派工单部位物料信息表seq',
  `material_info_code` varchar(50) DEFAULT NULL,
  `od_product_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体尺码序号',
  `size_seq` int DEFAULT NULL COMMENT '正式订单尺码序号（order_art_size_seq）',
  `size_code` varchar(50) DEFAULT NULL COMMENT 'size编码',
  `size_name` varchar(50) DEFAULT NULL COMMENT 'size名称',
  `prod_size_num` varchar(50) DEFAULT NULL COMMENT '生产订单数量',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=74459 DEFAULT CHARSET=utf8mb3 COMMENT='组别派工单部位尺码物料用量表';


--
-- Table structure for table `knife`
--

DROP TABLE IF EXISTS `knife`;


CREATE TABLE `knife` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(22) DEFAULT NULL COMMENT '斩刀代号',
  `part_no` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `part_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `matter_name` varchar(50) DEFAULT NULL COMMENT '物料名称',
  `model_no` varchar(22) DEFAULT NULL COMMENT '型体编号',
  `size_class` varchar(22) DEFAULT NULL COMMENT 'SIZE类别',
  `type_code` varchar(22) DEFAULT NULL COMMENT '型体代号',
  `width_ratio` varchar(22) DEFAULT NULL COMMENT '宽放比',
  `length` varchar(22) DEFAULT NULL COMMENT '长度',
  `width` varchar(22) DEFAULT NULL COMMENT '宽度',
  `specifications` varchar(22) DEFAULT NULL COMMENT '规格',
  `wide_width` varchar(22) DEFAULT NULL COMMENT '宽幅',
  `verify_date` date DEFAULT NULL COMMENT '审核时间',
  `verify_name` varchar(22) DEFAULT NULL COMMENT '审核人',
  `created_by` varchar(22) DEFAULT NULL COMMENT '建档人',
  `update_by` varchar(22) DEFAULT NULL COMMENT '修改人',
  `update_date` time(6) DEFAULT NULL COMMENT '修改时间',
  `created_at` date DEFAULT NULL COMMENT '建档时间',
  `veri_status` int DEFAULT '0' COMMENT '是否审核 0:未审核 1:审核',
  `order_no` varchar(22) DEFAULT NULL COMMENT '序号',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='斩刀用量设定';


--
-- Table structure for table `knife_info`
--

DROP TABLE IF EXISTS `knife_info`;


CREATE TABLE `knife_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `knife_seq` int NOT NULL COMMENT '外键',
  `produce_size` varchar(22) DEFAULT NULL COMMENT '生产SIZE',
  `chopping_size` varchar(22) DEFAULT NULL COMMENT '斩刀SIZE',
  `shoeLast_size` varchar(22) DEFAULT NULL COMMENT '楦头SIZE',
  `chopper_num` varchar(22) DEFAULT NULL COMMENT '斩刀用量',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `knife_foregin_key` (`knife_seq`) USING BTREE,
  CONSTRAINT `knife_foregin_key` FOREIGN KEY (`knife_seq`) REFERENCES `knife` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='斩刀用量设定详情表';


--
-- Table structure for table `knife_position`
--

DROP TABLE IF EXISTS `knife_position`;


CREATE TABLE `knife_position` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `batch_seq` int DEFAULT NULL COMMENT '物料seq',
  `position_seq` int DEFAULT NULL COMMENT '部件seq',
  `knife_seq` int DEFAULT NULL COMMENT '斩刀seq',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;


--
-- Table structure for table `mac`
--

DROP TABLE IF EXISTS `mac`;


CREATE TABLE `mac` (
  `MAC_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `MAC_NAME` varchar(255) DEFAULT NULL COMMENT '设备名称',
  `MAC_CUS` bigint DEFAULT NULL COMMENT '公司名称',
  `MAC_DATE` datetime DEFAULT NULL,
  `MAC_TYPE` bigint DEFAULT NULL COMMENT '设备类型：自动、非自动',
  `MAC_PROC` varchar(255) DEFAULT NULL COMMENT '设备制程：裁断、针车、成型',
  `MAC_STATUS` varchar(255) DEFAULT NULL COMMENT '设备状态：（0：上电 ，1：待机 ，2：联机， 3：运行，x:离线）',
  `REPAIR_TIMES` decimal(10,0) DEFAULT NULL COMMENT '维修次数',
  PRIMARY KEY (`MAC_ID`),
  UNIQUE KEY `idx` (`MAC_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;


--
-- Table structure for table `mac1`
--

DROP TABLE IF EXISTS `mac1`;


CREATE TABLE `mac1` (
  `mac_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'MAC_ID',
  `mac_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_NAME',
  `mac_date` datetime(3) DEFAULT NULL COMMENT 'MAC_DATE',
  `mac_sts_l` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_STS_L',
  `mac_sts_r` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_STS_R',
  `mac_opert` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_OPERT',
  `mac_cus` bigint DEFAULT NULL COMMENT 'MAC_CUS',
  `mac_type` bigint DEFAULT NULL COMMENT 'MAC_TYPE',
  `mac_speed_l` decimal(30,6) DEFAULT NULL COMMENT 'MAC_SPEED_L',
  `mac_speed_r` decimal(30,6) DEFAULT NULL COMMENT 'MAC_SPEED_R',
  `mac_output` bigint DEFAULT NULL COMMENT 'MAC_OUTPUT',
  `mac_ie_ratio` decimal(8,2) DEFAULT NULL COMMENT 'MAC_IE_RATIO',
  PRIMARY KEY (`mac_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mac2`
--

DROP TABLE IF EXISTS `mac2`;


CREATE TABLE `mac2` (
  `mac_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'MAC_ID',
  `mac_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_NAME',
  `mac_date` datetime(3) DEFAULT NULL COMMENT 'MAC_DATE',
  `mac_sts_l` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_STS_L',
  `mac_sts_r` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_STS_R',
  `mac_opert` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_OPERT',
  `mac_cus` bigint DEFAULT NULL COMMENT 'MAC_CUS',
  `mac_type` bigint DEFAULT NULL COMMENT 'MAC_TYPE',
  `mac_speed_l` decimal(30,6) DEFAULT NULL COMMENT 'MAC_SPEED_L',
  `mac_speed_r` decimal(30,6) DEFAULT NULL COMMENT 'MAC_SPEED_R',
  `mac_output` bigint DEFAULT NULL COMMENT 'MAC_OUTPUT',
  `mac_ie_ratio` decimal(8,2) DEFAULT NULL COMMENT 'MAC_IE_RATIO',
  PRIMARY KEY (`mac_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mac3`
--

DROP TABLE IF EXISTS `mac3`;


CREATE TABLE `mac3` (
  `mac_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'MAC_ID',
  `mac_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_NAME',
  `mac_date` datetime(3) DEFAULT NULL COMMENT 'MAC_DATE',
  `mac_sts_l` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_STS_L',
  `mac_sts_r` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_STS_R',
  `mac_opert` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_OPERT',
  `mac_cus` bigint DEFAULT NULL COMMENT 'MAC_CUS',
  `mac_type` bigint DEFAULT NULL COMMENT 'MAC_TYPE',
  `mac_speed_l` decimal(30,6) DEFAULT NULL COMMENT 'MAC_SPEED_L',
  `mac_speed_r` decimal(30,6) DEFAULT NULL COMMENT 'MAC_SPEED_R',
  `mac_output` bigint DEFAULT NULL COMMENT 'MAC_OUTPUT',
  `mac_ie_ratio` decimal(8,2) DEFAULT NULL COMMENT 'MAC_IE_RATIO',
  PRIMARY KEY (`mac_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mac_copy1`
--

DROP TABLE IF EXISTS `mac_copy1`;


CREATE TABLE `mac_copy1` (
  `id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `mac_name` varchar(255) DEFAULT NULL COMMENT '设备名称',
  `MAC_CUS` bigint DEFAULT NULL COMMENT '公司名称',
  `mac_date` datetime DEFAULT NULL,
  `MAC_TYPE` bigint DEFAULT NULL COMMENT '设备类型：自动、非自动',
  `mac_proc` varchar(255) DEFAULT NULL COMMENT '设备制程：裁断、针车、成型',
  `mac_stauts` varchar(255) DEFAULT NULL COMMENT '设备状态：（0：上电 ，1：待机 ，2：联机， 3：运行，x:离线）',
  `repair_times` decimal(10,0) DEFAULT NULL COMMENT '维修次数',
  `MAC_STS_L` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_STS_R` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_OPERT` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_SPEED_L` decimal(30,6) DEFAULT NULL,
  `MAC_SPEED_R` decimal(30,6) DEFAULT NULL,
  `MAC_OUTPUT` bigint DEFAULT NULL,
  `MAC_IE_RATIO` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`MAC_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;


--
-- Table structure for table `mac_oee`
--

DROP TABLE IF EXISTS `mac_oee`;


CREATE TABLE `mac_oee` (
  `id` varchar(36) NOT NULL,
  `mac_id` varchar(36) DEFAULT NULL COMMENT '设备id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL,
  `equip_name` varchar(255) DEFAULT NULL COMMENT '设备名称',
  `equip_no` varchar(0) DEFAULT NULL COMMENT '设备编号',
  `mac_address` varchar(255) DEFAULT NULL COMMENT '设备地址',
  `power_on_time` varchar(40) DEFAULT NULL COMMENT '开机时长',
  `preparing_time` varchar(40) DEFAULT NULL COMMENT '准备时长',
  `work_start` datetime DEFAULT NULL COMMENT '上班开始时间',
  `runing_time` decimal(18,2) DEFAULT NULL COMMENT '运行时长',
  `work_end` datetime DEFAULT NULL COMMENT '上班结束时间',
  `work_time` varchar(40) DEFAULT NULL COMMENT '工作时长',
  `stop_time` varchar(40) DEFAULT NULL COMMENT '停机时长',
  `pause_time` varchar(40) DEFAULT NULL COMMENT '暂停时长',
  `day_oee` decimal(18,2) DEFAULT NULL COMMENT '日稼动率',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;


--
-- Table structure for table `mac_oee1`
--

DROP TABLE IF EXISTS `mac_oee1`;


CREATE TABLE `mac_oee1` (
  `mac_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_ID',
  `mac_querystart` datetime(3) DEFAULT NULL COMMENT 'MAC_QUERYSTART',
  `mac_queryend` datetime(3) DEFAULT NULL COMMENT 'MAC_QUERYEND',
  `mac_uptime` decimal(30,6) DEFAULT NULL COMMENT 'MAC_UPTIME',
  `mac_downtime` decimal(30,6) DEFAULT NULL COMMENT 'MAC_DOWNTIME',
  `mac_runrate` decimal(30,6) DEFAULT NULL COMMENT 'MAC_RUNRATE',
  `mac_cutnum` bigint DEFAULT NULL COMMENT 'MAC_CUTNUM',
  `mac_targetnum` bigint DEFAULT NULL COMMENT 'MAC_TARGETNUM',
  `mac_unqnum` bigint DEFAULT NULL COMMENT 'MAC_UNQNUM'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mac_oee2`
--

DROP TABLE IF EXISTS `mac_oee2`;


CREATE TABLE `mac_oee2` (
  `mac_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_ID',
  `mac_querystart` datetime(3) DEFAULT NULL COMMENT 'MAC_QUERYSTART',
  `mac_queryend` datetime(3) DEFAULT NULL COMMENT 'MAC_QUERYEND',
  `mac_uptime` decimal(30,6) DEFAULT NULL COMMENT 'MAC_UPTIME',
  `mac_downtime` decimal(30,6) DEFAULT NULL COMMENT 'MAC_DOWNTIME',
  `mac_runrate` decimal(30,6) DEFAULT NULL COMMENT 'MAC_RUNRATE',
  `mac_cutnum` bigint DEFAULT NULL COMMENT 'MAC_CUTNUM',
  `mac_targetnum` bigint DEFAULT NULL COMMENT 'MAC_TARGETNUM',
  `mac_unqnum` bigint DEFAULT NULL COMMENT 'MAC_UNQNUM'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mac_oee_detail`
--

DROP TABLE IF EXISTS `mac_oee_detail`;


CREATE TABLE `mac_oee_detail` (
  `MAC_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_QUERYSTART` datetime(3) DEFAULT NULL,
  `MAC_QUERYEND` datetime(3) DEFAULT NULL,
  `MAC_UPTIME` decimal(30,6) DEFAULT NULL,
  `MAC_DOWNTIME` decimal(30,6) DEFAULT NULL,
  `MAC_RUNRATE` decimal(30,6) DEFAULT NULL,
  `MAC_CUTNUM` bigint DEFAULT NULL,
  `MAC_TARGETNUM` bigint DEFAULT NULL,
  `MAC_UNQNUM` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mac_oee_detail_zhenche`
--

DROP TABLE IF EXISTS `mac_oee_detail_zhenche`;


CREATE TABLE `mac_oee_detail_zhenche` (
  `id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '主键',
  `create_time` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'CREATE_TIME',
  `equip_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备名称',
  `equip_no` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备编号',
  `mac_address` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备地址',
  `current_sew_mode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '缝制模式',
  `current_speed` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '主轴转速',
  `network_state` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '网络状态',
  `power_on_time` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '开机时长',
  `preparing_time` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '准备时长',
  `runing_time` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '缝纫时长',
  `work_time` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '工作时间',
  `number` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '产量'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mac_oee_zhenche_detail`
--

DROP TABLE IF EXISTS `mac_oee_zhenche_detail`;


CREATE TABLE `mac_oee_zhenche_detail` (
  `mac_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_ID',
  `mac_querystart` datetime(3) DEFAULT NULL COMMENT 'MAC_QUERYSTART',
  `mac_queryend` datetime(3) DEFAULT NULL COMMENT 'MAC_QUERYEND',
  `mac_uptime` decimal(30,6) DEFAULT NULL COMMENT 'MAC_UPTIME',
  `mac_downtime` decimal(30,6) DEFAULT NULL COMMENT 'MAC_DOWNTIME',
  `mac_runrate` decimal(30,6) DEFAULT NULL COMMENT 'MAC_RUNRATE',
  `mac_cutnum` bigint DEFAULT NULL COMMENT 'MAC_CUTNUM',
  `mac_targetnum` bigint DEFAULT NULL COMMENT 'MAC_TARGETNUM',
  `mac_unqnum` bigint DEFAULT NULL COMMENT 'MAC_UNQNUM'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mat_customer_material`
--

DROP TABLE IF EXISTS `mat_customer_material`;


CREATE TABLE `mat_customer_material` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键seq',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `quarter_name` varchar(40) DEFAULT NULL COMMENT '季度名称',
  `article_seq_list` varchar(1000) DEFAULT NULL COMMENT '产品seq列表',
  `customer_seq` int NOT NULL COMMENT '客户信息seq',
  `material_info_seq` int DEFAULT NULL COMMENT '物料信息seq',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(500) DEFAULT NULL,
  `material_info_size` varchar(20) DEFAULT NULL COMMENT '物料尺码size',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(100) DEFAULT NULL COMMENT '物料简码编号',
  `material_category_name` text COMMENT '简码名称',
  `provider_seq` int DEFAULT NULL COMMENT '默认供应商id',
  `provider_name` varchar(100) DEFAULT NULL COMMENT '默认供应商名称',
  `purchase_unit_seq` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '采购单位名称',
  `article_sku_list` varchar(1000) DEFAULT NULL COMMENT '产品sku列表',
  `is_inquiry` int NOT NULL DEFAULT '0' COMMENT '是否询价 1询价  0未询价',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=23665 DEFAULT CHARSET=utf8mb3 COMMENT='客户物料关联关系表';


--
-- Table structure for table `mat_material_supplier`
--

DROP TABLE IF EXISTS `mat_material_supplier`;


CREATE TABLE `mat_material_supplier` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商信息seq',
  `supplier_name` varchar(100) DEFAULT NULL COMMENT '供应商名称',
  `supplier_code` varchar(100) DEFAULT NULL COMMENT '供应商编码',
  `material_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_name` varchar(1000) DEFAULT NULL COMMENT '物料名称',
  `category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `material_seq` int DEFAULT NULL COMMENT '物料seq',
  `material_info_seq` int DEFAULT NULL COMMENT '物料信息seq',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `internal_code` varchar(100) DEFAULT NULL COMMENT '供应商内部物料编码',
  `internal_name` varchar(100) DEFAULT NULL COMMENT '供应商内部物料名称',
  `color_code` varchar(50) DEFAULT NULL COMMENT '颜色编码',
  `color_name` text COMMENT '颜色名称',
  `class_seq` int DEFAULT NULL COMMENT '物料类别id',
  `class_name` varchar(100) DEFAULT NULL COMMENT '物料类别名称',
  `unit_seq` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `is_out_sourcing` int DEFAULT NULL COMMENT '是否外加工',
  `is_quotation` char(1) DEFAULT NULL COMMENT '物料报价状态:1-未报价,2-报价已过期,3-已报价',
  `is_def` char(1) DEFAULT '1' COMMENT '是否默认供应商:0-否,1-是',
  `inquiry_material_status` char(1) DEFAULT '0' COMMENT '询价单物料是否报价:0-否,1-是',
  `effective_date_begin` date DEFAULT NULL COMMENT '生效起',
  `effective_date_end` date DEFAULT NULL COMMENT '生效止',
  `minimum_quantity` varchar(100) DEFAULT NULL COMMENT '最小起购量',
  `is_logistics` char(2) DEFAULT NULL COMMENT '是否物流费:0-否,1-是',
  `estimated_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '预估单价',
  `bulk_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '大货单价',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=22418 DEFAULT CHARSET=utf8mb3 COMMENT='物料供应商关联';


--
-- Table structure for table `mat_price_inquiry`
--

DROP TABLE IF EXISTS `mat_price_inquiry`;


CREATE TABLE `mat_price_inquiry` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(20) DEFAULT NULL COMMENT '询价单号',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `inquiry_person_num` varchar(50) DEFAULT NULL COMMENT '询价人账号',
  `inquiry_person` varchar(50) DEFAULT NULL COMMENT '询价人',
  `inquiry_dept_id` int DEFAULT NULL COMMENT '询价部门id',
  `inquiry_dept_name` varchar(50) DEFAULT NULL COMMENT '询价部门名称',
  `inquiry_status` varchar(5) DEFAULT NULL COMMENT '询价单状态：51-草稿,10-提交,20-待审批,21-审批中,22-转办,23-委派,24-抄送,25-退回,26-驳回,1-撤回,50-完成，52 询价中，53 询价完成',
  `quote_status` varchar(5) DEFAULT NULL COMMENT '报价单状态：0-草稿,1-提交,2-待审批3-审批中,4-转办,5-委派,6-抄送,7-退回,8-驳回,9-撤回,10-完成,11-供应商报价中,12-供应商完成',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_def_supplier` char(1) DEFAULT NULL COMMENT '是否带入默认供应商:0-否,1-是',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除:0-否,1-是',
  `enable` char(1) DEFAULT '1' COMMENT '是否有效:0-否,1-是',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `status` int DEFAULT NULL COMMENT '状态',
  `created_by_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=246 DEFAULT CHARSET=utf8mb3 COMMENT='物料询价单';


--
-- Table structure for table `mat_price_inquiry_addr`
--

DROP TABLE IF EXISTS `mat_price_inquiry_addr`;


CREATE TABLE `mat_price_inquiry_addr` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '询价单seq',
  `addr` varchar(255) DEFAULT NULL COMMENT '地址',
  `detailed_addr` varchar(255) DEFAULT NULL COMMENT '详细地址',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=246 DEFAULT CHARSET=utf8mb3 COMMENT='询价单物料交期明细地点';


--
-- Table structure for table `mat_price_inquiry_copy1`
--

DROP TABLE IF EXISTS `mat_price_inquiry_copy1`;


CREATE TABLE `mat_price_inquiry_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(20) DEFAULT NULL COMMENT '询价单号',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `inquiry_person_num` varchar(50) DEFAULT NULL COMMENT '询价人账号',
  `inquiry_person` varchar(50) DEFAULT NULL COMMENT '询价人',
  `inquiry_dept_id` int DEFAULT NULL COMMENT '询价部门id',
  `inquiry_dept_name` varchar(50) DEFAULT NULL COMMENT '询价部门名称',
  `inquiry_status` varchar(5) DEFAULT NULL COMMENT '询价单状态：51-草稿,10-提交,20-待审批,21-审批中,22-转办,23-委派,24-抄送,25-退回,26-驳回,1-撤回,50-完成，52 询价中，53 询价完成',
  `quote_status` varchar(5) DEFAULT NULL COMMENT '报价单状态：0-草稿,1-提交,2-待审批3-审批中,4-转办,5-委派,6-抄送,7-退回,8-驳回,9-撤回,10-完成,11-供应商报价中,12-供应商完成',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_def_supplier` char(1) DEFAULT NULL COMMENT '是否带入默认供应商:0-否,1-是',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除:0-否,1-是',
  `enable` char(1) DEFAULT '1' COMMENT '是否有效:0-否,1-是',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `status` int DEFAULT NULL COMMENT '状态',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb3 COMMENT='物料询价单';


--
-- Table structure for table `mat_price_inquiry_info`
--

DROP TABLE IF EXISTS `mat_price_inquiry_info`;


CREATE TABLE `mat_price_inquiry_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `om_art_position_material_seq` int DEFAULT NULL,
  `customer_material_seq` int DEFAULT NULL COMMENT '客户物料关系表seq',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '物料询价单seq',
  `mat_material_supplier_seq` int DEFAULT NULL COMMENT '物料供应商关系表seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_name` varchar(50) DEFAULT NULL COMMENT '供应商Name',
  `inquiry_material_status` char(1) DEFAULT '0' COMMENT '询价单物料是否报价:0-否,1-是',
  `internal_code` varchar(100) DEFAULT NULL COMMENT '供应商内部物料编码',
  `internal_name` varchar(100) DEFAULT NULL COMMENT '供应商内部物料名称',
  `effective_date_begin` date DEFAULT NULL COMMENT '生效起',
  `effective_date_end` date DEFAULT NULL COMMENT '生效止',
  `minimum_quantity` varchar(100) DEFAULT NULL COMMENT '最小起购量',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `is_logistics` char(2) DEFAULT NULL COMMENT '是否物流费:0-否,1-是',
  `estimated_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '预估单价',
  `bulk_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '大货单价',
  `min_quantity` int DEFAULT NULL COMMENT '最小采购量',
  `min_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最小采购量单价',
  `max_quantity` int DEFAULT NULL COMMENT '最大采购量',
  `max_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最大采购量单价',
  `confirm_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '是否确认报价',
  `submit_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '提交状态(0草稿，1提交报价(待询价详情确认报价))',
  `sku` varchar(1000) DEFAULT NULL COMMENT 'sku',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `created_by` varchar(80) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(80) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(80) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_by_name` varchar(255) DEFAULT NULL,
  `material_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `material_name` text COMMENT '物料名称',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `inquiry_material_info_seq` int DEFAULT NULL COMMENT '询价明细seq',
  PRIMARY KEY (`seq`),
  KEY `customer_material_seq` (`customer_material_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2756 DEFAULT CHARSET=utf8mb3 COMMENT='询价明细表';


--
-- Table structure for table `mat_price_inquiry_info_copy1`
--

DROP TABLE IF EXISTS `mat_price_inquiry_info_copy1`;


CREATE TABLE `mat_price_inquiry_info_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `om_art_position_material_seq` int DEFAULT NULL,
  `customer_material_seq` int DEFAULT NULL COMMENT '客户物料关系表seq',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '物料询价单seq',
  `mat_material_supplier_seq` int DEFAULT NULL COMMENT '物料供应商关系表seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_name` varchar(50) DEFAULT NULL COMMENT '供应商Name',
  `inquiry_material_status` char(1) DEFAULT '0' COMMENT '询价单物料是否报价:0-否,1-是',
  `internal_code` varchar(100) DEFAULT NULL COMMENT '供应商内部物料编码',
  `internal_name` varchar(100) DEFAULT NULL COMMENT '供应商内部物料名称',
  `effective_date_begin` date DEFAULT NULL COMMENT '生效起',
  `effective_date_end` date DEFAULT NULL COMMENT '生效止',
  `minimum_quantity` varchar(100) DEFAULT NULL COMMENT '最小起购量',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `is_logistics` char(2) DEFAULT NULL COMMENT '是否物流费:0-否,1-是',
  `estimated_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '预估单价',
  `bulk_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '大货单价',
  `min_quantity` int DEFAULT NULL COMMENT '最小采购量',
  `min_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最小采购量单价',
  `max_quantity` int DEFAULT NULL COMMENT '最大采购量',
  `max_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最大采购量单价',
  `confirm_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '是否确认报价',
  `submit_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '提交状态(0草稿，1提交报价(待询价详情确认报价))',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `created_by` varchar(80) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(80) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(80) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=193 DEFAULT CHARSET=utf8mb3 COMMENT='询价明细表';


--
-- Table structure for table `mat_price_inquiry_info_tmp`
--

DROP TABLE IF EXISTS `mat_price_inquiry_info_tmp`;


CREATE TABLE `mat_price_inquiry_info_tmp` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键',
  `om_art_position_material_seq` int DEFAULT NULL,
  `customer_material_seq` int DEFAULT NULL COMMENT '客户物料关系表seq',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '物料询价单seq',
  `mat_material_supplier_seq` int DEFAULT NULL COMMENT '物料供应商关系表seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_name` varchar(50) DEFAULT NULL COMMENT '供应商Name',
  `inquiry_material_status` char(1) DEFAULT '0' COMMENT '询价单物料是否报价:0-否,1-是',
  `internal_code` varchar(100) DEFAULT NULL COMMENT '供应商内部物料编码',
  `internal_name` varchar(100) DEFAULT NULL COMMENT '供应商内部物料名称',
  `effective_date_begin` date DEFAULT NULL COMMENT '生效起',
  `effective_date_end` date DEFAULT NULL COMMENT '生效止',
  `minimum_quantity` varchar(100) DEFAULT NULL COMMENT '最小起购量',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `is_logistics` char(2) DEFAULT NULL COMMENT '是否物流费:0-否,1-是',
  `estimated_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '预估单价',
  `bulk_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '大货单价',
  `min_quantity` int DEFAULT NULL COMMENT '最小采购量',
  `min_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最小采购量单价',
  `max_quantity` int DEFAULT NULL COMMENT '最大采购量',
  `max_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最大采购量单价',
  `confirm_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '是否确认报价',
  `submit_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '提交状态(0草稿，1提交报价(待询价详情确认报价))'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mat_price_inquiry_info_tmp_copy1`
--

DROP TABLE IF EXISTS `mat_price_inquiry_info_tmp_copy1`;


CREATE TABLE `mat_price_inquiry_info_tmp_copy1` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键',
  `om_art_position_material_seq` int DEFAULT NULL,
  `customer_material_seq` int DEFAULT NULL COMMENT '客户物料关系表seq',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '物料询价单seq',
  `mat_material_supplier_seq` int DEFAULT NULL COMMENT '物料供应商关系表seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_name` varchar(50) DEFAULT NULL COMMENT '供应商Name',
  `inquiry_material_status` char(1) DEFAULT '0' COMMENT '询价单物料是否报价:0-否,1-是',
  `internal_code` varchar(100) DEFAULT NULL COMMENT '供应商内部物料编码',
  `internal_name` varchar(100) DEFAULT NULL COMMENT '供应商内部物料名称',
  `effective_date_begin` date DEFAULT NULL COMMENT '生效起',
  `effective_date_end` date DEFAULT NULL COMMENT '生效止',
  `minimum_quantity` varchar(100) DEFAULT NULL COMMENT '最小起购量',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `is_logistics` char(2) DEFAULT NULL COMMENT '是否物流费:0-否,1-是',
  `estimated_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '预估单价',
  `bulk_unit_price` decimal(12,2) unsigned zerofill DEFAULT NULL COMMENT '大货单价',
  `min_quantity` int DEFAULT NULL COMMENT '最小采购量',
  `min_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最小采购量单价',
  `max_quantity` int DEFAULT NULL COMMENT '最大采购量',
  `max_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最大采购量单价',
  `confirm_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '是否确认报价',
  `submit_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '提交状态(0草稿，1提交报价(待询价详情确认报价))'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mat_price_inquiry_material_delivery`
--

DROP TABLE IF EXISTS `mat_price_inquiry_material_delivery`;


CREATE TABLE `mat_price_inquiry_material_delivery` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键seq',
  `mat_price_inquiry_info_seq` int NOT NULL COMMENT '询价明细seq',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价单号',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '供应商编码',
  `supplier_name` varchar(100) DEFAULT NULL COMMENT '供应商名称',
  `supplier_add_name` varchar(50) DEFAULT NULL COMMENT '供应商简称',
  `purchase_unit_id` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '采购单位',
  `min_quantity` int DEFAULT NULL COMMENT '最小采购量',
  `min_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最小采购量单价',
  `max_quantity` int DEFAULT NULL COMMENT '最大采购量',
  `max_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最大采购量单价',
  `price_num` int DEFAULT NULL COMMENT '报价数量',
  `unit_id` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `interval_begin` int DEFAULT NULL COMMENT '区间起',
  `interval_end` int DEFAULT NULL COMMENT '区间止',
  `no_price` decimal(10,2) DEFAULT NULL COMMENT '单价(不含税)',
  `tax_rate` varchar(100) DEFAULT NULL COMMENT '税率',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价(含税)',
  `row_index` int DEFAULT NULL COMMENT '行标',
  `confirm_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '确认报价',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `created_by` varchar(80) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(80) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(80) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COMMENT='物料报价明细';


--
-- Table structure for table `mat_price_inquiry_material_delivery_addr`
--

DROP TABLE IF EXISTS `mat_price_inquiry_material_delivery_addr`;


CREATE TABLE `mat_price_inquiry_material_delivery_addr` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `mat_price_inquiry_material_delivery_seq` int DEFAULT NULL COMMENT '物料报价明细seq',
  `mat_price_inquiry_info_seq` int DEFAULT NULL COMMENT '询价明细seq',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '询价单seq',
  `addr` varchar(255) DEFAULT NULL COMMENT '地址',
  `detailed_addr` varchar(255) DEFAULT NULL COMMENT '详细地址',
  `logistics_price` decimal(10,2) DEFAULT NULL COMMENT '物流单价',
  `total_price` decimal(10,2) DEFAULT NULL COMMENT '物料总价',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=3172 DEFAULT CHARSET=utf8mb3 COMMENT='询价单物料交期明细地点';


--
-- Table structure for table `mat_price_inquiry_material_delivery_addr_copy1`
--

DROP TABLE IF EXISTS `mat_price_inquiry_material_delivery_addr_copy1`;


CREATE TABLE `mat_price_inquiry_material_delivery_addr_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `mat_price_inquiry_material_delivery_seq` int DEFAULT NULL COMMENT '物料报价明细seq',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '询价单seq',
  `addr` varchar(255) DEFAULT NULL COMMENT '地址',
  `detailed_addr` varchar(255) DEFAULT NULL COMMENT '详细地址',
  `logistics_price` decimal(10,2) DEFAULT NULL COMMENT '物流单价',
  `total_price` decimal(10,2) DEFAULT NULL COMMENT '物料总价',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=216 DEFAULT CHARSET=utf8mb3 COMMENT='询价单物料交期明细地点';


--
-- Table structure for table `mat_price_inquiry_material_delivery_addr_tmp`
--

DROP TABLE IF EXISTS `mat_price_inquiry_material_delivery_addr_tmp`;


CREATE TABLE `mat_price_inquiry_material_delivery_addr_tmp` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键',
  `mat_price_inquiry_material_delivery_seq` int DEFAULT NULL COMMENT '物料报价明细seq',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '询价单seq',
  `addr` varchar(255) DEFAULT NULL COMMENT '地址',
  `detailed_addr` varchar(255) DEFAULT NULL COMMENT '详细地址',
  `logistics_price` decimal(10,2) DEFAULT NULL COMMENT '物流单价',
  `total_price` decimal(10,2) DEFAULT NULL COMMENT '物料总价'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mat_price_inquiry_material_delivery_addr_tmp_copy1`
--

DROP TABLE IF EXISTS `mat_price_inquiry_material_delivery_addr_tmp_copy1`;


CREATE TABLE `mat_price_inquiry_material_delivery_addr_tmp_copy1` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键',
  `mat_price_inquiry_material_delivery_seq` int DEFAULT NULL COMMENT '物料报价明细seq',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '询价单seq',
  `addr` varchar(255) DEFAULT NULL COMMENT '地址',
  `detailed_addr` varchar(255) DEFAULT NULL COMMENT '详细地址',
  `logistics_price` decimal(10,2) DEFAULT NULL COMMENT '物流单价',
  `total_price` decimal(10,2) DEFAULT NULL COMMENT '物料总价'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mat_price_inquiry_material_delivery_copy1`
--

DROP TABLE IF EXISTS `mat_price_inquiry_material_delivery_copy1`;


CREATE TABLE `mat_price_inquiry_material_delivery_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键seq',
  `mat_price_inquiry_info_seq` int NOT NULL COMMENT '询价明细seq',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价单号',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '供应商编码',
  `supplier_name` varchar(100) DEFAULT NULL COMMENT '供应商名称',
  `supplier_add_name` varchar(50) DEFAULT NULL COMMENT '供应商简称',
  `purchase_unit_id` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '采购单位',
  `min_quantity` int DEFAULT NULL COMMENT '最小采购量',
  `min_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最小采购量单价',
  `max_quantity` int DEFAULT NULL COMMENT '最大采购量',
  `max_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最大采购量单价',
  `price_num` int DEFAULT NULL COMMENT '报价数量',
  `unit_id` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `interval_begin` int DEFAULT NULL COMMENT '区间起',
  `interval_end` int DEFAULT NULL COMMENT '区间止',
  `no_price` decimal(10,2) DEFAULT NULL COMMENT '单价(不含税)',
  `tax_rate` varchar(100) DEFAULT NULL COMMENT '税率',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价(含税)',
  `row_index` int DEFAULT NULL COMMENT '行标',
  `confirm_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '确认报价',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `created_by` varchar(80) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(80) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(80) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=utf8mb3 COMMENT='物料报价明细';


--
-- Table structure for table `mat_price_inquiry_material_delivery_tmp`
--

DROP TABLE IF EXISTS `mat_price_inquiry_material_delivery_tmp`;


CREATE TABLE `mat_price_inquiry_material_delivery_tmp` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键seq',
  `mat_price_inquiry_info_seq` int NOT NULL COMMENT '询价明细seq',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价单号',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '供应商编码',
  `supplier_name` varchar(100) DEFAULT NULL COMMENT '供应商名称',
  `supplier_add_name` varchar(50) DEFAULT NULL COMMENT '供应商简称',
  `purchase_unit_id` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '采购单位',
  `min_quantity` int DEFAULT NULL COMMENT '最小采购量',
  `min_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最小采购量单价',
  `max_quantity` int DEFAULT NULL COMMENT '最大采购量',
  `max_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最大采购量单价',
  `price_num` int DEFAULT NULL COMMENT '报价数量',
  `unit_id` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `interval_begin` int DEFAULT NULL COMMENT '区间起',
  `interval_end` int DEFAULT NULL COMMENT '区间止',
  `no_price` decimal(10,2) DEFAULT NULL COMMENT '单价(不含税)',
  `tax_rate` varchar(100) DEFAULT NULL COMMENT '税率',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价(含税)',
  `row_index` int DEFAULT NULL COMMENT '行标',
  `confirm_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '确认报价'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mat_price_inquiry_material_delivery_tmp_copy1`
--

DROP TABLE IF EXISTS `mat_price_inquiry_material_delivery_tmp_copy1`;


CREATE TABLE `mat_price_inquiry_material_delivery_tmp_copy1` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键seq',
  `mat_price_inquiry_info_seq` int NOT NULL COMMENT '询价明细seq',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价单号',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '供应商编码',
  `supplier_name` varchar(100) DEFAULT NULL COMMENT '供应商名称',
  `supplier_add_name` varchar(50) DEFAULT NULL COMMENT '供应商简称',
  `purchase_unit_id` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '采购单位',
  `min_quantity` int DEFAULT NULL COMMENT '最小采购量',
  `min_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最小采购量单价',
  `max_quantity` int DEFAULT NULL COMMENT '最大采购量',
  `max_quantity_price` decimal(10,2) DEFAULT NULL COMMENT '最大采购量单价',
  `price_num` int DEFAULT NULL COMMENT '报价数量',
  `unit_id` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `interval_begin` int DEFAULT NULL COMMENT '区间起',
  `interval_end` int DEFAULT NULL COMMENT '区间止',
  `no_price` decimal(10,2) DEFAULT NULL COMMENT '单价(不含税)',
  `tax_rate` varchar(100) DEFAULT NULL COMMENT '税率',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价(含税)',
  `row_index` int DEFAULT NULL COMMENT '行标',
  `confirm_quotation` int(1) unsigned zerofill DEFAULT '0' COMMENT '确认报价'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mat_price_inquiry_material_info`
--

DROP TABLE IF EXISTS `mat_price_inquiry_material_info`;


CREATE TABLE `mat_price_inquiry_material_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '物料询价单seq',
  `mat_customer_material_seq` int DEFAULT NULL COMMENT '客户物料关系表seq',
  `mat_material_supplier_seq` int DEFAULT NULL COMMENT '物料供应商关系表seq',
  `sku` text COMMENT 'sku',
  `quarter_code` varchar(50) DEFAULT NULL COMMENT '季节编码',
  `quarter_name` varchar(50) DEFAULT NULL COMMENT '季节名称',
  `customer_seq` int DEFAULT NULL COMMENT '客户seq',
  `material_name` text COMMENT '物料简码名称',
  `customer_name` varchar(200) DEFAULT NULL COMMENT '客户名称',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_name` varchar(200) DEFAULT NULL COMMENT '供应商名称',
  `supplier_code` varchar(100) DEFAULT NULL COMMENT '供应商编码',
  `material_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `category_code` varchar(100) DEFAULT NULL COMMENT '物料简码',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `color_code` varchar(100) DEFAULT NULL COMMENT '物料颜色',
  `color_name` varchar(100) DEFAULT NULL COMMENT '物料颜色名称',
  `unit_seq` int DEFAULT NULL COMMENT '单位seq',
  `unit_name` varchar(50) DEFAULT NULL COMMENT '单位名称',
  `class_seq` int DEFAULT NULL COMMENT '物料类别id',
  `class_name` varchar(50) DEFAULT NULL COMMENT '物料类别名称',
  `inquiry_material_status` char(1) DEFAULT '0' COMMENT '询价单物料是否报价:0-否,1-是',
  `created_by` varchar(80) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(80) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(80) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `confirm_quotation` int DEFAULT '0' COMMENT '是否确认报价',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `mat_price_inquiry_seq` (`mat_price_inquiry_seq`) USING BTREE,
  KEY `customer_material_seq` (`mat_customer_material_seq`) USING BTREE,
  KEY `mat_material_supplier_seq` (`mat_material_supplier_seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4401 DEFAULT CHARSET=utf8mb3 COMMENT='询价物料明细';


--
-- Table structure for table `mat_price_inquiry_supplier`
--

DROP TABLE IF EXISTS `mat_price_inquiry_supplier`;


CREATE TABLE `mat_price_inquiry_supplier` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `mat_price_inquiry_seq` int DEFAULT NULL COMMENT '物料询价单seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_name` varchar(255) DEFAULT NULL COMMENT '供应商Name',
  `supplier_code` varchar(255) DEFAULT NULL COMMENT '供应商code',
  `quote_status` int DEFAULT '2' COMMENT '报价状态  2未报价 1报价提交 0报价暂存 3报价驳回 4报价确认',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=249 DEFAULT CHARSET=utf8mb3 COMMENT='询价供应商';


--
-- Table structure for table `mat_price_inquiry_tmp`
--

DROP TABLE IF EXISTS `mat_price_inquiry_tmp`;


CREATE TABLE `mat_price_inquiry_tmp` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键',
  `code` varchar(20) DEFAULT NULL COMMENT '询价单号',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `inquiry_person_num` varchar(50) DEFAULT NULL COMMENT '询价人账号',
  `inquiry_person` varchar(50) DEFAULT NULL COMMENT '询价人',
  `inquiry_dept_id` int DEFAULT NULL COMMENT '询价部门id',
  `inquiry_dept_name` varchar(50) DEFAULT NULL COMMENT '询价部门名称',
  `inquiry_status` varchar(5) DEFAULT NULL COMMENT '询价单状态：51-草稿,10-提交,20-待审批,21-审批中,22-转办,23-委派,24-抄送,25-退回,26-驳回,1-撤回,50-完成，52 询价中，53 询价完成',
  `quote_status` varchar(5) DEFAULT NULL COMMENT '报价单状态：0-草稿,1-提交,2-待审批3-审批中,4-转办,5-委派,6-抄送,7-退回,8-驳回,9-撤回,10-完成,11-供应商报价中,12-供应商完成',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_def_supplier` char(1) DEFAULT NULL COMMENT '是否带入默认供应商:0-否,1-是',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除:0-否,1-是',
  `enable` char(1) DEFAULT '1' COMMENT '是否有效:0-否,1-是',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `status` int DEFAULT NULL COMMENT '状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mat_price_inquiry_tmp_copy1`
--

DROP TABLE IF EXISTS `mat_price_inquiry_tmp_copy1`;


CREATE TABLE `mat_price_inquiry_tmp_copy1` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键',
  `code` varchar(20) DEFAULT NULL COMMENT '询价单号',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `inquiry_person_num` varchar(50) DEFAULT NULL COMMENT '询价人账号',
  `inquiry_person` varchar(50) DEFAULT NULL COMMENT '询价人',
  `inquiry_dept_id` int DEFAULT NULL COMMENT '询价部门id',
  `inquiry_dept_name` varchar(50) DEFAULT NULL COMMENT '询价部门名称',
  `inquiry_status` varchar(5) DEFAULT NULL COMMENT '询价单状态：51-草稿,10-提交,20-待审批,21-审批中,22-转办,23-委派,24-抄送,25-退回,26-驳回,1-撤回,50-完成，52 询价中，53 询价完成',
  `quote_status` varchar(5) DEFAULT NULL COMMENT '报价单状态：0-草稿,1-提交,2-待审批3-审批中,4-转办,5-委派,6-抄送,7-退回,8-驳回,9-撤回,10-完成,11-供应商报价中,12-供应商完成',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_def_supplier` char(1) DEFAULT NULL COMMENT '是否带入默认供应商:0-否,1-是',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除:0-否,1-是',
  `enable` char(1) DEFAULT '1' COMMENT '是否有效:0-否,1-是',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `status` int DEFAULT NULL COMMENT '状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `material_batch`
--

DROP TABLE IF EXISTS `material_batch`;


CREATE TABLE `material_batch` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `type` int DEFAULT NULL COMMENT '单据分类',
  `receipt` varchar(255) DEFAULT NULL COMMENT '收货单号',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商编号',
  `receipt_date` datetime DEFAULT NULL COMMENT '收货日期',
  `send_date` datetime DEFAULT NULL COMMENT '送货日期',
  `send_code` varchar(255) DEFAULT NULL COMMENT '送货单号',
  `create_by` varchar(22) DEFAULT NULL COMMENT '建档人',
  `create_date` datetime DEFAULT NULL COMMENT '建档日期',
  `backse_by` varchar(22) DEFAULT NULL COMMENT '锁档人',
  `backse_date` datetime DEFAULT NULL COMMENT '锁档日期',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `is_material` int DEFAULT NULL COMMENT '是否收料，1-收料，2-退料',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料库存批次';


--
-- Table structure for table `material_batch_info`
--

DROP TABLE IF EXISTS `material_batch_info`;


CREATE TABLE `material_batch_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `batch_no` int NOT NULL COMMENT '外键',
  `procurement_seq` int DEFAULT NULL COMMENT '采购计划子表主键',
  `no` varchar(255) DEFAULT NULL COMMENT '单据号',
  `bath_no` varchar(255) DEFAULT NULL COMMENT '批次号',
  `storage` int DEFAULT NULL COMMENT '数量',
  `surplus` int DEFAULT NULL COMMENT '剩余数量',
  `unit` varchar(4) DEFAULT NULL COMMENT '单位（包/双/件）',
  `mater_stock` int DEFAULT NULL COMMENT '库存标识(0:入库 1：出库)',
  `resource` varchar(255) DEFAULT NULL COMMENT '来源',
  `price` double(2,0) DEFAULT NULL COMMENT '单价(不含税)',
  `sum_price` varchar(12) DEFAULT NULL COMMENT '金额（不含税）',
  `tax` double(3,0) DEFAULT NULL COMMENT '税率',
  `resource_no` varchar(255) DEFAULT NULL COMMENT '原单据号(仅出库有)',
  `accounting` date DEFAULT NULL COMMENT '会计期待',
  `edit_time` date DEFAULT NULL COMMENT '变更时间',
  `is_delete` int DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `material_batch_foregin_key` (`batch_no`) USING BTREE,
  CONSTRAINT `material_batch_foregin_key` FOREIGN KEY (`batch_no`) REFERENCES `material_batch` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料库存明细';


--
-- Table structure for table `material_inventory`
--

DROP TABLE IF EXISTS `material_inventory`;


CREATE TABLE `material_inventory` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(22) DEFAULT NULL COMMENT '单据号',
  `bath_no` varchar(22) DEFAULT NULL COMMENT '批次号',
  `mater_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `mater_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `storage` int DEFAULT NULL COMMENT '入库数量',
  `out_storage` int DEFAULT NULL COMMENT '出库数量',
  `unit` varchar(2) DEFAULT NULL COMMENT '单位',
  `is_size` int DEFAULT '0' COMMENT '是否码号管理',
  `resource` varchar(255) DEFAULT NULL COMMENT '来源',
  `price` double(10,2) DEFAULT NULL COMMENT '单价',
  `sum_price` double(10,2) DEFAULT NULL COMMENT '金额',
  `tax` double(255,0) DEFAULT NULL COMMENT '税率',
  `supplier` varchar(255) DEFAULT NULL COMMENT '供应商编码',
  `edit_time` datetime DEFAULT NULL COMMENT '变更时间',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料出入库表';


--
-- Table structure for table `material_inventory_info`
--

DROP TABLE IF EXISTS `material_inventory_info`;


CREATE TABLE `material_inventory_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `batch_no` int NOT NULL COMMENT '外键',
  `mater_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `size` varchar(255) DEFAULT NULL COMMENT '码号',
  `storage` int DEFAULT NULL COMMENT '数量',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `material_inventory_foregin_key` (`batch_no`) USING BTREE,
  CONSTRAINT `material_inventory_foregin_key` FOREIGN KEY (`batch_no`) REFERENCES `material_inventory` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料出入库表明细';


--
-- Table structure for table `material_receive`
--

DROP TABLE IF EXISTS `material_receive`;


CREATE TABLE `material_receive` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `vender_no` varchar(255) DEFAULT NULL COMMENT '厂别代号',
  `type` char(6) DEFAULT NULL COMMENT '单据类型',
  `no` varchar(20) DEFAULT NULL COMMENT '单号',
  `apply_company_seq` int DEFAULT NULL COMMENT '申领单位',
  `apply_date` datetime DEFAULT NULL COMMENT '申领时间',
  `filing_by` varchar(64) DEFAULT NULL COMMENT '建档人',
  `filing_date` datetime DEFAULT NULL COMMENT '建档日期',
  `backset_by` varchar(64) DEFAULT NULL COMMENT '锁档人',
  `backset_date` datetime DEFAULT NULL COMMENT '锁档日期',
  `is_backset` char(1) DEFAULT NULL COMMENT '是否锁档：N-否，Y-是',
  `memo` varchar(64) DEFAULT NULL COMMENT '备注',
  `customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `is_delete` int DEFAULT '0' COMMENT '0:未删除 1：删除',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料申领单';


--
-- Table structure for table `material_receive_info`
--

DROP TABLE IF EXISTS `material_receive_info`;


CREATE TABLE `material_receive_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sample_order_seq` int DEFAULT NULL COMMENT '样品单号',
  `material_receive_seq` int DEFAULT NULL COMMENT '材料申领表seq',
  `amount` varchar(255) DEFAULT NULL COMMENT '申领数量',
  `actual_amount` varchar(255) DEFAULT NULL COMMENT '实际数量',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  `sum` decimal(10,2) DEFAULT NULL COMMENT '金额',
  `is_delete` int DEFAULT '0' COMMENT '0:未删除 1：删除',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `material_receive_seq` (`material_receive_seq`) USING BTREE,
  KEY `sample_order_seq` (`sample_order_seq`) USING BTREE,
  CONSTRAINT `material_receive_info_ibfk_1` FOREIGN KEY (`material_receive_seq`) REFERENCES `material_receive` (`seq`),
  CONSTRAINT `material_receive_info_ibfk_2` FOREIGN KEY (`sample_order_seq`) REFERENCES `sample_order` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料申领详情';


--
-- Table structure for table `material_replenishment`
--

DROP TABLE IF EXISTS `material_replenishment`;


CREATE TABLE `material_replenishment` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(20) DEFAULT NULL COMMENT '补料单号',
  `product_order_code` varchar(20) DEFAULT NULL COMMENT '生产订单号',
  `fill_date` date DEFAULT NULL COMMENT '补料日期',
  `sku_name` varchar(50) DEFAULT NULL COMMENT 'sku名称',
  `req_material_factory_id` int DEFAULT NULL COMMENT '请料工厂id',
  `req_material_factory_name` varchar(100) DEFAULT NULL COMMENT '请料工厂名称',
  `status` varchar(5) DEFAULT NULL COMMENT '状态：51-草稿,10-提交,20-待审批,21-审批中,22-转办,23-委派,24-抄送,25-退回,26-驳回,27-作废,1-撤回,50-完成',
  `factory_floor_id` int DEFAULT NULL COMMENT '工厂车间id',
  `factory_floor` varchar(20) DEFAULT NULL COMMENT '工厂车间',
  `aritcle` varchar(20) DEFAULT NULL COMMENT '形体',
  `customer_article_name` varchar(100) DEFAULT NULL COMMENT '客户型体',
  `shop_team` varchar(20) DEFAULT NULL COMMENT '车间小组',
  `receiver_dept` varchar(50) DEFAULT NULL COMMENT '领取部门',
  `receiver_person` varchar(20) DEFAULT NULL COMMENT '领取人',
  `receiver_type` varchar(20) DEFAULT NULL COMMENT '领取类型',
  `even_num` varchar(100) DEFAULT NULL COMMENT '领料双数',
  `duty_ownership` varchar(100) DEFAULT NULL COMMENT '责任归属',
  `reason` varchar(255) DEFAULT NULL COMMENT '补料原因',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除',
  `enable` char(1) DEFAULT '1' COMMENT '是否有效',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `size_map` varchar(255) DEFAULT NULL COMMENT '前端参数',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `manual_prod_code` varchar(255) DEFAULT NULL COMMENT '手工排产单号',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3 COMMENT='材料补料单';


--
-- Table structure for table `material_replenishment_matching`
--

DROP TABLE IF EXISTS `material_replenishment_matching`;


CREATE TABLE `material_replenishment_matching` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `material_replenishment_seq` int DEFAULT NULL COMMENT '材料补料seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单-正式订单型体部位-物料信息seq',
  `order_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '订单合同号',
  `sku` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku',
  `customer_article_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '客户型体名称',
  `customer_article_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '客户型体编号',
  `customer` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '客户',
  `instruct` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '指令',
  `unit_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '单位',
  `category_material_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_estonian_ci DEFAULT NULL COMMENT '物料简码',
  `material_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '物料编码',
  `material_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '物料名称',
  `supplier` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '供方',
  `material_add_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '物料简码',
  `colour_id` int DEFAULT NULL COMMENT '颜色id',
  `colour_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '颜色名称',
  `part_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '部位编码',
  `part_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '部位名称',
  `is_matching` int DEFAULT NULL COMMENT '是否配码:0-否,1-是',
  `average_usage` decimal(18,4) DEFAULT NULL COMMENT '平均用量',
  `plan_usage` decimal(18,4) DEFAULT NULL COMMENT '预估用量',
  `actual_usage` decimal(18,4) DEFAULT NULL COMMENT '实际用量',
  `manual_prod_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '手工排产单号',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_estonian_ci COMMENT='材料补料配码';


--
-- Table structure for table `material_replenishment_matching_size`
--

DROP TABLE IF EXISTS `material_replenishment_matching_size`;


CREATE TABLE `material_replenishment_matching_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `material_replenishment_matching_seq` int DEFAULT NULL COMMENT '配码seq',
  `size` varchar(20) DEFAULT NULL COMMENT '尺码',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb3 COMMENT='材料补料配码size';


--
-- Table structure for table `material_replenishment_matching_size_value`
--

DROP TABLE IF EXISTS `material_replenishment_matching_size_value`;


CREATE TABLE `material_replenishment_matching_size_value` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `material_replenishment_matching_size_seq` int DEFAULT NULL COMMENT '材料补料配码size',
  `left_size_num` varchar(100) DEFAULT NULL COMMENT '左脚数量',
  `right_size_num` varchar(100) DEFAULT NULL COMMENT '右脚数量',
  `average_usage` varchar(100) DEFAULT NULL COMMENT '评均用量',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb3 COMMENT='配码size数量表';


--
-- Table structure for table `material_replenishment_matching_value`
--

DROP TABLE IF EXISTS `material_replenishment_matching_value`;


CREATE TABLE `material_replenishment_matching_value` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `material_replenishment_matching_seq` int NOT NULL COMMENT '材料补料配码seq',
  `num_key` varchar(100) DEFAULT NULL COMMENT '码号',
  `num_value` varchar(100) DEFAULT NULL COMMENT '数量',
  `average_usage` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2934 DEFAULT CHARSET=utf8mb3 COMMENT='不配码材料数量';


--
-- Table structure for table `material_replenishment_orders`
--

DROP TABLE IF EXISTS `material_replenishment_orders`;


CREATE TABLE `material_replenishment_orders` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `material_replenishment_seq` int DEFAULT NULL COMMENT '材料补料seq',
  `order_code` varchar(50) DEFAULT NULL COMMENT '正式订单号',
  `order_row` varchar(50) DEFAULT NULL COMMENT '正式订单行标识',
  `is_check` char(1) DEFAULT NULL COMMENT '是否勾选:0-否,1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3 COMMENT='材料补料正式订单关联表';


--
-- Table structure for table `material_return_materials`
--

DROP TABLE IF EXISTS `material_return_materials`;


CREATE TABLE `material_return_materials` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `return_materials_type` varchar(10) DEFAULT NULL COMMENT '退料类型 1加工材料退料2 原材料退料',
  `return_materials_number` varchar(50) DEFAULT NULL COMMENT '退料单号',
  `return_materials_at` datetime DEFAULT NULL COMMENT '退料日期',
  `return_materials_address` varchar(200) DEFAULT NULL COMMENT '退料地址',
  `outbound_at` datetime DEFAULT NULL COMMENT '出库日期',
  `operator` varchar(50) DEFAULT NULL COMMENT '经办人',
  `factory_id` int DEFAULT NULL,
  `factory` varchar(255) DEFAULT NULL COMMENT '工厂',
  `warehouse` varchar(50) DEFAULT NULL COMMENT '仓库',
  `status` varchar(50) DEFAULT NULL COMMENT '状态(0暂存，1提交)',
  `printing_frequency` int DEFAULT '0' COMMENT '打印次数',
  `submit_at` datetime DEFAULT NULL COMMENT '提交日期',
  `workshop_team` varchar(50) DEFAULT NULL COMMENT '车间小组',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `supplier` varchar(100) DEFAULT NULL COMMENT '供应商',
  `supplier_id` int DEFAULT NULL COMMENT '供应商ID',
  `contacts` varchar(100) DEFAULT NULL COMMENT '联系人',
  `contacts_phone` varchar(50) DEFAULT NULL COMMENT '联系人电话',
  `undertaking_party` varchar(50) DEFAULT NULL COMMENT '承担方',
  `undertaking_explain` varchar(50) DEFAULT NULL COMMENT '承担说明',
  `is_effective` int DEFAULT '0' COMMENT '是否可用(0-否,1-是)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_receive_again` char(1) DEFAULT '1' COMMENT '是否重收',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `inspection_order_number` varchar(255) DEFAULT NULL COMMENT '品检单号',
  `todo_seqs` text COMMENT 'todo列表seq',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `warehouse_entry_date` datetime DEFAULT NULL COMMENT '打印日期',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料退料';


--
-- Table structure for table `material_return_materials_info`
--

DROP TABLE IF EXISTS `material_return_materials_info`;


CREATE TABLE `material_return_materials_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `material_return_materials_seq` int DEFAULT NULL COMMENT '材料退料表seq',
  `formal_order_code` varchar(100) DEFAULT NULL COMMENT '正式订单号',
  `od_prod_order_code` text COMMENT '生产订单号',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `customer_article_code` varchar(100) DEFAULT NULL COMMENT '客户型体号',
  `batch_number` varchar(255) DEFAULT NULL COMMENT '批次号',
  `storage_location` varchar(50) DEFAULT NULL COMMENT '储位',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour_name` varchar(500) DEFAULT NULL,
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `position_seq` int DEFAULT NULL,
  `position_name` varchar(100) DEFAULT NULL COMMENT '部位',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '颜色',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料基本单位',
  `mx_material_category_purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '物料采购单位',
  `material_category_code` varchar(100) DEFAULT NULL COMMENT '物料简码',
  `material_manager` varchar(100) DEFAULT NULL COMMENT '材料负责人',
  `order_doc_aritcle_seq` varchar(100) DEFAULT NULL COMMENT '正式订单行标识',
  `mx_material_category_purchase_convert_rate` varchar(100) DEFAULT NULL COMMENT '转换比率',
  `customer_delivery_time` datetime DEFAULT NULL COMMENT '客户交期',
  `art_color_name` varchar(100) DEFAULT NULL COMMENT '型体颜色',
  `cumulative_return_materials_number` decimal(11,2) DEFAULT NULL COMMENT '累计退料数量',
  `thistime_return_materials_number` decimal(11,2) DEFAULT NULL,
  `return_materials_quantity` decimal(11,2) DEFAULT NULL COMMENT '本次退料数量',
  `lnventory_quantity` decimal(11,2) DEFAULT NULL COMMENT '库存量',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `total_inventory` decimal(11,2) DEFAULT NULL COMMENT '总库存量',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `thistime_return_materials_number1` int DEFAULT NULL COMMENT '本次退料数量',
  `warehouse_code` varchar(100) DEFAULT NULL COMMENT '退料接收仓库',
  `warehouse_name` varchar(255) DEFAULT NULL COMMENT '退料接收仓库',
  `location_code` varchar(100) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(255) DEFAULT NULL COMMENT '储位名称',
  `row_no` varchar(50) DEFAULT NULL,
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '监控表seq',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `source_seq` int DEFAULT NULL COMMENT '品检单seq',
  `source_info_seq` int DEFAULT NULL COMMENT '品检单明细seq',
  `inspection_order_number` varchar(255) DEFAULT NULL COMMENT '品检单号',
  `temp_order_number` varchar(255) DEFAULT NULL COMMENT '暂收单号',
  `purchase_order_number` varchar(255) DEFAULT NULL COMMENT '采购单号',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `manual_prod_code` varchar(255) DEFAULT NULL COMMENT '指令号',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `size` varchar(255) DEFAULT NULL,
  `test_by` varchar(255) DEFAULT NULL COMMENT '品检员',
  `test_department_name` varchar(255) DEFAULT NULL COMMENT '品检部门',
  `test_department_seq` int DEFAULT NULL COMMENT '品检部门序号',
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  `test_date` datetime DEFAULT NULL COMMENT '品检日期',
  `sampling_quantity` decimal(11,2) DEFAULT NULL COMMENT '抽检数量',
  `sampling_rate` decimal(5,2) DEFAULT NULL COMMENT '抽检比率',
  `inspection_quantity` decimal(11,2) DEFAULT NULL COMMENT '收料数量',
  `delivery_note_number` varchar(255) DEFAULT NULL COMMENT '送货单号',
  `unit_price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料退料明细';


--
-- Table structure for table `material_return_materials_todo`
--

DROP TABLE IF EXISTS `material_return_materials_todo`;


CREATE TABLE `material_return_materials_todo` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `source_seq` int DEFAULT NULL COMMENT '品检单seq',
  `source_info_seq` int DEFAULT NULL COMMENT '品检单明细seq',
  `formal_order_code` varchar(100) DEFAULT NULL COMMENT '正式订单号',
  `od_prod_order_code` text COMMENT '生产订单号',
  `sku` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_croatian_ci DEFAULT NULL COMMENT 'sku',
  `row_no` varchar(255) DEFAULT NULL COMMENT '行号',
  `purchase_order_number` varchar(255) DEFAULT NULL COMMENT '采购单号',
  `temp_order_number` varchar(255) DEFAULT NULL COMMENT '暂收单',
  `inspection_order_number` varchar(255) DEFAULT NULL COMMENT '品检单号',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `customer_article_code` varchar(100) DEFAULT NULL COMMENT '客户型体号',
  `batch_number` varchar(255) DEFAULT NULL COMMENT '批次号',
  `delivery_note_number` varchar(255) DEFAULT NULL COMMENT '送货单号',
  `storage_location` varchar(50) DEFAULT NULL COMMENT '储位',
  `material_info_seq` int DEFAULT NULL,
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_category_code` varchar(100) DEFAULT NULL COMMENT '物料简码',
  `material_category_seq` int DEFAULT NULL,
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '颜色',
  `material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `position_seq` int DEFAULT NULL,
  `position_name` varchar(100) DEFAULT NULL COMMENT '部位',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料基本单位',
  `mx_material_category_purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '物料采购单位',
  `material_manager` varchar(100) DEFAULT NULL COMMENT '材料负责人',
  `mx_material_category_purchase_convert_rate` varchar(100) DEFAULT NULL COMMENT '转换比率',
  `customer_delivery_time` datetime DEFAULT NULL COMMENT '客户交期',
  `art_color_name` varchar(100) DEFAULT NULL COMMENT '型体颜色',
  `cumulative_return_materials_number` decimal(11,2) DEFAULT NULL COMMENT '累计退料数量',
  `thistime_return_materials_number` decimal(11,2) DEFAULT NULL COMMENT '本次退料数量',
  `return_materials_quantity` decimal(11,2) DEFAULT NULL COMMENT '本次退料数量',
  `lnventory_quantity` decimal(11,2) DEFAULT NULL COMMENT '库存量',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `total_inventory` decimal(11,2) DEFAULT NULL COMMENT '总库存量',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `warehouse_code` varchar(100) DEFAULT NULL COMMENT '退料接收仓库',
  `warehouse_name` varchar(255) DEFAULT NULL COMMENT '退料接收仓库',
  `location_code` varchar(100) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(255) DEFAULT NULL COMMENT '储位名称',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商',
  `provider_seq` int DEFAULT NULL COMMENT '供应商',
  `factory_id` int DEFAULT NULL COMMENT '退料工厂',
  `factory` varchar(255) DEFAULT NULL COMMENT '退料工厂',
  `size` varchar(255) DEFAULT NULL,
  `manual_prod_code` text,
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '物料监控表seq',
  `test_by` varchar(255) DEFAULT NULL COMMENT '品检员',
  `test_department_name` varchar(255) DEFAULT NULL COMMENT '品检部门',
  `test_department_seq` int DEFAULT NULL COMMENT '品检部门序号',
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  `test_date` datetime DEFAULT NULL COMMENT '品检日期',
  `sampling_quantity` decimal(11,2) DEFAULT NULL COMMENT '抽检数量',
  `sampling_rate` decimal(5,2) DEFAULT NULL COMMENT '抽检比率',
  `inspection_quantity` decimal(11,2) DEFAULT NULL COMMENT '收料数量',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料退料明细';


--
-- Table structure for table `material_sample`
--

DROP TABLE IF EXISTS `material_sample`;


CREATE TABLE `material_sample` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `material_seq` int DEFAULT NULL COMMENT '采购计划详情表seq',
  `sample_seq` int DEFAULT NULL COMMENT '样品表seq',
  `matter_seq` int DEFAULT NULL COMMENT '物料表seq',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='采购计划\\样品表\\物料关联表';


--
-- Table structure for table `material_warehouse_out`
--

DROP TABLE IF EXISTS `material_warehouse_out`;


CREATE TABLE `material_warehouse_out` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(20) NOT NULL COMMENT '转仓出库单号',
  `company_out_id` int NOT NULL COMMENT '转出工厂',
  `company_out_name` varchar(100) DEFAULT NULL COMMENT '转出工厂名称',
  `warehouse_out_id` int NOT NULL COMMENT '转出仓库id',
  `warehouse_out_code` varchar(100) DEFAULT NULL COMMENT '转出库编码',
  `warehouse_out_name` varchar(50) NOT NULL COMMENT '转出仓库',
  `company_in_id` int NOT NULL COMMENT '转入工厂(公司)id',
  `company_in_name` varchar(100) NOT NULL COMMENT '转入工厂名称',
  `warehouse_in_id` int NOT NULL COMMENT '转入仓库id',
  `warehouse_in_name` varchar(50) DEFAULT NULL COMMENT '转入仓库名称',
  `warehouse_in_code` varchar(100) DEFAULT NULL COMMENT '转进仓库',
  `status` int NOT NULL COMMENT '单据状态',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `print_count` int NOT NULL DEFAULT '1' COMMENT '打印次数',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除  0未删除 1删除',
  `created_username` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_by` varchar(100) DEFAULT NULL COMMENT '创建昵称',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb3 COMMENT='转仓出库主表';


--
-- Table structure for table `material_warehouse_out_extra`
--

DROP TABLE IF EXISTS `material_warehouse_out_extra`;


CREATE TABLE `material_warehouse_out_extra` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `mat_warehouse_out_seq` int NOT NULL COMMENT '材料转仓出库主键',
  `prod_order_code` varchar(30) NOT NULL COMMENT '生产订单号',
  `manual_prod_code` text COMMENT '指令号',
  `company_out_seq` int NOT NULL COMMENT '转出工厂seq',
  `warehouse_out_code` varchar(100) NOT NULL COMMENT '转出仓库code',
  `sku` varchar(100) DEFAULT NULL COMMENT '型体sku',
  `material_info_code` varchar(100) NOT NULL COMMENT '物料编码',
  `material_name` text NOT NULL COMMENT '物料名称',
  PRIMARY KEY (`seq`),
  KEY `material_warehouse_out_extra_material_warehouse_out_seq_fk` (`mat_warehouse_out_seq`),
  KEY `more_index` (`prod_order_code`,`sku`,`material_info_code`,`warehouse_out_code`,`company_out_seq`,`mat_warehouse_out_seq`),
  FULLTEXT KEY `material_warehouse_out_extra_material_name_index` (`material_name`),
  CONSTRAINT `material_warehouse_out_extra_material_warehouse_out_seq_fk` FOREIGN KEY (`mat_warehouse_out_seq`) REFERENCES `material_warehouse_out` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=5774 DEFAULT CHARSET=utf8mb3 COMMENT='转仓出库主表额外信息表(查询用)';


--
-- Table structure for table `material_warehouse_out_info`
--

DROP TABLE IF EXISTS `material_warehouse_out_info`;


CREATE TABLE `material_warehouse_out_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `mat_warehouse_out_seq` int NOT NULL COMMENT '材料转仓出库主键',
  `store_id` varchar(40) NOT NULL COMMENT '库存报表ID',
  `customer_seq` int NOT NULL COMMENT '客户Seq',
  `customer_name` varchar(100) NOT NULL COMMENT '客户名称',
  `prod_order_seq` int DEFAULT NULL COMMENT '生成订单seq',
  `row_no` varchar(200) DEFAULT NULL COMMENT '行标识',
  `manual_prod_code` text COMMENT '手工排产单号',
  `prod_order_code` varchar(30) NOT NULL COMMENT '指令单号',
  `provider_seq` int NOT NULL COMMENT '供应商seq',
  `provider_name` varchar(100) NOT NULL COMMENT '供应商名称',
  `position_name` varchar(200) DEFAULT NULL COMMENT '部位名称',
  `position_code` varchar(100) DEFAULT NULL COMMENT '部位编码',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_info_seq` int NOT NULL COMMENT '物料编码主键',
  `material_info_code` varchar(100) NOT NULL COMMENT '物料编码',
  `material_name` text NOT NULL COMMENT '物料名称',
  `art_color_name` varchar(200) DEFAULT NULL COMMENT '型体颜色',
  `customer_article_code` varchar(200) DEFAULT NULL COMMENT '客户形体号',
  `art_code` varchar(200) DEFAULT NULL COMMENT '工厂型体号',
  `color_code` varchar(200) DEFAULT NULL COMMENT '颜色编码',
  `color_name` varchar(100) DEFAULT NULL COMMENT '物料颜色',
  `size_code` varchar(50) DEFAULT NULL COMMENT '物料尺码',
  `size_name` varchar(50) DEFAULT NULL COMMENT '尺码',
  `unit_seq` int NOT NULL COMMENT '物料单位seq',
  `unit_name` varchar(10) DEFAULT NULL COMMENT '物料单位',
  `warehouse_code` varchar(100) NOT NULL COMMENT '转出仓库code',
  `warehouse_name` varchar(100) NOT NULL COMMENT '转出仓库名称',
  `location_code` varchar(100) DEFAULT NULL COMMENT '转出储位编号',
  `location_name` varchar(100) DEFAULT NULL COMMENT '转出储位名称',
  `sku` varchar(200) DEFAULT NULL COMMENT 'sku',
  `store_num` decimal(14,2) NOT NULL COMMENT '库存数量',
  `store_out_num` decimal(14,2) NOT NULL COMMENT '转出库存数量',
  `can_store_out_num` decimal(14,4) NOT NULL DEFAULT '0.0000' COMMENT '可转出剩余数量',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  PRIMARY KEY (`seq`),
  KEY `material_warehouse_out_index` (`mat_warehouse_out_seq`,`can_store_out_num`)
) ENGINE=InnoDB AUTO_INCREMENT=5774 DEFAULT CHARSET=utf8mb3 COMMENT='转仓出库明细表';


--
-- Table structure for table `matter_store`
--

DROP TABLE IF EXISTS `matter_store`;


CREATE TABLE `matter_store` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `matter_seq` int DEFAULT NULL COMMENT '物料seq',
  `store_hose` int DEFAULT NULL COMMENT '仓库seq',
  `strong_seq` varchar(255) DEFAULT NULL COMMENT '储位seq',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;


--
-- Table structure for table `matter_supplier`
--

DROP TABLE IF EXISTS `matter_supplier`;


CREATE TABLE `matter_supplier` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `matter_seq` int NOT NULL,
  `supplier_seq` int DEFAULT NULL,
  `price` double(10,2) DEFAULT NULL COMMENT '单价',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料-供应商关联表';


--
-- Table structure for table `mx_material_attribute`
--

DROP TABLE IF EXISTS `mx_material_attribute`;


CREATE TABLE `mx_material_attribute` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(50) DEFAULT NULL COMMENT '编号',
  `attribute_name` varchar(50) DEFAULT NULL COMMENT '属性名称',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `is_hide` int DEFAULT '0' COMMENT '是否隐藏',
  `enable` int DEFAULT '1' COMMENT '是否可用',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb3 COMMENT='物料属性基础资料';


--
-- Table structure for table `mx_material_attribute_value`
--

DROP TABLE IF EXISTS `mx_material_attribute_value`;


CREATE TABLE `mx_material_attribute_value` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `material_attribute_id` bigint DEFAULT NULL COMMENT '主表ID',
  `attribute_code` varchar(255) DEFAULT NULL COMMENT '属性编号',
  `attribute_value` text COMMENT '属性值',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `deleted_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `created_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `created_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2640 DEFAULT CHARSET=utf8mb3 COMMENT='物料属性基础资料子表';


--
-- Table structure for table `mx_material_category`
--

DROP TABLE IF EXISTS `mx_material_category`;


CREATE TABLE `mx_material_category` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `old_category_code` varchar(100) DEFAULT NULL COMMENT '原物料简码',
  `material_name` text COMMENT '物料名称',
  `old_material_name` varchar(255) DEFAULT NULL COMMENT '原物料名称',
  `type_seq` int DEFAULT NULL COMMENT '物料类型id',
  `type_name` varchar(100) DEFAULT NULL COMMENT '物料类型名称',
  `class_seq` int DEFAULT NULL COMMENT '物料类别id',
  `class_name` varchar(100) DEFAULT NULL COMMENT '物料类别名称',
  `class_path_name` varchar(100) DEFAULT NULL COMMENT '物料类别路径名称',
  `group_seq` int DEFAULT NULL COMMENT '物料分组id',
  `group_name` varchar(100) DEFAULT NULL COMMENT '物料分组名称',
  `unit_seq` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `provider_seq` int DEFAULT NULL COMMENT '默认供应商id',
  `provider_name` varchar(100) DEFAULT NULL COMMENT '默认供应商名称',
  `is_match_size` int DEFAULT '0' COMMENT '是否配码（0-否，1-是）',
  `is_each_expend` int DEFAULT '0' COMMENT '是否码段用量(0-否，1-是)',
  `is_used` int DEFAULT '0' COMMENT '是否使用',
  `enable` int DEFAULT '0' COMMENT '是否停用(0-否，1-是)',
  `is_out_sourcing` int DEFAULT '0' COMMENT '是否外发加工(0-否,1-是)',
  `is_color_constraint` int DEFAULT '0' COMMENT '是否颜色约束',
  `money_type_seq` int DEFAULT NULL COMMENT '币种id',
  `money_type_name` varchar(100) DEFAULT NULL COMMENT '币种名称',
  `purchase_unit_seq` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '采购单位名称',
  `purchase_convert_rate` decimal(18,2) DEFAULT '0.00' COMMENT '采购转换比率',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方id',
  `provider_type_name` varchar(100) DEFAULT NULL COMMENT '供方名称',
  `purchase_hit_rate` decimal(18,2) DEFAULT '0.00' COMMENT '采购打大率',
  `many_purchase_rate` decimal(18,2) DEFAULT '0.00' COMMENT '允许多采比率',
  `many_receive_rate` decimal(18,2) DEFAULT '0.00' COMMENT '允许多收比率',
  `is_exempt_verify` int DEFAULT '0' COMMENT '是否免检(0-否,1-是)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `data_source` varchar(100) DEFAULT NULL COMMENT '数据来源',
  `item_source` varchar(100) DEFAULT NULL COMMENT '单据来源',
  `approve_status` bit(2) DEFAULT NULL COMMENT '审批状态',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `dna_id` int DEFAULT NULL,
  `created_name` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `category_code` (`category_code`)
) ENGINE=InnoDB AUTO_INCREMENT=21138 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料简码';


--
-- Table structure for table `mx_material_category_20250805`
--

DROP TABLE IF EXISTS `mx_material_category_20250805`;


CREATE TABLE `mx_material_category_20250805` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `old_category_code` varchar(100) DEFAULT NULL COMMENT '原物料简码',
  `material_name` text COMMENT '物料名称',
  `old_material_name` varchar(255) DEFAULT NULL COMMENT '原物料名称',
  `type_seq` int DEFAULT NULL COMMENT '物料类型id',
  `type_name` varchar(100) DEFAULT NULL COMMENT '物料类型名称',
  `class_seq` int DEFAULT NULL COMMENT '物料类别id',
  `class_name` varchar(100) DEFAULT NULL COMMENT '物料类别名称',
  `class_path_name` varchar(100) DEFAULT NULL COMMENT '物料类别路径名称',
  `group_seq` int DEFAULT NULL COMMENT '物料分组id',
  `group_name` varchar(100) DEFAULT NULL COMMENT '物料分组名称',
  `unit_seq` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `provider_seq` int DEFAULT NULL COMMENT '默认供应商id',
  `provider_name` varchar(100) DEFAULT NULL COMMENT '默认供应商名称',
  `is_match_size` int DEFAULT '0' COMMENT '是否配码（0-否，1-是）',
  `is_each_expend` int DEFAULT '0' COMMENT '是否码段用量(0-否，1-是)',
  `is_used` int DEFAULT '0' COMMENT '是否使用',
  `enable` int DEFAULT '0' COMMENT '是否停用(0-否，1-是)',
  `is_out_sourcing` int DEFAULT '0' COMMENT '是否外发加工(0-否,1-是)',
  `is_color_constraint` int DEFAULT '0' COMMENT '是否颜色约束',
  `money_type_seq` int DEFAULT NULL COMMENT '币种id',
  `money_type_name` varchar(100) DEFAULT NULL COMMENT '币种名称',
  `purchase_unit_seq` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '采购单位名称',
  `purchase_convert_rate` decimal(18,2) DEFAULT '0.00' COMMENT '采购转换比率',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方id',
  `provider_type_name` varchar(100) DEFAULT NULL COMMENT '供方名称',
  `purchase_hit_rate` decimal(18,2) DEFAULT '0.00' COMMENT '采购打大率',
  `many_purchase_rate` decimal(18,2) DEFAULT '0.00' COMMENT '允许多采比率',
  `many_receive_rate` decimal(18,2) DEFAULT '0.00' COMMENT '允许多收比率',
  `is_exempt_verify` int DEFAULT '0' COMMENT '是否免检(0-否,1-是)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `data_source` varchar(100) DEFAULT NULL COMMENT '数据来源',
  `item_source` varchar(100) DEFAULT NULL COMMENT '单据来源',
  `approve_status` bit(2) DEFAULT NULL COMMENT '审批状态',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `dna_id` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `category_code` (`category_code`)
) ENGINE=InnoDB AUTO_INCREMENT=18462 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料简码';


--
-- Table structure for table `mx_material_category_attribute`
--

DROP TABLE IF EXISTS `mx_material_category_attribute`;


CREATE TABLE `mx_material_category_attribute` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键seq',
  `mx_material_category_seq` int DEFAULT NULL COMMENT '物料简码表seq',
  `attribute_seq` int DEFAULT NULL COMMENT '属性seq',
  `attribute_value_seq` int DEFAULT NULL COMMENT '属性valueSeq',
  `attribute_value_name` text COMMENT '属性valuename',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=20461 DEFAULT CHARSET=utf8mb3 COMMENT='物料管理-物料简码属性表';


--
-- Table structure for table `mx_material_category_dna`
--

DROP TABLE IF EXISTS `mx_material_category_dna`;


CREATE TABLE `mx_material_category_dna` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `old_category_code` varchar(100) DEFAULT NULL COMMENT '原物料简码',
  `material_name` text COMMENT '物料名称',
  `old_material_name` varchar(255) DEFAULT NULL COMMENT '原物料名称',
  `type_seq` int DEFAULT NULL COMMENT '物料类型id',
  `type_name` varchar(100) DEFAULT NULL COMMENT '物料类型名称',
  `class_seq` int DEFAULT NULL COMMENT '物料类别id',
  `class_name` varchar(100) DEFAULT NULL COMMENT '物料类别名称',
  `class_path_name` varchar(100) DEFAULT NULL COMMENT '物料类别路径名称',
  `group_seq` int DEFAULT NULL COMMENT '物料分组id',
  `group_name` varchar(100) DEFAULT NULL COMMENT '物料分组名称',
  `unit_seq` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `provider_seq` int DEFAULT NULL COMMENT '默认供应商id',
  `provider_name` varchar(100) DEFAULT NULL COMMENT '默认供应商名称',
  `is_match_size` int DEFAULT '0' COMMENT '是否配码（0-否，1-是）',
  `is_each_expend` int DEFAULT '0' COMMENT '是否码段用量(0-否，1-是)',
  `is_used` int DEFAULT '0' COMMENT '是否使用',
  `enable` int DEFAULT '0' COMMENT '是否停用(0-否，1-是)',
  `is_out_sourcing` int DEFAULT '0' COMMENT '是否外发加工(0-否,1-是)',
  `is_color_constraint` int DEFAULT '0' COMMENT '是否颜色约束',
  `money_type_seq` int DEFAULT NULL COMMENT '币种id',
  `money_type_name` varchar(100) DEFAULT NULL COMMENT '币种名称',
  `purchase_unit_seq` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '采购单位名称',
  `purchase_convert_rate` decimal(18,2) DEFAULT '0.00' COMMENT '采购转换比率',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方id',
  `provider_type_name` varchar(100) DEFAULT NULL COMMENT '供方名称',
  `purchase_hit_rate` decimal(18,2) DEFAULT '0.00' COMMENT '采购打大率',
  `many_purchase_rate` decimal(18,2) DEFAULT '0.00' COMMENT '允许多采比率',
  `many_receive_rate` decimal(18,2) DEFAULT '0.00' COMMENT '允许多收比率',
  `is_exempt_verify` int DEFAULT '0' COMMENT '是否免检(0-否,1-是)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `data_source` varchar(100) DEFAULT NULL COMMENT '数据来源',
  `item_source` varchar(100) DEFAULT NULL COMMENT '单据来源',
  `approve_status` bit(2) DEFAULT NULL COMMENT '审批状态',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `dna_id` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `category_code` (`category_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5139 DEFAULT CHARSET=utf8mb3 COMMENT='物料简码';


--
-- Table structure for table `mx_material_category_zhx0708`
--

DROP TABLE IF EXISTS `mx_material_category_zhx0708`;


CREATE TABLE `mx_material_category_zhx0708` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `old_category_code` varchar(100) DEFAULT NULL COMMENT '原物料简码',
  `material_name` text COMMENT '物料名称',
  `old_material_name` varchar(255) DEFAULT NULL COMMENT '原物料名称',
  `type_seq` int DEFAULT NULL COMMENT '物料类型id',
  `type_name` varchar(100) DEFAULT NULL COMMENT '物料类型名称',
  `class_seq` int DEFAULT NULL COMMENT '物料类别id',
  `class_name` varchar(100) DEFAULT NULL COMMENT '物料类别名称',
  `class_path_name` varchar(100) DEFAULT NULL COMMENT '物料类别路径名称',
  `group_seq` int DEFAULT NULL COMMENT '物料分组id',
  `group_name` varchar(100) DEFAULT NULL COMMENT '物料分组名称',
  `unit_seq` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `provider_seq` int DEFAULT NULL COMMENT '默认供应商id',
  `provider_name` varchar(100) DEFAULT NULL COMMENT '默认供应商名称',
  `is_match_size` int DEFAULT '0' COMMENT '是否配码（0-否，1-是）',
  `is_each_expend` int DEFAULT '0' COMMENT '是否码段用量(0-否，1-是)',
  `is_used` int DEFAULT '0' COMMENT '是否使用',
  `enable` int DEFAULT '0' COMMENT '是否停用(0-否，1-是)',
  `is_out_sourcing` int DEFAULT '0' COMMENT '是否外发加工(0-否,1-是)',
  `is_color_constraint` int DEFAULT '0' COMMENT '是否颜色约束',
  `money_type_seq` int DEFAULT NULL COMMENT '币种id',
  `money_type_name` varchar(100) DEFAULT NULL COMMENT '币种名称',
  `purchase_unit_seq` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '采购单位名称',
  `purchase_convert_rate` decimal(18,2) DEFAULT '0.00' COMMENT '采购转换比率',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方id',
  `provider_type_name` varchar(100) DEFAULT NULL COMMENT '供方名称',
  `purchase_hit_rate` decimal(18,2) DEFAULT '0.00' COMMENT '采购打大率',
  `many_purchase_rate` decimal(18,2) DEFAULT '0.00' COMMENT '允许多采比率',
  `many_receive_rate` decimal(18,2) DEFAULT '0.00' COMMENT '允许多收比率',
  `is_exempt_verify` int DEFAULT '0' COMMENT '是否免检(0-否,1-是)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `data_source` varchar(100) DEFAULT NULL COMMENT '数据来源',
  `item_source` varchar(100) DEFAULT NULL COMMENT '单据来源',
  `approve_status` bit(2) DEFAULT NULL COMMENT '审批状态',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `category_code` (`category_code`)
) ENGINE=InnoDB AUTO_INCREMENT=17563 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料简码';


--
-- Table structure for table `mx_material_class`
--

DROP TABLE IF EXISTS `mx_material_class`;


CREATE TABLE `mx_material_class` (
  `seq` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL COMMENT '类别编码',
  `name` varchar(255) DEFAULT NULL COMMENT '类别名称',
  `class_path_name` varchar(255) DEFAULT NULL COMMENT '物料类别路径名称',
  `level` int DEFAULT NULL COMMENT '层级',
  `serial_no` int DEFAULT NULL COMMENT '同层级顺序号',
  `parent_seq` int DEFAULT NULL COMMENT '父级',
  `material_type_id` int DEFAULT NULL COMMENT '物料类型id',
  `material_type_name` varchar(500) DEFAULT NULL COMMENT '物料类型名称',
  `is_color_constraint` int DEFAULT NULL COMMENT '是否颜色约束',
  `number_format` varchar(50) DEFAULT NULL COMMENT '数量格式化',
  `is_each_expend` int DEFAULT NULL COMMENT '是否码段用量',
  `purchase_money_type_id` int DEFAULT NULL COMMENT '采购币种id',
  `purchase_money_type_name` varchar(50) DEFAULT NULL COMMENT '采购币种名称',
  `unit_id` int DEFAULT NULL COMMENT '单位ID',
  `unit_name` varchar(50) DEFAULT NULL COMMENT '单位名称',
  `purchase_unit_id` int DEFAULT NULL COMMENT '采购单位id',
  `purchase_unit_name` varchar(50) DEFAULT NULL COMMENT '采购单位名称',
  `purchase_hit_rate` decimal(18,2) DEFAULT NULL COMMENT '采购打大率',
  `many_purchase_rate` decimal(18,2) DEFAULT NULL COMMENT '允许多采比率',
  `many_receive_rate` decimal(18,2) DEFAULT NULL COMMENT '允许多收比率',
  `is_exempt_verify` int DEFAULT NULL COMMENT '是否免检',
  `colour` int DEFAULT NULL COMMENT '颜色',
  `chinese` varchar(255) DEFAULT NULL COMMENT '中文',
  `vietnamese` varchar(255) DEFAULT NULL COMMENT '越文',
  `cambodia` varchar(255) DEFAULT NULL COMMENT '柬文',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_delete` char(1) DEFAULT NULL COMMENT '删除：0-否,1-是',
  `create_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `create_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=287 DEFAULT CHARSET=utf8mb3 COMMENT='物料类别';


--
-- Table structure for table `mx_material_class_attribute`
--

DROP TABLE IF EXISTS `mx_material_class_attribute`;


CREATE TABLE `mx_material_class_attribute` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `material_class_id` bigint DEFAULT NULL COMMENT '物料类别id',
  `serial_no` bigint DEFAULT NULL COMMENT '顺序号',
  `attribute_id` bigint DEFAULT NULL COMMENT '属性ID',
  `attribute_code` varchar(50) DEFAULT NULL COMMENT '属性编号',
  `attribute_name` varchar(255) DEFAULT NULL COMMENT '属性名称',
  `attribute_value` text COMMENT '属性值',
  `separator_str` varchar(50) DEFAULT NULL COMMENT '分隔符',
  `is_required` int DEFAULT NULL COMMENT '是否必填',
  `remark` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `delete_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime(3) DEFAULT NULL COMMENT '删除时间',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_at` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3105 DEFAULT CHARSET=utf8mb3 COMMENT='物料类别属性表';


--
-- Table structure for table `mx_material_info`
--

DROP TABLE IF EXISTS `mx_material_info`;


CREATE TABLE `mx_material_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码id',
  `material_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `old_material_code` varchar(100) DEFAULT NULL COMMENT '原物料编码',
  `color_code` varchar(100) DEFAULT NULL COMMENT '颜色编号',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色名称',
  `size_code` varchar(100) DEFAULT NULL COMMENT '尺码编号',
  `size_name` varchar(100) DEFAULT NULL COMMENT '尺码名称',
  `material_control_code` varchar(100) DEFAULT NULL COMMENT '物控编码',
  `enable` int DEFAULT '1' COMMENT '是否停用(0-否,1-是)',
  `hidden` int DEFAULT '0' COMMENT '是否隐藏',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `memo` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_true` int DEFAULT '1' COMMENT '是否真实物料',
  `dna_id` int DEFAULT NULL,
  `created_name` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_material_code` (`material_code`)
) ENGINE=InnoDB AUTO_INCREMENT=103339 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料编码';


--
-- Table structure for table `mx_material_info_20250521`
--

DROP TABLE IF EXISTS `mx_material_info_20250521`;


CREATE TABLE `mx_material_info_20250521` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码id',
  `material_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `old_material_code` varchar(100) DEFAULT NULL COMMENT '原物料编码',
  `color_code` varchar(100) DEFAULT NULL COMMENT '颜色编号',
  `color_name` varchar(100) DEFAULT NULL COMMENT '颜色名称',
  `size_code` varchar(100) DEFAULT NULL COMMENT '尺码编号',
  `size_name` varchar(100) DEFAULT NULL COMMENT '尺码名称',
  `material_control_code` varchar(100) DEFAULT NULL COMMENT '物控编码',
  `enable` int DEFAULT '1' COMMENT '是否停用(0-否,1-是)',
  `hidden` int DEFAULT '0' COMMENT '是否隐藏',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `memo` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_true` int DEFAULT '1' COMMENT '是否真实物料'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `mx_material_info_20250805`
--

DROP TABLE IF EXISTS `mx_material_info_20250805`;


CREATE TABLE `mx_material_info_20250805` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码id',
  `material_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `old_material_code` varchar(100) DEFAULT NULL COMMENT '原物料编码',
  `color_code` varchar(100) DEFAULT NULL COMMENT '颜色编号',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色名称',
  `size_code` varchar(100) DEFAULT NULL COMMENT '尺码编号',
  `size_name` varchar(100) DEFAULT NULL COMMENT '尺码名称',
  `material_control_code` varchar(100) DEFAULT NULL COMMENT '物控编码',
  `enable` int DEFAULT '1' COMMENT '是否停用(0-否,1-是)',
  `hidden` int DEFAULT '0' COMMENT '是否隐藏',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `memo` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_true` int DEFAULT '1' COMMENT '是否真实物料',
  `dna_id` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_material_code` (`material_code`)
) ENGINE=InnoDB AUTO_INCREMENT=62509 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料编码';


--
-- Table structure for table `mx_material_info_dna`
--

DROP TABLE IF EXISTS `mx_material_info_dna`;


CREATE TABLE `mx_material_info_dna` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码id',
  `material_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `old_material_code` varchar(100) DEFAULT NULL COMMENT '原物料编码',
  `color_code` varchar(100) DEFAULT NULL COMMENT '颜色编号',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色名称',
  `size_code` varchar(100) DEFAULT NULL COMMENT '尺码编号',
  `size_name` varchar(100) DEFAULT NULL COMMENT '尺码名称',
  `material_control_code` varchar(100) DEFAULT NULL COMMENT '物控编码',
  `enable` int DEFAULT '1' COMMENT '是否停用(0-否,1-是)',
  `hidden` int DEFAULT '0' COMMENT '是否隐藏',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `memo` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_true` int DEFAULT '1' COMMENT '是否真实物料',
  `dna_id` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_material_code` (`material_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=219715 DEFAULT CHARSET=utf8mb3 COMMENT='物料编码';


--
-- Table structure for table `mx_material_outsouring`
--

DROP TABLE IF EXISTS `mx_material_outsouring`;


CREATE TABLE `mx_material_outsouring` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `material_category_seq` int DEFAULT NULL COMMENT '组合物料简码seq',
  `parent_id` int DEFAULT NULL COMMENT '子材料简码seq',
  `material_category_info_code` varchar(255) DEFAULT NULL COMMENT '子材料物料编码',
  `material_category_info_seq` int DEFAULT NULL COMMENT '子材料物料编码序号',
  `serial_no` int DEFAULT NULL COMMENT '顺序号',
  `is_color` int DEFAULT '0' COMMENT '是否固色',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色',
  `color_code` varchar(100) DEFAULT NULL,
  `is_size` int DEFAULT '0' COMMENT '是否固码',
  `size_name` varchar(100) DEFAULT NULL COMMENT '码号',
  `size_code` varchar(50) DEFAULT NULL,
  `is_each_expend` int DEFAULT '0' COMMENT '是否码段用量',
  `is_out_sourcing` int DEFAULT '0' COMMENT '是否外发加工(0-否,1-是)',
  `each_expend` varchar(50) DEFAULT NULL COMMENT '单耗',
  `loss_expend` varchar(50) DEFAULT NULL COMMENT '损耗',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方seq',
  `provider_type_name` varchar(100) DEFAULT NULL COMMENT '供方名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT '0' COMMENT '供应商名称',
  `unit_name` varchar(50) DEFAULT '0' COMMENT '单位',
  `enable` int DEFAULT '1' COMMENT '是否可用',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `dna_id` int DEFAULT NULL,
  PRIMARY KEY (`seq`),
  KEY `mx_index` (`material_category_seq`,`is_deleted`,`provider_type_name`)
) ENGINE=InnoDB AUTO_INCREMENT=205078 DEFAULT CHARSET=utf8mb3 COMMENT='组合材料明细表';


--
-- Table structure for table `mx_material_outsouring_dna`
--

DROP TABLE IF EXISTS `mx_material_outsouring_dna`;


CREATE TABLE `mx_material_outsouring_dna` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `parent_id` int DEFAULT NULL COMMENT '原材料简码seq',
  `material_category_info_code` varchar(255) DEFAULT NULL COMMENT '子材料物料编码',
  `material_category_info_seq` int DEFAULT NULL COMMENT '子材料物料编码序号',
  `serial_no` int DEFAULT NULL COMMENT '顺序号',
  `is_color` int DEFAULT '0' COMMENT '是否固色',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色',
  `color_code` varchar(100) DEFAULT NULL,
  `is_size` int DEFAULT '0' COMMENT '是否固码',
  `size_name` varchar(100) DEFAULT NULL COMMENT '码号',
  `size_code` varchar(50) DEFAULT NULL,
  `is_each_expend` int DEFAULT '0' COMMENT '是否码段用量',
  `is_out_sourcing` int DEFAULT '0' COMMENT '是否外发加工(0-否,1-是)',
  `each_expend` varchar(50) DEFAULT NULL COMMENT '单耗',
  `loss_expend` varchar(50) DEFAULT NULL COMMENT '损耗',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方seq',
  `provider_type_name` varchar(100) DEFAULT NULL COMMENT '供方名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT '0' COMMENT '供应商名称',
  `unit_name` varchar(50) DEFAULT '0' COMMENT '单位',
  `enable` int DEFAULT '1' COMMENT '是否可用',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `dna_id` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3759 DEFAULT CHARSET=utf8mb3 COMMENT='组合材料明细表';


--
-- Table structure for table `number`
--

DROP TABLE IF EXISTS `number`;


CREATE TABLE `number` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` int DEFAULT NULL COMMENT '编号代码',
  `auto` varchar(22) DEFAULT NULL COMMENT '前缀',
  `maxNum` int DEFAULT '1' COMMENT '当前最大值',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='最大编号表';


--
-- Table structure for table `od_order_doc`
--

DROP TABLE IF EXISTS `od_order_doc`;


CREATE TABLE `od_order_doc` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `code` varchar(60) DEFAULT NULL COMMENT '订单合同号',
  `type` int DEFAULT NULL COMMENT '订单类型',
  `type_name` varchar(255) DEFAULT NULL COMMENT '订单名称',
  `pay_way_seq` int DEFAULT NULL COMMENT '付款方式(字典序号)',
  `pay_way_name` varchar(255) DEFAULT NULL COMMENT '付款方式(字典名称)',
  `order_date` date DEFAULT NULL COMMENT '下单日期',
  `money_type_seq` int DEFAULT NULL COMMENT '币种序号(目标币种)',
  `money_type` varchar(50) DEFAULT NULL COMMENT '币种编码(目标币种)',
  `money_name` varchar(255) DEFAULT NULL COMMENT '币种名称(目标币种)',
  `money_type_rate` decimal(18,2) DEFAULT NULL COMMENT '汇率(原币种：人民币与目标币种的汇率)',
  `custom_seq` int DEFAULT NULL COMMENT '客户序号',
  `custom_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `custom_contact_seq` int DEFAULT NULL COMMENT '客户联系人序号(根据选中客户查询联系人后选中)',
  `custom_contact_name` varchar(255) DEFAULT NULL COMMENT '客户联系人名称(选中联系人带出)',
  `custom_contact_fax` varchar(255) DEFAULT NULL COMMENT '客户传真(选中联系人带出)',
  `custom_contact_receipt_address` varchar(255) DEFAULT NULL COMMENT '收货地址(选中联系人带出)',
  `custom_contact_receipt_address_abb` varchar(255) DEFAULT NULL COMMENT '收货地址简称(选中联系人带出)',
  `custom_contact_mobile_phone` varchar(50) DEFAULT NULL COMMENT '客户联系电话(选中联系人带出)',
  `freight_mode_seq` int DEFAULT NULL COMMENT '货运方式(字典seq)',
  `freight_mode` varchar(255) DEFAULT NULL COMMENT '货运方式(字典名称)',
  `receiving_department` varchar(255) DEFAULT NULL COMMENT '接单部门(默认当前登录用户所在部门，可修改)',
  `comp_seq` int DEFAULT NULL COMMENT '公司序号(根据当前登录用户获取所在公司)',
  `comp_name` varchar(255) DEFAULT NULL COMMENT '公司名称(根据当前登录用户获取所在公司)',
  `comp_contact_seq` int DEFAULT NULL COMMENT '公司联系人seq(根据当前登录用户所在公司查询联系人后选中)',
  `comp_contact_name` varchar(255) DEFAULT NULL COMMENT '公司联系人名称(选中联系人带出)',
  `comp_contact_mobile_phone` varchar(50) DEFAULT NULL COMMENT '公司联系人联系电话(选中联系人带出)',
  `comp_bank_seq` int DEFAULT NULL COMMENT '公司账户序号(根据当前登录用户获取所在公司查询账号信息)',
  `comp_bank_name` varchar(255) DEFAULT NULL COMMENT '公司账户名称(根据当前登录用户获取所在公司查询账号信息)',
  `current_account` varchar(255) DEFAULT NULL COMMENT '往来账户(数据格式：公司名称/公司账号名称)',
  `total_number` int DEFAULT '0' COMMENT '订单总数',
  `memo` text COMMENT '备注',
  `status_code` int DEFAULT NULL COMMENT '状态编码',
  `status` varchar(10) DEFAULT NULL COMMENT '状态名称',
  `enable` tinyint(1) DEFAULT '1' COMMENT '是否可用',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除',
  `version` varchar(255) DEFAULT NULL COMMENT '版本号',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_name` varchar(100) DEFAULT NULL COMMENT '创建人昵称',
  `created_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `data_source` varchar(255) DEFAULT NULL COMMENT '数据来源（导入、手动新增、流程单据）',
  PRIMARY KEY (`seq`),
  KEY `ky_code` (`code`,`enable`,`is_deleted`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb3 COMMENT='正式订单基础表信息';


--
-- Table structure for table `od_order_doc_aritcle_size`
--

DROP TABLE IF EXISTS `od_order_doc_aritcle_size`;


CREATE TABLE `od_order_doc_aritcle_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '订单序号',
  `order_doc_aritcle_seq` int DEFAULT NULL COMMENT '订单型体表序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体尺码表序号',
  `size_num` varchar(50) DEFAULT NULL COMMENT '尺码总数',
  `size_unused_num` varchar(50) DEFAULT NULL COMMENT '未处理尺码数',
  `no` int DEFAULT NULL COMMENT '顺序号',
  `size_seq` int DEFAULT NULL COMMENT 'size序号',
  `size_code` varchar(50) DEFAULT NULL COMMENT 'size编码',
  `size_name` varchar(50) DEFAULT NULL COMMENT 'size名称',
  `group_name` varchar(50) DEFAULT NULL COMMENT '尺码组名称',
  `is_standard_code` char(1) DEFAULT NULL COMMENT '是否基本码',
  `product_bar_code` varchar(50) DEFAULT NULL COMMENT '产品条码(客户产品类别获取)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '更新人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `order_doc_aritcle_seq` (`order_doc_aritcle_seq`),
  CONSTRAINT `od_order_doc_aritcle_size_ibfk_1` FOREIGN KEY (`order_doc_aritcle_seq`) REFERENCES `od_order_doc_article` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=29483 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='正式订单型体尺码';


--
-- Table structure for table `od_order_doc_aritcle_size_delivery_time`
--

DROP TABLE IF EXISTS `od_order_doc_aritcle_size_delivery_time`;


CREATE TABLE `od_order_doc_aritcle_size_delivery_time` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '订单序号',
  `order_doc_aritcle_size_seq` int DEFAULT NULL COMMENT '订单型体尺码表序号',
  `delivery_time` date DEFAULT NULL COMMENT '交期',
  `num` varchar(50) DEFAULT NULL COMMENT '交期数量',
  `unused_num` varchar(50) DEFAULT NULL COMMENT '未处理交期数',
  `no` int DEFAULT NULL COMMENT '顺序号',
  `discharge_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '出厂日期',
  `latest_shipping_date` timestamp NULL DEFAULT NULL COMMENT '最晚装船日',
  `transp_way` int DEFAULT NULL COMMENT '运输方式',
  `transp_way_name` varchar(255) DEFAULT NULL COMMENT '运输方式名称',
  `destination` varchar(50) DEFAULT NULL COMMENT '目的地',
  `packing_location` varchar(50) DEFAULT NULL COMMENT '装箱地',
  `unloading_location` varchar(50) DEFAULT NULL COMMENT '卸货地',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `order_doc_aritcle_size_seq` (`order_doc_aritcle_size_seq`),
  CONSTRAINT `od_order_doc_aritcle_size_delivery_time_ibfk_1` FOREIGN KEY (`order_doc_aritcle_size_seq`) REFERENCES `od_order_doc_aritcle_size` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=29482 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='正式订单型体尺码交期';


--
-- Table structure for table `od_order_doc_art_posit_size`
--

DROP TABLE IF EXISTS `od_order_doc_art_posit_size`;


CREATE TABLE `od_order_doc_art_posit_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '订单序号',
  `order_doc_aritcle_seq` int DEFAULT NULL COMMENT '订单型体序号',
  `od_order_doc_art_position` int DEFAULT NULL COMMENT '订单型体部位序号',
  `position_type` int DEFAULT NULL COMMENT '部位材料类型（0：型体部位材料；1：包材部位材料）',
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位',
  `is_effective` int DEFAULT '1' COMMENT '是否有效',
  `version` varchar(200) DEFAULT NULL COMMENT '版本号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体size',
  `position_seq` int DEFAULT NULL COMMENT '部位序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `size` varchar(255) DEFAULT NULL COMMENT '实际尺码',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=96384 DEFAULT CHARSET=utf8mb3 COMMENT='订单型体部位size';


--
-- Table structure for table `od_order_doc_art_position`
--

DROP TABLE IF EXISTS `od_order_doc_art_position`;


CREATE TABLE `od_order_doc_art_position` (
  `position_type` int DEFAULT NULL COMMENT '部位材料类型（0：型体部位材料；1：包材部位材料）',
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '正式订单seq',
  `order_doc_aritcle_seq` int DEFAULT NULL COMMENT '正式订单型体seq',
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位表序号',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `process_seq` int DEFAULT NULL COMMENT '制程seq',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料简码名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(50) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(50) DEFAULT NULL COMMENT '供方类型名称',
  `material_parent_seq` int DEFAULT NULL COMMENT '父级材料编辑序号-\r\n1、材料为子材料时有值\r\n2、子材料尺码数量与原材料一致',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(50) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(50) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(50) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(50) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_info_is_match_size` varchar(50) DEFAULT NULL COMMENT '物料是否配码',
  `material_info_is_each_expend` varchar(50) DEFAULT NULL COMMENT '物料是否码段用量',
  `material_info_is_out_sourcing` varchar(50) DEFAULT NULL COMMENT '物料是否外加工',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位seq',
  `material_category_unit_name` varchar(20) DEFAULT NULL COMMENT '物料单位名称',
  `ie_name` varchar(255) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(50) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(50) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(50) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `base_each_expend` decimal(12,4) DEFAULT NULL COMMENT '基本码用量',
  `loss_rate` decimal(14,4) DEFAULT NULL COMMENT '损耗率',
  `package_info_seq` int DEFAULT NULL COMMENT '包材info seq',
  `package_name` varchar(100) DEFAULT NULL COMMENT '包材库名称',
  `mrp_status` int NOT NULL DEFAULT '0' COMMENT '数据状态 0新增 1添加',
  `package_seq` int DEFAULT NULL COMMENT '包材库seq',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(50) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_craft` int DEFAULT '0' COMMENT '是否工艺',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `order_doc_aritcle_seq` (`order_doc_aritcle_seq`),
  CONSTRAINT `od_order_doc_art_position_ibfk_1` FOREIGN KEY (`order_doc_aritcle_seq`) REFERENCES `od_order_doc_article` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=18163 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='正式订单型体部位-物料信息';


--
-- Table structure for table `od_order_doc_art_position_material`
--

DROP TABLE IF EXISTS `od_order_doc_art_position_material`;


CREATE TABLE `od_order_doc_art_position_material` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `od_order_doc_seq` int DEFAULT NULL COMMENT '正式订单序号',
  `order_doc_aritcle_seq` int DEFAULT NULL COMMENT '正式订单型体表序号',
  `od_order_doc_art_position` int DEFAULT NULL COMMENT '正式订单型体部位表序号',
  `art_seq` int DEFAULT NULL COMMENT '型体seq',
  `art_post_seq` int DEFAULT NULL COMMENT '型体部位序号',
  `parent_seq` int DEFAULT NULL COMMENT '物料父级seq',
  `position_type` int DEFAULT NULL COMMENT '部位材料类型（0：型体部位材料；1：包材部位材料）',
  `no` int DEFAULT NULL,
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `base_each_expend` decimal(11,4) DEFAULT NULL COMMENT '当前物料单耗（(单耗=1*A1单耗)：1*子材料单耗*子材料单耗*...）\r\nA(外加工材料,单耗1)\r\nA1(单耗=1*A1单耗)\r\nA11(单耗=1*A1单耗*A11单耗)\r\nA12(单耗=1*A1单耗*A12单耗)\r\nA2(单耗=1*A2单耗)',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` text COMMENT '物料简码名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_info_is_match_size` varchar(100) DEFAULT NULL COMMENT '物料是否配码',
  `material_info_is_each_expend` varchar(100) DEFAULT NULL COMMENT '物料是否码段用量',
  `material_info_is_out_sourcing` varchar(100) DEFAULT NULL COMMENT '物料是否外加工',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位seq',
  `material_category_unit_name` varchar(20) DEFAULT NULL COMMENT '物料单位名称',
  `ie_name` varchar(255) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` text COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=96406 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='正式订单型体部位-物料明细';


--
-- Table structure for table `od_order_doc_art_position_size_dosage`
--

DROP TABLE IF EXISTS `od_order_doc_art_position_size_dosage`;


CREATE TABLE `od_order_doc_art_position_size_dosage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '正式订单序号',
  `order_doc_aritcle_seq` int DEFAULT NULL COMMENT '正式订单型体表序号',
  `art_position_size_seq` int DEFAULT NULL COMMENT '型体部位尺码表序号',
  `art_position_size_dosage_seq` int DEFAULT NULL COMMENT '型体部位尺码用量表序号',
  `order_doc_aritcle_position_seq` int DEFAULT NULL COMMENT '正式订单型体部位物料序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体size序号',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码序号',
  `material_size_name` varchar(255) DEFAULT NULL COMMENT '物料尺码名称',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '用量',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否被删除',
  PRIMARY KEY (`seq`),
  KEY `order_doc_aritcle_position_seq` (`order_doc_aritcle_position_seq`),
  CONSTRAINT `od_order_doc_art_position_size_dosage_ibfk_1` FOREIGN KEY (`order_doc_aritcle_position_seq`) REFERENCES `od_order_doc_art_position` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=85496 DEFAULT CHARSET=utf8mb3 COMMENT='正式订单型体部位各码用量明细';


--
-- Table structure for table `od_order_doc_article`
--

DROP TABLE IF EXISTS `od_order_doc_article`;


CREATE TABLE `od_order_doc_article` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '订单序号',
  `row_no` varchar(255) DEFAULT NULL COMMENT 'PO（原行标识）',
  `is_pre_compensation` int DEFAULT '0' COMMENT '是否预补',
  `art_seq` int DEFAULT NULL COMMENT '产品资料序号',
  `logo` varchar(255) DEFAULT NULL COMMENT '图片',
  `sku` varchar(255) DEFAULT NULL COMMENT '产品编号',
  `code` varchar(30) DEFAULT NULL COMMENT '工厂型体编号',
  `name` varchar(50) DEFAULT NULL COMMENT '型体名称',
  `customer_article_name` varchar(255) DEFAULT NULL COMMENT '客户型体名称',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `color` int DEFAULT NULL COMMENT '颜色序号',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `quarter_code` int DEFAULT NULL COMMENT '下单季度序号',
  `product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `product_class_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `basic_size_seq` varchar(255) DEFAULT NULL COMMENT 'size模版(size模版seq)',
  `basic_size_code` varchar(255) DEFAULT NULL COMMENT '基本码',
  `size_range` varchar(50) DEFAULT NULL COMMENT '码段',
  `sex` int DEFAULT NULL COMMENT '样鞋性别（字典表seq）',
  `last_code` varchar(100) DEFAULT NULL COMMENT '楦头代号',
  `outside_code` varchar(30) DEFAULT NULL COMMENT '大底代号',
  `cutter_cod` varchar(30) DEFAULT NULL COMMENT '刀模编号',
  `face_material_seq` int DEFAULT NULL COMMENT '帮面材质seq',
  `face_material_name` varchar(50) DEFAULT NULL COMMENT '帮面材质',
  `implement_standard` varchar(255) DEFAULT NULL COMMENT '国家执行标准',
  `country_barcode` varchar(255) DEFAULT NULL COMMENT '国家条码',
  `sample_stage_seq` varchar(255) DEFAULT NULL COMMENT '样品阶段id',
  `sample_stage_name` varchar(255) DEFAULT NULL COMMENT '样品阶段名称',
  `total_number` int DEFAULT '0' COMMENT '订单型体总数',
  `dispatch_group_number` int DEFAULT '0' COMMENT '派工数量',
  `order_quarter` varchar(50) DEFAULT NULL COMMENT '下单季度',
  `manual_prod_code` varchar(100) DEFAULT NULL COMMENT '指令号',
  `customer_code` varchar(200) DEFAULT NULL COMMENT '客人订单号',
  `version` varchar(255) DEFAULT 'V1.0.0' COMMENT '版本号',
  `status` varchar(3) DEFAULT NULL COMMENT '状态\r\n',
  `memo` varchar(255) DEFAULT NULL COMMENT '型体说明',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否有效',
  `end_delivery_date` date DEFAULT NULL COMMENT '最晚交期时间',
  `destination` varchar(200) DEFAULT NULL COMMENT '目的地',
  `size_codes` varchar(255) DEFAULT NULL COMMENT '尺码列表',
  `discharge_date` datetime DEFAULT NULL COMMENT '生产日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `bom_updated_by` varchar(100) DEFAULT NULL COMMENT '包材更新人',
  `bom_updated_at` datetime DEFAULT NULL COMMENT '绑定的包材更新时间',
  PRIMARY KEY (`seq`),
  KEY `od_order_doc_seq` (`od_order_doc_seq`),
  KEY `od_proc` (`row_no`,`od_order_doc_seq`) USING BTREE,
  CONSTRAINT `od_order_doc_article_ibfk_1` FOREIGN KEY (`od_order_doc_seq`) REFERENCES `od_order_doc` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=5885 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='正式订单型体';


--
-- Table structure for table `od_order_doc_article_package`
--

DROP TABLE IF EXISTS `od_order_doc_article_package`;


CREATE TABLE `od_order_doc_article_package` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `package_seq` int DEFAULT NULL,
  `package_code` varchar(100) DEFAULT NULL COMMENT '包材库编码',
  `order_art_seq` int DEFAULT NULL,
  `package_name` varchar(255) DEFAULT NULL COMMENT '包材库名称',
  `show_status` int DEFAULT NULL COMMENT '展示状态 1展示 0不展示',
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=3299 DEFAULT CHARSET=utf8mb3 COMMENT='正式订单行绑定包材信息';


--
-- Table structure for table `od_order_doc_change`
--

DROP TABLE IF EXISTS `od_order_doc_change`;


CREATE TABLE `od_order_doc_change` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `old_order_seq` int DEFAULT NULL COMMENT '变更前订单序号',
  `old_order_code` varchar(255) DEFAULT NULL COMMENT '变更前订单号',
  `new_order_seq` int DEFAULT NULL COMMENT '变更后订单序号',
  `new_order_code` varchar(255) DEFAULT NULL COMMENT '变更后订单号',
  `code` varchar(255) DEFAULT NULL COMMENT '变更申请号',
  `apply_by` varchar(255) DEFAULT NULL COMMENT '申请人',
  `apply_by_name` varchar(255) DEFAULT NULL COMMENT '申请人名称',
  `apply_at` datetime DEFAULT NULL COMMENT '申请日期',
  `notifier` varchar(11) DEFAULT NULL COMMENT '通知人',
  `notifier_name` varchar(255) DEFAULT NULL COMMENT '通知人名称',
  `change_memo` text COMMENT '变更原因',
  `version` varchar(255) DEFAULT NULL COMMENT '版本',
  `status` varchar(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_name` varchar(100) DEFAULT NULL COMMENT '创建人昵称',
  `created_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COMMENT='正式订单变更申请';


--
-- Table structure for table `od_product_order_doc`
--

DROP TABLE IF EXISTS `od_product_order_doc`;


CREATE TABLE `od_product_order_doc` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `code` varchar(64) DEFAULT NULL COMMENT '生产订单编号',
  `art_seq` int DEFAULT NULL COMMENT '产品资料序号',
  `logo` varchar(255) DEFAULT NULL COMMENT '主图',
  `sku` varchar(255) DEFAULT NULL COMMENT '产品编号',
  `art_code` varchar(30) DEFAULT NULL COMMENT '工厂型体编号',
  `art_name` varchar(50) DEFAULT NULL COMMENT '型体名称',
  `manual_prod_code` varchar(100) DEFAULT NULL COMMENT '手工排产单号',
  `customer_code` varchar(200) DEFAULT NULL COMMENT '客人订单号',
  `row_no` varchar(255) NOT NULL COMMENT '行标识',
  `customer_seq` int DEFAULT NULL COMMENT '客户seq',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `customer_article_name` varchar(255) DEFAULT NULL COMMENT '客户型体名称',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `art_color` int DEFAULT NULL COMMENT '颜色序号',
  `art_color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `art_quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `product_class_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `basic_size_seq` varchar(255) DEFAULT NULL COMMENT 'size模版(size模版seq)',
  `basic_size_code` varchar(255) DEFAULT NULL COMMENT '基本码',
  `art_size_range` varchar(50) DEFAULT NULL COMMENT '码段',
  `version` varchar(255) DEFAULT NULL COMMENT '订单版本号',
  `art_sex` int DEFAULT NULL COMMENT '样鞋性别（字典表seq）',
  `art_version` varchar(255) DEFAULT NULL COMMENT '版本号',
  `status` varchar(3) DEFAULT NULL COMMENT '状态\r\n',
  `memo` varchar(255) DEFAULT NULL COMMENT '型体说明',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_name` varchar(100) DEFAULT NULL COMMENT '创建人',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否有效',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  PRIMARY KEY (`seq`),
  UNIQUE KEY `od_product_order_doc_code_index` (`code`),
  KEY `idx_code_deleted` (`code`,`is_deleted`,`seq`,`sku`,`art_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=5058 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='生产订单';


--
-- Table structure for table `od_product_order_doc_change`
--

DROP TABLE IF EXISTS `od_product_order_doc_change`;


CREATE TABLE `od_product_order_doc_change` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proOrderSeq` int DEFAULT NULL COMMENT '需要变更生产订单序号',
  `proOrderCode` varchar(255) DEFAULT NULL COMMENT '生产订单编号',
  `art_seq` int DEFAULT NULL COMMENT '产品资料序号',
  `logo` varchar(255) DEFAULT NULL COMMENT '主图',
  `sku` varchar(255) DEFAULT NULL COMMENT '产品编号',
  `art_code` varchar(30) DEFAULT NULL COMMENT '工厂型体编号',
  `art_name` varchar(50) DEFAULT NULL COMMENT '型体名称',
  `customer_article_name` varchar(255) DEFAULT NULL COMMENT '客户型体名称',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `art_color` int DEFAULT NULL COMMENT '颜色序号',
  `art_color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `art_quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `product_class_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `basic_size_seq` varchar(255) DEFAULT NULL COMMENT 'size模版(size模版seq)',
  `basic_size_code` varchar(255) DEFAULT NULL COMMENT '基本码',
  `art_size_range` varchar(50) DEFAULT NULL COMMENT '码段',
  `version` varchar(255) DEFAULT NULL COMMENT '订单版本号',
  `art_sex` int DEFAULT NULL COMMENT '样鞋性别（字典表seq）',
  `art_version` varchar(255) DEFAULT NULL COMMENT '版本号',
  `status` varchar(3) DEFAULT NULL COMMENT '状态\n',
  `memo` varchar(255) DEFAULT NULL COMMENT '型体说明',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否有效',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='生产订单变更记录';


--
-- Table structure for table `od_product_order_doc_size_delivery_time`
--

DROP TABLE IF EXISTS `od_product_order_doc_size_delivery_time`;


CREATE TABLE `od_product_order_doc_size_delivery_time` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `product_order_order_size_seq` int DEFAULT NULL COMMENT '生产订单型体尺码表序号',
  `od_order_delivery_seq` int DEFAULT NULL COMMENT '正式订单交期表序号',
  `delivery_time` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '交期',
  `num` varchar(50) DEFAULT NULL COMMENT '交期数量',
  `no` int DEFAULT NULL COMMENT '顺序号',
  `discharge_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '出厂日期',
  `latest_shipping_date` timestamp NULL DEFAULT NULL COMMENT '最晚装船日',
  `transp_way` int DEFAULT NULL COMMENT '运输方式',
  `transp_way_name` varchar(255) DEFAULT NULL COMMENT '运输方式名称',
  `destination` varchar(50) DEFAULT NULL COMMENT '目的地',
  `packing_location` varchar(50) DEFAULT NULL COMMENT '装箱地',
  `unloading_location` varchar(50) DEFAULT NULL COMMENT '卸货地',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `product_order_order_size_seq` (`product_order_order_size_seq`),
  CONSTRAINT `od_product_order_doc_size_delivery_time_ibfk_1` FOREIGN KEY (`product_order_order_size_seq`) REFERENCES `od_product_order_order_size` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=27950 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='生产订单型体尺码交期';


--
-- Table structure for table `od_product_order_order`
--

DROP TABLE IF EXISTS `od_product_order_order`;


CREATE TABLE `od_product_order_order` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `order_seq` int DEFAULT NULL COMMENT '正式订单序号',
  `prou_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `order_doc_aritcle_seq` int DEFAULT NULL COMMENT '正式订单型体序号',
  `enable` int DEFAULT '1' COMMENT '是否启用（0：未启用；1：已启用）',
  `version` varchar(255) DEFAULT 'V1.0.0' COMMENT '版本号',
  PRIMARY KEY (`seq`),
  KEY `prou_order_seq` (`prou_order_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=5077 DEFAULT CHARSET=utf8mb3 COMMENT='生产订单-正式订单关联关系表';


--
-- Table structure for table `od_product_order_order_position`
--

DROP TABLE IF EXISTS `od_product_order_order_position`;


CREATE TABLE `od_product_order_order_position` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `od_prod_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `od_prod_order_order_seq` int DEFAULT NULL COMMENT '生产-正式订单行关联关系表序号',
  `parent_seq` int DEFAULT NULL COMMENT '部位物料父子级',
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位表序号',
  `order_art_position_seq` int DEFAULT NULL COMMENT '正式订单型体部位序号',
  `od_order_doc_code` varchar(255) DEFAULT NULL COMMENT '正式订单号(实际存的正式订单序号)',
  `od_prod_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `order_doc_aritcle_seq` int DEFAULT NULL COMMENT '正式订单型体seq',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_no` int DEFAULT NULL COMMENT '部位顺序号',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `material_category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` text COMMENT '物料简码名称',
  `material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(50) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(50) DEFAULT NULL COMMENT '供方类型名称',
  `material_parent_seq` int DEFAULT NULL COMMENT '父级材料序号-\r\n1、材料为子材料时有值\r\n2、子材料尺码数量与原材料一致',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(50) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(50) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(500) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_is_match_size` varchar(50) DEFAULT NULL COMMENT '物料是否配码',
  `material_info_is_each_expend` varchar(50) DEFAULT NULL COMMENT '物料是否码段用量',
  `material_info_is_out_sourcing` varchar(1) DEFAULT '0' COMMENT '物料是否外加工',
  `quantity` int DEFAULT NULL COMMENT '总数量',
  `usages` decimal(11,4) DEFAULT NULL COMMENT '总用量',
  `average_usage` varchar(50) DEFAULT NULL COMMENT '平均用量',
  `memo` varchar(500) DEFAULT NULL COMMENT '备注',
  `mx_material_category_type_name` varchar(255) DEFAULT NULL COMMENT '物料类型名称',
  `mx_material_category_type_seq` int DEFAULT NULL COMMENT '物料类型序号',
  `mx_material_category_class_seq` varchar(255) DEFAULT NULL COMMENT '物料类别序号',
  `mx_material_category_class_name` varchar(255) DEFAULT NULL COMMENT '物料类别名称',
  `mx_material_category_class_path_name` varchar(255) DEFAULT NULL COMMENT '物料类别路径名称',
  `mx_material_category_group_seq` int DEFAULT NULL COMMENT '物料分组序号',
  `mx_material_category_group_name` varchar(100) DEFAULT NULL COMMENT '物料分组名称',
  `mx_material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位序号',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料单位名称',
  `mx_material_category_is_exempt_verify` int DEFAULT '0' COMMENT '物料是否免检(0-否,1-是)',
  `mx_material_category_is_color_constraint` int DEFAULT '0' COMMENT '物料是否颜色约束',
  `mx_material_category_money_type_seq` int DEFAULT NULL COMMENT '物料币种id',
  `mx_material_category_money_type_name` varchar(100) DEFAULT NULL COMMENT '物料币种名称',
  `mx_material_category_purchase_unit_seq` int DEFAULT NULL COMMENT '物料采购单位id',
  `mx_material_category_purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '物料采购单位名称',
  `mx_material_category_purchase_convert_rate` decimal(18,2) DEFAULT NULL COMMENT '物料采购转换比率',
  `mx_material_category_purchase_hit_rate` decimal(18,2) DEFAULT NULL COMMENT '物料采购打大率',
  `mx_material_category_many_purchase_rate` decimal(18,2) DEFAULT NULL COMMENT '物料允许多采比率',
  `version` varchar(20) DEFAULT NULL COMMENT '版本号',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `od_prod_order_order_seq` (`od_prod_order_order_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2469674 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='生产订单-正式订单型体部位-物料信息';


--
-- Table structure for table `od_product_order_order_position_change`
--

DROP TABLE IF EXISTS `od_product_order_order_position_change`;


CREATE TABLE `od_product_order_order_position_change` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `art_change_record_seq` int DEFAULT NULL COMMENT '需要变更生产订单序号',
  `product_order_seq` int DEFAULT NULL,
  `product_order_order_seq` int DEFAULT NULL COMMENT '生产关联关系表序号',
  `old_order_position_seq` int NOT NULL COMMENT '旧生产订单物料信息主键',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `process_seq` int DEFAULT NULL COMMENT '制程主键',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料简码名称',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_colour` varchar(50) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '物料编码颜色名称',
  `quantity` int DEFAULT NULL COMMENT '总数量',
  `usages` decimal(10,4) DEFAULT NULL COMMENT '总用量',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=18104 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='生产订单-正式订单型体部位-物料信息变更表';


--
-- Table structure for table `od_product_order_order_position_size_change`
--

DROP TABLE IF EXISTS `od_product_order_order_position_size_change`;


CREATE TABLE `od_product_order_order_position_size_change` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `old_order_position_size_seq` int DEFAULT NULL COMMENT '生产订单型体部位各码总用量明细主键',
  `od_prod_order_order_seq` int DEFAULT NULL COMMENT '生产订单正式订单关联关系表序号',
  `product_order_order_position_size_seq` int DEFAULT NULL COMMENT '生产订单型体部位尺码表序号',
  `product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单型体部位表序号',
  `product_order_order_size_seq` int DEFAULT NULL COMMENT '生产订单型体size序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体size序号',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码序号',
  `material_size_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` varchar(255) DEFAULT NULL COMMENT '用量',
  `create_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `create_at` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=18104 DEFAULT CHARSET=utf8mb3 COMMENT='生产订单型体部位各码总用量明细变更表';


--
-- Table structure for table `od_product_order_order_position_size_dosage`
--

DROP TABLE IF EXISTS `od_product_order_order_position_size_dosage`;


CREATE TABLE `od_product_order_order_position_size_dosage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_prod_order_seq` int DEFAULT NULL COMMENT '生产订单表序号',
  `od_prod_order_order_seq` int DEFAULT NULL COMMENT '生产订单正式订单关联关系表序号',
  `product_order_order_position_size_seq` int DEFAULT NULL COMMENT '生产订单型体部位尺码表序号',
  `product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单型体部位表序号',
  `product_order_order_size_seq` int DEFAULT NULL COMMENT '生产订单型体size序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体size序号',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码序号',
  `material_size_name` text COMMENT '物料名称',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` varchar(255) DEFAULT NULL COMMENT '用量',
  `is_deleted` int DEFAULT '0' COMMENT '系统删除标识（0：正常数据；1：已删除）',
  PRIMARY KEY (`seq`),
  KEY `product_order_order_position_seq` (`product_order_order_position_seq`),
  KEY `product_order_order_size_seq` (`product_order_order_size_seq`),
  KEY `product_order_order_position_size_seq` (`product_order_order_position_size_seq`),
  KEY `idx_pd_order_key_position` (`od_prod_order_seq`,`key`,`product_order_order_position_seq`),
  KEY `idx_od_prod_order_seq_key` (`od_prod_order_seq`,`key`),
  KEY `idx_product_order_position_seq` (`product_order_order_position_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2469619 DEFAULT CHARSET=utf8mb3 COMMENT='生产订单型体部位各码总用量明细';


--
-- Table structure for table `od_product_order_order_size`
--

DROP TABLE IF EXISTS `od_product_order_order_size`;


CREATE TABLE `od_product_order_order_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_product_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `od_product_order_order_seq` int DEFAULT NULL COMMENT '生产订单-正式订单-关联表序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体尺码序号',
  `size_seq` int DEFAULT NULL COMMENT '正式订单尺码序号（order_art_size_seq）',
  `size_code` varchar(50) DEFAULT NULL COMMENT 'size编码',
  `size_name` varchar(50) DEFAULT NULL COMMENT 'size名称',
  `prod_size_num` varchar(50) DEFAULT NULL COMMENT '生产订单数量',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `enable` int DEFAULT '1' COMMENT '是否启用（0：未启用；1：已启用）',
  PRIMARY KEY (`seq`),
  KEY `od_product_order_order_seq` (`od_product_order_order_seq`),
  KEY `idx_od_product_order_seq` (`od_product_order_seq`),
  KEY `idx_size_code` (`size_code`)
) ENGINE=InnoDB AUTO_INCREMENT=28171 DEFAULT CHARSET=utf8mb3 COMMENT='生产订单-正式订单型体各size数量';


--
-- Temporary view structure for view `od_product_order_view`
--

DROP TABLE IF EXISTS `od_product_order_view`;
/*!50001 DROP VIEW IF EXISTS `od_product_order_view`*/;
SET @saved_cs_client     = @@character_set_client;

/*!50001 CREATE VIEW `od_product_order_view` AS SELECT 
 1 AS `customer_article_code`,
 1 AS `sku`,
 1 AS `art_color_name`,
 1 AS `material_category_code`,
 1 AS `size_name`,
 1 AS `size_code`,
 1 AS `each_expend`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ods_mac`
--

DROP TABLE IF EXISTS `ods_mac`;


CREATE TABLE `ods_mac` (
  `mac_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'MAC_ID',
  `mac_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_NAME',
  `mac_date` datetime(3) DEFAULT NULL COMMENT 'MAC_DATE',
  `mac_sts_l` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_STS_L',
  `mac_sts_r` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_STS_R',
  `mac_opert` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'MAC_OPERT',
  `mac_cus` bigint DEFAULT NULL COMMENT 'MAC_CUS',
  `mac_type` bigint DEFAULT NULL COMMENT 'MAC_TYPE',
  `mac_speed_l` decimal(30,6) DEFAULT NULL COMMENT 'MAC_SPEED_L',
  `mac_speed_r` decimal(30,6) DEFAULT NULL COMMENT 'MAC_SPEED_R',
  `mac_output` bigint DEFAULT NULL COMMENT 'MAC_OUTPUT',
  `mac_ie_ratio` decimal(8,2) DEFAULT NULL COMMENT 'MAC_IE_RATIO',
  PRIMARY KEY (`mac_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `ods_seam_equip`
--

DROP TABLE IF EXISTS `ods_seam_equip`;


CREATE TABLE `ods_seam_equip` (
  `id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '主键',
  `create_by` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_time` datetime(3) DEFAULT NULL COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_time` datetime(3) DEFAULT NULL COMMENT '更新日期',
  `sys_org_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '所属部门',
  `equip_no` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备编号',
  `equip_type` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备型号',
  `equip_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备名称',
  `equip_address` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备地址',
  `main_soft_ver` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '主版本',
  `panel_soft_ver` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '显示屏版本',
  `servo_soft_ver` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '主轴版本',
  `equip_group_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '设备组名称',
  `card_number` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '卡号',
  `state` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '状态',
  `equip_group_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '组名',
  `screen_version` bigint DEFAULT NULL COMMENT '屏幕版本',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `om_aritcle_size`
--

DROP TABLE IF EXISTS `om_aritcle_size`;


CREATE TABLE `om_aritcle_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '型体尺存序号',
  `article_seq` int NOT NULL COMMENT '型体表序号',
  `size_seq` int DEFAULT NULL COMMENT 'size序号',
  `size_code` varchar(50) DEFAULT NULL,
  `no` int DEFAULT NULL,
  `size_name` varchar(50) DEFAULT NULL,
  `group_name` varchar(50) DEFAULT NULL,
  `product_bar_code` varchar(50) DEFAULT NULL COMMENT '产品条码(客户产品类别获取)',
  `is_standard_code` char(1) DEFAULT NULL COMMENT '是否基本码',
  `is_quotation` int DEFAULT NULL COMMENT '是否已报价 0未报价  1已报价',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `dna_id` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `article_seq` (`article_seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=324909 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体大小';


--
-- Table structure for table `om_aritcle_size_dna`
--

DROP TABLE IF EXISTS `om_aritcle_size_dna`;


CREATE TABLE `om_aritcle_size_dna` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '型体尺存序号',
  `article_seq` int NOT NULL COMMENT '型体表序号',
  `size_seq` int DEFAULT NULL COMMENT 'size序号',
  `size_code` varchar(50) DEFAULT NULL,
  `no` int DEFAULT NULL,
  `size_name` varchar(50) DEFAULT NULL,
  `group_name` varchar(50) DEFAULT NULL,
  `product_bar_code` varchar(50) DEFAULT NULL COMMENT '产品条码(客户产品类别获取)',
  `is_standard_code` char(1) DEFAULT NULL COMMENT '是否基本码',
  `is_quotation` int DEFAULT NULL COMMENT '是否已报价 0未报价  1已报价',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `dna_id` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `article_seq` (`article_seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5175 DEFAULT CHARSET=utf8mb3 COMMENT='型体大小';


--
-- Table structure for table `om_art_position`
--

DROP TABLE IF EXISTS `om_art_position`;


CREATE TABLE `om_art_position` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `no` int DEFAULT NULL COMMENT '顺序号',
  `art_seq` int DEFAULT NULL COMMENT '型体seq',
  `is_lock` int DEFAULT '0' COMMENT '是否锁定',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编号',
  `position_type` varchar(255) DEFAULT NULL COMMENT '部位分类',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `material_type_seq` int DEFAULT NULL COMMENT '部位物料分类序号',
  `material_type_name` varchar(255) DEFAULT NULL COMMENT '部位物料类型',
  `process_seq` int DEFAULT NULL COMMENT '制程seq',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` text COMMENT '物料简码名称',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料简码单位序号',
  `material_category_unit_name` varchar(255) DEFAULT NULL COMMENT '物料简码单位名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_infoIs_match_size` varchar(100) DEFAULT '0' COMMENT '物料是否配码',
  `material_infoIs_each_expend` varchar(100) DEFAULT '0' COMMENT '物料是否码段用量',
  `material_infoIs_out_sourcing` varchar(100) DEFAULT '0' COMMENT '物料是否外加工',
  `is_craft` int DEFAULT '0' COMMENT '是否工艺',
  `ie_name` varchar(500) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `base_each_expend` int DEFAULT NULL COMMENT '物料基本码用量',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` text COMMENT '备注',
  `loss_rate` decimal(10,2) DEFAULT NULL COMMENT '损耗率',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_confirm` int DEFAULT NULL COMMENT '是否确认',
  `dna_id` int DEFAULT NULL,
  `error_message` varchar(500) DEFAULT NULL COMMENT '校验失败原因',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `art_seq` (`art_seq`),
  KEY `no_art_seq` (`art_seq`,`no`)
) ENGINE=InnoDB AUTO_INCREMENT=89084 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体部位-物料简码信息';


--
-- Table structure for table `om_art_position_dna`
--

DROP TABLE IF EXISTS `om_art_position_dna`;


CREATE TABLE `om_art_position_dna` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `no` int DEFAULT NULL COMMENT '顺序号',
  `art_seq` int DEFAULT NULL COMMENT '型体seq',
  `is_lock` int DEFAULT '0' COMMENT '是否锁定',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编号',
  `position_type` varchar(255) DEFAULT NULL COMMENT '部位分类',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `material_type_seq` int DEFAULT NULL COMMENT '部位物料分类序号',
  `material_type_name` varchar(255) DEFAULT NULL COMMENT '部位物料类型',
  `process_seq` int DEFAULT NULL COMMENT '制程seq',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` text COMMENT '物料简码名称',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料简码单位序号',
  `material_category_unit_name` varchar(255) DEFAULT NULL COMMENT '物料简码单位名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_infoIs_match_size` varchar(100) DEFAULT '0' COMMENT '物料是否配码',
  `material_infoIs_each_expend` varchar(100) DEFAULT '0' COMMENT '物料是否码段用量',
  `material_infoIs_out_sourcing` varchar(100) DEFAULT '0' COMMENT '物料是否外加工',
  `is_craft` int DEFAULT '0' COMMENT '是否工艺',
  `ie_name` varchar(500) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `base_each_expend` int DEFAULT NULL COMMENT '物料基本码用量',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` text COMMENT '备注',
  `loss_rate` decimal(10,2) DEFAULT NULL COMMENT '损耗率',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_confirm` int DEFAULT NULL COMMENT '是否确认',
  `dna_id` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `art_seq` (`art_seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=17697 DEFAULT CHARSET=utf8mb3 COMMENT='型体部位-物料简码信息';


--
-- Table structure for table `om_art_position_dosage`
--

DROP TABLE IF EXISTS `om_art_position_dosage`;


CREATE TABLE `om_art_position_dosage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `art_seq` int DEFAULT NULL COMMENT '型体序号',
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位物料序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体size序号',
  `parent_seq` int DEFAULT NULL COMMENT '父级材料seq',
  `material_no` int DEFAULT NULL COMMENT '子材料顺序号',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码序号',
  `material_size_name` varchar(255) DEFAULT NULL COMMENT '物料尺码名称',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` decimal(20,4) DEFAULT NULL COMMENT '用量',
  PRIMARY KEY (`seq`),
  KEY `art_seq` (`art_seq`),
  KEY `art_position_seq` (`art_position_seq`),
  KEY `art_seq_2` (`art_seq`,`art_position_seq`,`parent_seq`,`key`)
) ENGINE=InnoDB AUTO_INCREMENT=1217060 DEFAULT CHARSET=utf8mb3 COMMENT='型体部位各码用量明细';


--
-- Table structure for table `om_art_position_dosage_snapshot`
--

DROP TABLE IF EXISTS `om_art_position_dosage_snapshot`;


CREATE TABLE `om_art_position_dosage_snapshot` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `business_id` int DEFAULT NULL COMMENT '生成业务ID',
  `art_seq` int DEFAULT NULL COMMENT '型体序号',
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位物料序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体size序号',
  `parent_seq` int DEFAULT NULL COMMENT '父级材料seq',
  `material_no` int DEFAULT NULL COMMENT '子材料顺序号',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码序号',
  `material_size_name` varchar(255) DEFAULT NULL COMMENT '物料尺码名称',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` decimal(20,4) DEFAULT NULL COMMENT '用量',
  `snapshot_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '快照时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=79366 DEFAULT CHARSET=utf8mb3 COMMENT='型体部位各码用量明细(用于产品资料变更保存原始数据)';


--
-- Table structure for table `om_art_position_ie`
--

DROP TABLE IF EXISTS `om_art_position_ie`;


CREATE TABLE `om_art_position_ie` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `art_seq` int DEFAULT NULL COMMENT '型体序号',
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位序号',
  `ie_code` varchar(255) DEFAULT NULL COMMENT '工艺编码',
  `ie_name` varchar(500) DEFAULT NULL COMMENT '工艺名称',
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=137825 DEFAULT CHARSET=utf8mb3 COMMENT='部位工艺信息';


--
-- Table structure for table `om_art_position_material`
--

DROP TABLE IF EXISTS `om_art_position_material`;


CREATE TABLE `om_art_position_material` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `art_seq` int DEFAULT NULL COMMENT '型体seq',
  `art_post_seq` int DEFAULT NULL COMMENT '型体部位序号',
  `no` int DEFAULT NULL,
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `parent_seq` int DEFAULT NULL COMMENT '物料父级seq',
  `material_category_name` text COMMENT '物料简码名称',
  `is_quotation` int DEFAULT '0' COMMENT '是否询价',
  `is_inquire` int DEFAULT '0' COMMENT '是否询价（0：否;1：是）',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `base_each_expend` decimal(11,4) DEFAULT NULL COMMENT '当前物料单耗（(单耗=1*A1单耗)：1*子材料单耗*子材料单耗*...）\r\nA(外加工材料,单耗1)\r\nA1(单耗=1*A1单耗)\r\nA11(单耗=1*A1单耗*A11单耗)\r\nA12(单耗=1*A1单耗*A12单耗)\r\nA2(单耗=1*A2单耗)',
  `each_expend` decimal(11,4) DEFAULT '1.0000' COMMENT '单耗',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `material_no` int DEFAULT NULL COMMENT '子材料顺序号',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_infoIs_match_size` varchar(100) DEFAULT NULL COMMENT '物料是否配码',
  `material_infoIs_each_expend` varchar(100) DEFAULT NULL COMMENT '物料是否码段用量',
  `material_infoIs_out_sourcing` varchar(100) DEFAULT NULL COMMENT '物料是否外加工',
  `ie_name` varchar(500) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `is_color` int NOT NULL DEFAULT '0' COMMENT '是否固色',
  `is_size` int NOT NULL DEFAULT '0' COMMENT '是否固码',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` text COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `art_post_seq` (`art_post_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=1347733 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体部位-物料明细';


--
-- Table structure for table `om_art_position_material_copy`
--

DROP TABLE IF EXISTS `om_art_position_material_copy`;


CREATE TABLE `om_art_position_material_copy` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `art_seq` int DEFAULT NULL COMMENT '型体seq',
  `art_post_seq` int DEFAULT NULL COMMENT '型体部位序号',
  `no` int DEFAULT NULL,
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `parent_seq` int DEFAULT NULL COMMENT '物料父级seq',
  `material_category_name` text COMMENT '物料简码名称',
  `is_quotation` int DEFAULT '0' COMMENT '是否询价',
  `is_inquire` int DEFAULT '0' COMMENT '是否询价（0：否;1：是）',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `base_each_expend` decimal(11,4) DEFAULT NULL COMMENT '当前物料单耗（(单耗=1*A1单耗)：1*子材料单耗*子材料单耗*...）\r\nA(外加工材料,单耗1)\r\nA1(单耗=1*A1单耗)\r\nA11(单耗=1*A1单耗*A11单耗)\r\nA12(单耗=1*A1单耗*A12单耗)\r\nA2(单耗=1*A2单耗)',
  `each_expend` decimal(11,4) DEFAULT '1.0000' COMMENT '单耗',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `material_no` int DEFAULT NULL COMMENT '子材料顺序号',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_infoIs_match_size` varchar(100) DEFAULT NULL COMMENT '物料是否配码',
  `material_infoIs_each_expend` varchar(100) DEFAULT NULL COMMENT '物料是否码段用量',
  `material_infoIs_out_sourcing` varchar(100) DEFAULT NULL COMMENT '物料是否外加工',
  `ie_name` varchar(500) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `is_color` int NOT NULL DEFAULT '0' COMMENT '是否固色',
  `is_size` int NOT NULL DEFAULT '0' COMMENT '是否固码',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` text COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `art_post_seq` (`art_post_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=1300990 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体部位-物料明细';


--
-- Table structure for table `om_art_position_material_snapshot`
--

DROP TABLE IF EXISTS `om_art_position_material_snapshot`;


CREATE TABLE `om_art_position_material_snapshot` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `business_id` int DEFAULT NULL COMMENT '生成业务ID',
  `art_seq` int DEFAULT NULL COMMENT '型体seq',
  `art_post_seq` int DEFAULT NULL COMMENT '型体部位序号',
  `parent_seq` int DEFAULT NULL COMMENT '物料父级seq',
  `is_quotation` int DEFAULT '0' COMMENT '是否询价',
  `is_inquire` int DEFAULT '0' COMMENT '是否询价（0：否;1：是）',
  `no` int DEFAULT NULL,
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `base_each_expend` decimal(11,4) DEFAULT NULL COMMENT '当前物料单耗（(单耗=1*A1单耗)：1*子材料单耗*子材料单耗*...）\nA(外加工材料,单耗1)\nA1(单耗=1*A1单耗)\nA11(单耗=1*A1单耗*A11单耗)\nA12(单耗=1*A1单耗*A12单耗)\nA2(单耗=1*A2单耗)',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` text COMMENT '物料简码名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `material_no` int DEFAULT NULL COMMENT '子材料顺序号',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_infoIs_match_size` varchar(100) DEFAULT NULL COMMENT '物料是否配码',
  `material_infoIs_each_expend` varchar(100) DEFAULT NULL COMMENT '物料是否码段用量',
  `material_infoIs_out_sourcing` varchar(100) DEFAULT NULL COMMENT '物料是否外加工',
  `ie_name` varchar(255) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` text COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `snapshot_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '快照时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=87619 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体部位-物料明细(用于产品资料变更保存原始数据)';


--
-- Table structure for table `om_art_position_size`
--

DROP TABLE IF EXISTS `om_art_position_size`;


CREATE TABLE `om_art_position_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `art_seq` int DEFAULT NULL,
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位',
  `art_size_seq` int DEFAULT NULL COMMENT '型体size',
  `position_seq` int DEFAULT NULL COMMENT '部位序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `size` varchar(255) DEFAULT NULL COMMENT '实际尺码',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=337454 DEFAULT CHARSET=utf8mb3 COMMENT='型体部位size（当部位物料需要配码时才会有数据）';


--
-- Table structure for table `om_art_position_size_snapshot`
--

DROP TABLE IF EXISTS `om_art_position_size_snapshot`;


CREATE TABLE `om_art_position_size_snapshot` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `business_id` int DEFAULT NULL COMMENT '生成业务ID',
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位',
  `art_size_seq` int DEFAULT NULL COMMENT '型体size',
  `position_seq` int DEFAULT NULL COMMENT '部位序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `size` varchar(255) DEFAULT NULL COMMENT '实际尺码',
  `snapshot_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '快照时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2481 DEFAULT CHARSET=utf8mb3 COMMENT='型体部位size（当部位物料需要配码时才会有数据）';


--
-- Table structure for table `om_art_position_snapshot`
--

DROP TABLE IF EXISTS `om_art_position_snapshot`;


CREATE TABLE `om_art_position_snapshot` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `business_id` int DEFAULT NULL COMMENT '生成业务ID',
  `no` int DEFAULT NULL COMMENT '顺序号',
  `art_seq` int DEFAULT NULL COMMENT '型体seq',
  `is_lock` int DEFAULT '0' COMMENT '是否锁定',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编号',
  `position_type` varchar(255) DEFAULT NULL COMMENT '部位分类',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `material_type_seq` int DEFAULT NULL,
  `material_type_name` varchar(255) DEFAULT NULL,
  `process_seq` int DEFAULT NULL COMMENT '制程seq',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` text COMMENT '物料简码名称',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料简码单位序号',
  `material_category_unit_name` varchar(255) DEFAULT NULL COMMENT '物料简码单位名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_infoIs_match_size` varchar(100) DEFAULT '0' COMMENT '物料是否配码',
  `material_infoIs_each_expend` varchar(100) DEFAULT '0' COMMENT '物料是否码段用量',
  `material_infoIs_out_sourcing` varchar(100) DEFAULT '0' COMMENT '物料是否外加工',
  `is_craft` int DEFAULT '0' COMMENT '是否工艺',
  `ie_name` varchar(255) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `base_each_expend` int DEFAULT NULL COMMENT '物料基本码用量',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` text COMMENT '备注',
  `loss_rate` decimal(10,2) DEFAULT NULL COMMENT '损耗率',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `snapshot_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '快照时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=4005 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体部位-物料简码信息(用于产品资料变更保存原始数据)';


--
-- Table structure for table `om_art_properties`
--

DROP TABLE IF EXISTS `om_art_properties`;


CREATE TABLE `om_art_properties` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `art_seq` int DEFAULT NULL,
  `properties_key` varchar(255) DEFAULT NULL COMMENT '属性Key',
  `properties_name` varchar(255) DEFAULT NULL COMMENT '属性名',
  `properties_value` varchar(255) DEFAULT NULL COMMENT '属性value',
  `type` varchar(255) DEFAULT NULL COMMENT '属性类型',
  `is_query` varchar(255) DEFAULT NULL COMMENT '是否可查询',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=8243 DEFAULT CHARSET=utf8mb3 COMMENT='型体拓展属性表';


--
-- Table structure for table `om_art_properties_snapshot`
--

DROP TABLE IF EXISTS `om_art_properties_snapshot`;


CREATE TABLE `om_art_properties_snapshot` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `business_id` int DEFAULT NULL COMMENT '生成业务ID',
  `art_seq` int DEFAULT NULL,
  `properties_key` varchar(255) DEFAULT NULL COMMENT '属性Key',
  `properties_name` varchar(255) DEFAULT NULL COMMENT '属性名',
  `properties_value` varchar(255) DEFAULT NULL COMMENT '属性value',
  `type` varchar(255) DEFAULT NULL COMMENT '属性类型',
  `is_query` varchar(255) DEFAULT NULL COMMENT '是否可查询',
  `snapshot_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '快照时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COMMENT='型体拓展属性表（当部位物料需要配码时才会有数据）';


--
-- Table structure for table `om_art_update_info`
--

DROP TABLE IF EXISTS `om_art_update_info`;


CREATE TABLE `om_art_update_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `art_seq` int DEFAULT NULL COMMENT '新型体序号',
  `art_code` int DEFAULT NULL COMMENT '原型体序号',
  `art_info_code` int DEFAULT NULL COMMENT '型体详情序号',
  `field_name` varchar(255) DEFAULT NULL COMMENT '字段名称',
  `old_value` varchar(255) DEFAULT NULL COMMENT '原始值',
  `new_value` varchar(255) DEFAULT NULL COMMENT '新值',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=112691 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体变更信息记录';


--
-- Table structure for table `om_art_update_info_snapshot`
--

DROP TABLE IF EXISTS `om_art_update_info_snapshot`;


CREATE TABLE `om_art_update_info_snapshot` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `business_id` int DEFAULT NULL COMMENT '生成业务ID',
  `art_seq` int DEFAULT NULL COMMENT '新型体序号',
  `art_code` int DEFAULT NULL COMMENT '原型体序号',
  `art_info_code` int DEFAULT NULL COMMENT '型体详情序号',
  `field_name` varchar(255) DEFAULT NULL COMMENT '字段名称',
  `old_value` varchar(255) DEFAULT NULL COMMENT '原始值',
  `new_value` varchar(255) DEFAULT NULL COMMENT '新值',
  `snapshot_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '快照时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=11068 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体变更信息记录（当部位物料需要配码时才会有数据）';


--
-- Table structure for table `om_article`
--

DROP TABLE IF EXISTS `om_article`;


CREATE TABLE `om_article` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `origin_sku` varchar(255) DEFAULT NULL COMMENT '原始型体数据sku值',
  `sku_logo` int DEFAULT NULL COMMENT 'sku主图片',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '所属工厂序号',
  `supplier_name` varchar(30) DEFAULT NULL,
  `original_code` varchar(30) DEFAULT NULL COMMENT '原始型体编号\r\n（当型体为新创建时，该字段为空\r\n   当型体为型体更新时，为原始型体编号\r\n    当型体为复制新增时，为复制形体号）',
  `code` varchar(30) DEFAULT NULL COMMENT '工厂型体编号',
  `name` varchar(50) DEFAULT NULL COMMENT '型体名称',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `customer_article_name` varchar(255) DEFAULT NULL COMMENT '客户型体名称',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `color` int DEFAULT NULL COMMENT '颜色序号',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `product_class_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `om_size_seq` int DEFAULT NULL COMMENT '尺码模板序号',
  `om_size_name` varchar(255) DEFAULT NULL COMMENT '尺码模板名称',
  `basic_size_seq` varchar(255) DEFAULT NULL COMMENT '基本码序号',
  `basic_size_code` varchar(255) DEFAULT NULL COMMENT '基本码',
  `accounting_code` varchar(255) DEFAULT NULL COMMENT '报价码',
  `size_range` varchar(50) DEFAULT NULL COMMENT '码段',
  `sex` int DEFAULT NULL COMMENT '样鞋性别（字典表seq）',
  `inner_cavity_height` varchar(255) DEFAULT NULL COMMENT 'IDS内腔长度',
  `heel_height` varchar(255) DEFAULT NULL COMMENT '后跟高度',
  `waist_height` varchar(255) DEFAULT NULL COMMENT '外腰高度',
  `inner_waist_height` varchar(255) DEFAULT NULL COMMENT '内腰高度',
  `vamp_length` varchar(255) DEFAULT NULL COMMENT '鞋头长度',
  `vamp_height` varchar(255) DEFAULT NULL COMMENT '鞋头高度',
  `collar_inside_height` varchar(255) DEFAULT NULL COMMENT '领口内高度',
  `collar_outside_height` varchar(255) DEFAULT NULL COMMENT '领口外高度',
  `last_code` varchar(255) DEFAULT NULL COMMENT '楦头代号',
  `outside_code` varchar(30) DEFAULT NULL COMMENT '大底代号',
  `cutter_cod` varchar(30) DEFAULT NULL COMMENT '刀模编号',
  `face_material_seq` int DEFAULT NULL COMMENT '帮面材质seq',
  `face_material_name` varchar(50) DEFAULT NULL COMMENT '帮面材质',
  `implement_standard` varchar(255) DEFAULT NULL COMMENT '国家执行标准',
  `country_bar_code` varchar(255) DEFAULT NULL COMMENT '国家条码',
  `sample_stage_seq` varchar(255) DEFAULT NULL COMMENT '样品阶段id',
  `sample_stage_name` varchar(255) DEFAULT NULL COMMENT '样品阶段名称',
  `is_inquire` int DEFAULT '0' COMMENT '是否完成询价（0：否；1：是）',
  `is_many_each_expend` int DEFAULT NULL COMMENT '是否多码段级放',
  `version` varchar(255) DEFAULT NULL COMMENT '版本号',
  `status` varchar(3) DEFAULT NULL COMMENT '状态\r\n0:草稿\r\n10：待审核\r\n11：撤回\r\n12：审核中\r\n13：驳回\r\n20：审核通过\r\n\r\n40: \r\n401:用量维护中\r\n1: 草稿\r\n30：用量维护待处理',
  `way` varchar(50) DEFAULT NULL COMMENT '方式',
  `article_seq` text COMMENT '关联型体seq(关联型体seq值，用“,”隔开，便于查询关联型体信息)',
  `memo` varchar(255) DEFAULT NULL COMMENT '型体说明',
  `tag_price` decimal(10,2) DEFAULT NULL COMMENT '吊牌价',
  `loss_rate` decimal(10,2) DEFAULT NULL COMMENT '损耗率',
  `origin_seq` int DEFAULT NULL COMMENT '原始型体seq(为型体申请变更记录原seq)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否有效',
  `dosage_created_by` varchar(255) DEFAULT NULL,
  `dosage_created_name` varchar(255) DEFAULT NULL,
  `dosage_created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_name` varchar(255) DEFAULT NULL COMMENT '创建人昵称',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `dna_id` int DEFAULT NULL,
  `sample_number` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `customer_seq` (`customer_seq`) USING BTREE,
  KEY `idx_sku_art` (`sku`,`seq`,`customer_article_code`,`quarter_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1543 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产品资料';


--
-- Table structure for table `om_article_20250805`
--

DROP TABLE IF EXISTS `om_article_20250805`;


CREATE TABLE `om_article_20250805` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `origin_sku` varchar(255) DEFAULT NULL COMMENT '原始型体数据sku值',
  `sku_logo` int DEFAULT NULL COMMENT 'sku主图片',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '所属工厂序号',
  `supplier_name` varchar(30) DEFAULT NULL,
  `original_code` varchar(30) DEFAULT NULL COMMENT '原始型体编号\r\n（当型体为新创建时，该字段为空\r\n   当型体为型体更新时，为原始型体编号\r\n    当型体为复制新增时，为复制形体号）',
  `code` varchar(30) DEFAULT NULL COMMENT '工厂型体编号',
  `name` varchar(50) DEFAULT NULL COMMENT '型体名称',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `customer_article_name` varchar(255) DEFAULT NULL COMMENT '客户型体名称',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `color` int DEFAULT NULL COMMENT '颜色序号',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `product_class_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `om_size_seq` int DEFAULT NULL COMMENT '尺码模板序号',
  `om_size_name` varchar(255) DEFAULT NULL COMMENT '尺码模板名称',
  `basic_size_seq` varchar(255) DEFAULT NULL COMMENT '基本码序号',
  `basic_size_code` varchar(255) DEFAULT NULL COMMENT '基本码',
  `accounting_code` varchar(255) DEFAULT NULL COMMENT '报价码',
  `size_range` varchar(50) DEFAULT NULL COMMENT '码段',
  `sex` int DEFAULT NULL COMMENT '样鞋性别（字典表seq）',
  `inner_cavity_height` varchar(255) DEFAULT NULL COMMENT 'IDS内腔长度',
  `heel_height` varchar(255) DEFAULT NULL COMMENT '后跟高度',
  `waist_height` varchar(255) DEFAULT NULL COMMENT '外腰高度',
  `inner_waist_height` varchar(255) DEFAULT NULL COMMENT '内腰高度',
  `vamp_length` varchar(255) DEFAULT NULL COMMENT '鞋头长度',
  `vamp_height` varchar(255) DEFAULT NULL COMMENT '鞋头高度',
  `collar_inside_height` varchar(255) DEFAULT NULL COMMENT '领口内高度',
  `collar_outside_height` varchar(255) DEFAULT NULL COMMENT '领口外高度',
  `last_code` varchar(255) DEFAULT NULL COMMENT '楦头代号',
  `outside_code` varchar(30) DEFAULT NULL COMMENT '大底代号',
  `cutter_cod` varchar(30) DEFAULT NULL COMMENT '刀模编号',
  `face_material_seq` int DEFAULT NULL COMMENT '帮面材质seq',
  `face_material_name` varchar(50) DEFAULT NULL COMMENT '帮面材质',
  `implement_standard` varchar(255) DEFAULT NULL COMMENT '国家执行标准',
  `country_bar_code` varchar(255) DEFAULT NULL COMMENT '国家条码',
  `sample_stage_seq` varchar(255) DEFAULT NULL COMMENT '样品阶段id',
  `sample_stage_name` varchar(255) DEFAULT NULL COMMENT '样品阶段名称',
  `is_inquire` int DEFAULT '0' COMMENT '是否完成询价（0：否；1：是）',
  `is_many_each_expend` int DEFAULT NULL COMMENT '是否多码段级放',
  `version` varchar(255) DEFAULT NULL COMMENT '版本号',
  `status` varchar(3) DEFAULT NULL COMMENT '状态\r\n0:草稿\r\n10：待审核\r\n11：撤回\r\n12：审核中\r\n13：驳回\r\n20：审核通过\r\n\r\n40: \r\n401:用量维护中\r\n1: 草稿\r\n30：用量维护待处理',
  `way` varchar(50) DEFAULT NULL COMMENT '方式',
  `article_seq` text COMMENT '关联型体seq(关联型体seq值，用“,”隔开，便于查询关联型体信息)',
  `memo` varchar(255) DEFAULT NULL COMMENT '型体说明',
  `tag_price` decimal(10,2) DEFAULT NULL COMMENT '吊牌价',
  `loss_rate` decimal(10,2) DEFAULT NULL COMMENT '损耗率',
  `origin_seq` int DEFAULT NULL COMMENT '原始型体seq(为型体申请变更记录原seq)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否有效',
  `dosage_created_by` varchar(255) DEFAULT NULL,
  `dosage_created_name` varchar(255) DEFAULT NULL,
  `dosage_created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_name` varchar(255) DEFAULT NULL COMMENT '创建人昵称',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `dna_id` int DEFAULT NULL,
  `sample_number` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `customer_seq` (`customer_seq`) USING BTREE,
  KEY `idx_sku_art` (`sku`,`seq`,`customer_article_code`,`quarter_code`)
) ENGINE=InnoDB AUTO_INCREMENT=899 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产品资料';


--
-- Table structure for table `om_article_change_record`
--

DROP TABLE IF EXISTS `om_article_change_record`;


CREATE TABLE `om_article_change_record` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `change_no` varchar(32) NOT NULL COMMENT '变更单号',
  `art_seq` int NOT NULL COMMENT '待更改的型体seq',
  `sku` varchar(100) DEFAULT NULL COMMENT '更改sku',
  `new_art_seq` int DEFAULT NULL COMMENT '新增的型体seq',
  `customer_seq` int DEFAULT NULL COMMENT '客户id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `product_class_seq` int DEFAULT NULL COMMENT '产品类型seq',
  `product_class_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `apply_reason` varchar(50) DEFAULT NULL COMMENT '变更原因',
  `status` int NOT NULL COMMENT '状态（27-作废）',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `active` int NOT NULL DEFAULT '1' COMMENT '数据有效标识 1有效 0删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `created_name` varchar(100) DEFAULT NULL COMMENT '创建人昵称',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体申请更改记录';


--
-- Table structure for table `om_article_dna`
--

DROP TABLE IF EXISTS `om_article_dna`;


CREATE TABLE `om_article_dna` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `origin_sku` varchar(255) DEFAULT NULL COMMENT '原始型体数据sku值',
  `sku_logo` int DEFAULT NULL COMMENT 'sku主图片',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '所属工厂序号',
  `supplier_name` varchar(30) DEFAULT NULL,
  `original_code` varchar(30) DEFAULT NULL COMMENT '原始型体编号\r\n（当型体为新创建时，该字段为空\r\n   当型体为型体更新时，为原始型体编号\r\n    当型体为复制新增时，为复制形体号）',
  `code` varchar(30) DEFAULT NULL COMMENT '工厂型体编号',
  `name` varchar(50) DEFAULT NULL COMMENT '型体名称',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `customer_article_name` varchar(255) DEFAULT NULL COMMENT '客户型体名称',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `color` int DEFAULT NULL COMMENT '颜色序号',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `product_class_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `om_size_seq` int DEFAULT NULL COMMENT '尺码模板序号',
  `om_size_name` varchar(255) DEFAULT NULL COMMENT '尺码模板名称',
  `basic_size_seq` varchar(255) DEFAULT NULL COMMENT '基本码序号',
  `basic_size_code` varchar(255) DEFAULT NULL COMMENT '基本码',
  `accounting_code` varchar(255) DEFAULT NULL COMMENT '报价码',
  `size_range` varchar(50) DEFAULT NULL COMMENT '码段',
  `sex` int DEFAULT NULL COMMENT '样鞋性别（字典表seq）',
  `inner_cavity_height` varchar(255) DEFAULT NULL COMMENT 'IDS内腔长度',
  `heel_height` varchar(255) DEFAULT NULL COMMENT '后跟高度',
  `waist_height` varchar(255) DEFAULT NULL COMMENT '外腰高度',
  `inner_waist_height` varchar(255) DEFAULT NULL COMMENT '内腰高度',
  `vamp_length` varchar(255) DEFAULT NULL COMMENT '鞋头长度',
  `vamp_height` varchar(255) DEFAULT NULL COMMENT '鞋头高度',
  `collar_inside_height` varchar(255) DEFAULT NULL COMMENT '领口内高度',
  `collar_outside_height` varchar(255) DEFAULT NULL COMMENT '领口外高度',
  `last_code` varchar(255) DEFAULT NULL COMMENT '楦头代号',
  `outside_code` varchar(30) DEFAULT NULL COMMENT '大底代号',
  `cutter_cod` varchar(30) DEFAULT NULL COMMENT '刀模编号',
  `face_material_seq` int DEFAULT NULL COMMENT '帮面材质seq',
  `face_material_name` varchar(50) DEFAULT NULL COMMENT '帮面材质',
  `implement_standard` varchar(255) DEFAULT NULL COMMENT '国家执行标准',
  `country_bar_code` varchar(255) DEFAULT NULL COMMENT '国家条码',
  `sample_stage_seq` varchar(255) DEFAULT NULL COMMENT '样品阶段id',
  `sample_stage_name` varchar(255) DEFAULT NULL COMMENT '样品阶段名称',
  `is_inquire` int DEFAULT '0' COMMENT '是否完成询价（0：否；1：是）',
  `is_many_each_expend` int DEFAULT NULL COMMENT '是否多码段级放',
  `version` varchar(255) DEFAULT NULL COMMENT '版本号',
  `status` varchar(3) DEFAULT NULL COMMENT '状态\r\n0:草稿\r\n10：待审核\r\n11：撤回\r\n12：审核中\r\n13：驳回\r\n20：审核通过\r\n\r\n40: \r\n401:用量维护中\r\n1: 草稿\r\n30：用量维护待处理',
  `way` varchar(50) DEFAULT NULL COMMENT '方式',
  `article_seq` text COMMENT '关联型体seq(关联型体seq值，用“,”隔开，便于查询关联型体信息)',
  `memo` varchar(255) DEFAULT NULL COMMENT '型体说明',
  `tag_price` decimal(10,2) DEFAULT NULL COMMENT '吊牌价',
  `loss_rate` decimal(10,2) DEFAULT NULL COMMENT '损耗率',
  `origin_seq` int DEFAULT NULL COMMENT '原始型体seq(为型体申请变更记录原seq)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否有效',
  `dosage_created_by` varchar(255) DEFAULT NULL,
  `dosage_created_name` varchar(255) DEFAULT NULL,
  `dosage_created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_name` varchar(255) DEFAULT NULL COMMENT '创建人昵称',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `dna_id` int DEFAULT NULL,
  `sample_number` int DEFAULT NULL,
  `is_handle` int DEFAULT '0' COMMENT '是否已经处理 1是0否',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `customer_seq` (`customer_seq`) USING BTREE,
  KEY `idx_sku_art` (`sku`,`seq`,`customer_article_code`,`quarter_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=342 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产品资料_dna';


--
-- Table structure for table `om_article_position_material_change`
--

DROP TABLE IF EXISTS `om_article_position_material_change`;


CREATE TABLE `om_article_position_material_change` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `change_record_seq` int NOT NULL COMMENT '形体变更记录seq',
  `no` int DEFAULT NULL COMMENT '顺序号',
  `art_seq` int NOT NULL COMMENT '待更改的型体seq',
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位-物料简码信息seq',
  `om_art_position_material_seq` int DEFAULT NULL COMMENT '型体部位-物料明细 seq',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_type` varchar(20) DEFAULT NULL COMMENT '部位分类',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `process_seq` int DEFAULT NULL COMMENT '制程主键',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料简码名称',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料简码单位序号',
  `material_category_unit_name` varchar(255) DEFAULT NULL COMMENT '物料简码单位名称',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料code',
  `material_info_colour` varchar(50) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_type_seq` int DEFAULT NULL COMMENT '部位物料分类序号',
  `material_type_name` varchar(255) DEFAULT NULL COMMENT '部位物料类型',
  `group_seq` int DEFAULT NULL COMMENT '分组序号',
  `group_name` varchar(255) DEFAULT NULL COMMENT '分组名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` decimal(10,4) DEFAULT NULL COMMENT '级放比率',
  `grading_count` int DEFAULT NULL COMMENT '级放数量',
  `material_info_is_match_size` int DEFAULT NULL COMMENT '材料是否配码 1是 0否',
  `material_info_is_each_expend` int DEFAULT NULL COMMENT '是否码段用量 1是 0否',
  `material_info_is_out_sourcing` int DEFAULT NULL COMMENT '物料是否外加工',
  `loss_rate` decimal(10,2) DEFAULT NULL COMMENT '损耗率',
  `is_new_data` int NOT NULL COMMENT '是否为新增数据 1是 0否',
  `is_craft` int DEFAULT NULL COMMENT '是否工艺 1是 0否',
  `ie_name` varchar(255) DEFAULT NULL COMMENT '工艺名称',
  `status` int NOT NULL COMMENT '状态 0未修改,1修改，2删除 3新增',
  `change_type` int DEFAULT NULL COMMENT '变更类型 1.仅变更用量 2.变更数据明细',
  `change_remark` varchar(100) DEFAULT NULL COMMENT '变更详情备注',
  `dosage_info` text COMMENT '用量信息数据',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=627 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体物料部位待变更数据';


--
-- Table structure for table `om_article_pro_order_change`
--

DROP TABLE IF EXISTS `om_article_pro_order_change`;


CREATE TABLE `om_article_pro_order_change` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `change_record_seq` int NOT NULL COMMENT '形体变更记录seq',
  `product_code` varchar(255) DEFAULT NULL COMMENT '生产订单单号',
  `row_no` varchar(100) DEFAULT NULL COMMENT '订单行标识',
  `art_seq` int NOT NULL COMMENT '待更改的型体seq',
  `status` int NOT NULL COMMENT '状态 0未变更 1已变更',
  `pro_order_seq` int NOT NULL COMMENT '需要变更的生产订单seq',
  `manual_prod_code` text COMMENT '手工排产单号',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2238 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体生产订单待变更数据';


--
-- Table structure for table `om_article_size_snapshot`
--

DROP TABLE IF EXISTS `om_article_size_snapshot`;


CREATE TABLE `om_article_size_snapshot` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '型体尺存序号',
  `business_id` int DEFAULT NULL COMMENT '生成业务Id',
  `article_seq` int NOT NULL COMMENT '型体表序号',
  `size_seq` int DEFAULT NULL COMMENT 'size序号',
  `size_code` varchar(50) DEFAULT NULL,
  `no` int DEFAULT NULL,
  `size_name` varchar(50) DEFAULT NULL,
  `group_name` varchar(50) DEFAULT NULL,
  `product_bar_code` varchar(50) DEFAULT NULL COMMENT '产品条码(客户产品类别获取)',
  `is_standard_code` char(1) DEFAULT NULL COMMENT '是否基本码',
  `is_quotation` int DEFAULT NULL COMMENT '是否已报价 0未报价  1已报价',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `snapshot_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '快照时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=1089 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='型体大小(用于产品资料变更保存原始数据)';


--
-- Table structure for table `om_article_snapshot`
--

DROP TABLE IF EXISTS `om_article_snapshot`;


CREATE TABLE `om_article_snapshot` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `business_id` int DEFAULT NULL COMMENT '生成业务ID',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `sku_logo` int DEFAULT NULL COMMENT 'sku主图片',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '所属工厂序号',
  `supplier_name` varchar(30) DEFAULT NULL,
  `original_code` varchar(30) DEFAULT NULL COMMENT '原始型体编号\n（当型体为新创建时，该字段为空\n   当型体为型体更新时，为原始型体编号\n    当型体为复制新增时，为复制形体号）',
  `code` varchar(30) DEFAULT NULL COMMENT '工厂型体编号',
  `name` varchar(50) DEFAULT NULL COMMENT '型体名称',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `customer_article_name` varchar(255) DEFAULT NULL COMMENT '客户型体名称',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `color` int DEFAULT NULL COMMENT '颜色序号',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `product_class_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `om_size_seq` int DEFAULT NULL COMMENT '尺码模板序号',
  `om_size_name` varchar(255) DEFAULT NULL COMMENT '尺码模板名称',
  `basic_size_seq` varchar(255) DEFAULT NULL COMMENT '基本码序号',
  `basic_size_code` varchar(255) DEFAULT NULL COMMENT '基本码',
  `size_range` varchar(50) DEFAULT NULL COMMENT '码段',
  `sex` int DEFAULT NULL COMMENT '样鞋性别（字典表seq）',
  `inner_cavity_height` varchar(255) DEFAULT NULL COMMENT 'IDS内腔长度',
  `heel_height` varchar(255) DEFAULT NULL COMMENT '后跟高度',
  `waist_height` varchar(255) DEFAULT NULL COMMENT '外腰高度',
  `inner_waist_height` varchar(255) DEFAULT NULL COMMENT '内腰高度',
  `vamp_length` varchar(255) DEFAULT NULL COMMENT '鞋头长度',
  `vamp_height` varchar(255) DEFAULT NULL COMMENT '鞋头高度',
  `collar_inside_height` varchar(255) DEFAULT NULL COMMENT '领口内高度',
  `collar_outside_height` varchar(255) DEFAULT NULL COMMENT '领口外高度',
  `last_code` varchar(255) DEFAULT NULL COMMENT '楦头代号',
  `outside_code` varchar(30) DEFAULT NULL COMMENT '大底代号',
  `cutter_cod` varchar(30) DEFAULT NULL COMMENT '刀模编号',
  `face_material_seq` int DEFAULT NULL COMMENT '帮面材质seq',
  `face_material_name` varchar(50) DEFAULT NULL COMMENT '帮面材质',
  `implement_standard` varchar(255) DEFAULT NULL COMMENT '国家执行标准',
  `country_bar_code` varchar(255) DEFAULT NULL COMMENT '国家条码',
  `sample_stage_seq` varchar(255) DEFAULT NULL COMMENT '样品阶段id',
  `sample_stage_name` varchar(255) DEFAULT NULL COMMENT '样品阶段名称',
  `is_inquire` int DEFAULT '0' COMMENT '是否完成询价（0：否；1：是）',
  `is_many_each_expend` int DEFAULT NULL COMMENT '是否多码段级放',
  `version` varchar(255) DEFAULT NULL COMMENT '版本号',
  `status` varchar(3) DEFAULT NULL COMMENT '状态\n0:草稿\n10：待审核\n11：撤回\n12：审核中\n13：驳回\n20：审核通过\n',
  `way` varchar(50) DEFAULT NULL COMMENT '方式',
  `article_seq` text COMMENT '关联型体seq(关联型体seq值，用“,”隔开，便于查询关联型体信息)',
  `memo` varchar(255) DEFAULT NULL COMMENT '型体说明',
  `tag_price` decimal(10,2) DEFAULT NULL COMMENT '吊牌价',
  `loss_rate` decimal(10,2) DEFAULT NULL COMMENT '损耗率',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否有效',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `snapshot_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '快照时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产品资料快照(用于产品资料变更保存原始数据)';


--
-- Table structure for table `om_colour`
--

DROP TABLE IF EXISTS `om_colour`;


CREATE TABLE `om_colour` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `code` varchar(255) DEFAULT NULL COMMENT '编号',
  `memo` text COMMENT '描述',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `update_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_name` varchar(255) DEFAULT NULL COMMENT '创建人',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='颜色模版';


--
-- Table structure for table `om_colour_info`
--

DROP TABLE IF EXISTS `om_colour_info`;


CREATE TABLE `om_colour_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `om_colour_seq` int DEFAULT NULL COMMENT '颜色模版seq',
  `level` varchar(50) DEFAULT NULL COMMENT '色系',
  `type` int DEFAULT NULL COMMENT '颜色类型zseq',
  `code` varchar(255) DEFAULT NULL COMMENT '编号',
  `name` varchar(500) DEFAULT NULL COMMENT '名称',
  `data_source` varchar(255) DEFAULT NULL,
  `memo` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_used` int DEFAULT '0' COMMENT '是否使用',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否生效',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `update_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `created_name` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `omColor_idx` (`type`,`name`),
  KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=31228 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='颜色库';


--
-- Table structure for table `om_colour_info_20250521`
--

DROP TABLE IF EXISTS `om_colour_info_20250521`;


CREATE TABLE `om_colour_info_20250521` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '序号',
  `om_colour_seq` int DEFAULT NULL COMMENT '颜色模版seq',
  `level` varchar(50) DEFAULT NULL COMMENT '色系',
  `type` int DEFAULT NULL COMMENT '颜色类型zseq',
  `code` varchar(255) DEFAULT NULL COMMENT '编号',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  `data_source` varchar(255) DEFAULT NULL,
  `memo` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_used` int DEFAULT '0' COMMENT '是否使用',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否生效',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `update_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `om_colour_info_tmp`
--

DROP TABLE IF EXISTS `om_colour_info_tmp`;


CREATE TABLE `om_colour_info_tmp` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '序号',
  `om_colour_seq` int DEFAULT NULL COMMENT '颜色模版seq',
  `level` varchar(50) DEFAULT NULL COMMENT '色系',
  `type` int DEFAULT NULL COMMENT '颜色类型zseq',
  `code` varchar(255) DEFAULT NULL COMMENT '编号',
  `name` varchar(500) DEFAULT NULL COMMENT '名称',
  `data_source` varchar(255) DEFAULT NULL,
  `memo` varchar(50) DEFAULT NULL COMMENT '备注',
  `is_used` int DEFAULT '0' COMMENT '是否使用',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '1' COMMENT '是否生效',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `update_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `om_pack_bom_size`
--

DROP TABLE IF EXISTS `om_pack_bom_size`;


CREATE TABLE `om_pack_bom_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '型体尺存序号',
  `pack_bom_seq` int NOT NULL COMMENT '型体表序号',
  `size_seq` int DEFAULT NULL COMMENT 'size序号',
  `size_code` varchar(50) DEFAULT NULL,
  `no` int DEFAULT NULL,
  `size_name` varchar(50) DEFAULT NULL,
  `group_name` varchar(50) DEFAULT NULL,
  `product_bar_code` varchar(50) DEFAULT NULL COMMENT '产品条码(客户产品类别获取)',
  `is_standard_code` char(1) DEFAULT NULL COMMENT '是否基本码',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `pack_bom_seq` (`pack_bom_seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3787 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='包材库大小';


--
-- Table structure for table `om_package_bom`
--

DROP TABLE IF EXISTS `om_package_bom`;


CREATE TABLE `om_package_bom` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `origin_seq` int DEFAULT NULL COMMENT '引用变更的原始包材库seq',
  `code` varchar(255) DEFAULT NULL COMMENT '包材库编码',
  `name` varchar(255) DEFAULT NULL COMMENT '包材库名称',
  `loss_rate` decimal(10,4) DEFAULT NULL,
  `om_size_seq` int DEFAULT NULL COMMENT '尺码模板',
  `om_size_name` varchar(100) DEFAULT NULL COMMENT '尺码模板名称',
  `basic_size_seq` int DEFAULT NULL COMMENT '基本码序号',
  `om_basic_size_code` varchar(50) DEFAULT NULL COMMENT '基本码',
  `is_many_each_expend` int DEFAULT NULL COMMENT '是否多玛段',
  `om_basic_size_range` varchar(50) DEFAULT NULL COMMENT '码段',
  `quarter_code` int DEFAULT NULL COMMENT '季度编号',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `brand_seq` int DEFAULT NULL COMMENT '产品类别Seq',
  `brand_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `version` varchar(255) DEFAULT NULL COMMENT '版本',
  `status` varchar(3) DEFAULT NULL COMMENT '状态',
  `queue_status` int NOT NULL DEFAULT '1' COMMENT '数据队列状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `enable` int DEFAULT '0' COMMENT '是否可用',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_name` varchar(100) DEFAULT NULL COMMENT '创建人昵称',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=119 DEFAULT CHARSET=utf8mb3 COMMENT='国家包材库';


--
-- Table structure for table `om_package_bom_change_record`
--

DROP TABLE IF EXISTS `om_package_bom_change_record`;


CREATE TABLE `om_package_bom_change_record` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `change_no` varchar(32) NOT NULL COMMENT '变更单号',
  `package_seq` int NOT NULL COMMENT '待更改的包材seq',
  `code` varchar(255) DEFAULT NULL COMMENT '包材库编码',
  `name` varchar(255) DEFAULT NULL COMMENT '包材库名称',
  `new_package_seq` int DEFAULT NULL COMMENT '新增的包材seq',
  `om_size_name` varchar(100) DEFAULT NULL COMMENT '尺码模板名称',
  `apply_reason` varchar(50) DEFAULT NULL COMMENT '变更原因',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `package_version` varchar(20) DEFAULT NULL COMMENT '包材版本号',
  `status` int DEFAULT NULL COMMENT '状态',
  `data_status` varchar(3) DEFAULT NULL COMMENT '数据流转状态',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `active` int NOT NULL DEFAULT '1' COMMENT '数据有效标识 1有效 0删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `created_name` varchar(100) DEFAULT NULL COMMENT '创建人昵称',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COMMENT='包材库变更记录';


--
-- Table structure for table `om_package_bom_dosage`
--

DROP TABLE IF EXISTS `om_package_bom_dosage`;


CREATE TABLE `om_package_bom_dosage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `back_size_seq` int DEFAULT NULL COMMENT '型体size序号',
  `parent_seq` int DEFAULT NULL,
  `pack_bom_seq` int DEFAULT NULL COMMENT '型体序号',
  `position_seq` int DEFAULT NULL COMMENT '部件',
  `position_code` varchar(100) DEFAULT NULL COMMENT '部件code',
  `position_name` varchar(200) DEFAULT NULL COMMENT '部件名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码',
  `material_category_code` varchar(200) DEFAULT NULL,
  `material_category_name` varchar(200) DEFAULT NULL,
  `package_bom_info_seq` int DEFAULT NULL COMMENT '包装BOMseq',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码序号',
  `material_size_name` varchar(255) DEFAULT NULL COMMENT '物料尺码名称',
  `loss_rate` decimal(10,4) DEFAULT NULL COMMENT '损耗率',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` decimal(20,4) DEFAULT NULL COMMENT '用量',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=35243 DEFAULT CHARSET=utf8mb3 COMMENT='包材明细各码用量明细';


--
-- Table structure for table `om_package_bom_info`
--

DROP TABLE IF EXISTS `om_package_bom_info`;


CREATE TABLE `om_package_bom_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `uid` varchar(42) DEFAULT NULL,
  `no` int DEFAULT NULL COMMENT '顺序号',
  `pack_bom_seq` int DEFAULT NULL COMMENT '包材库序号',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `process_seq` int DEFAULT NULL COMMENT '制程seq',
  `loss_rate` decimal(10,4) DEFAULT NULL,
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料简码名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_infoIs_match_size` varchar(100) DEFAULT NULL COMMENT '物料是否配码',
  `material_infoIs_each_expend` varchar(100) DEFAULT NULL COMMENT '物料是否码段用量',
  `material_infoIs_out_sourcing` varchar(100) DEFAULT NULL COMMENT '物料是否外加工',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位seq',
  `material_category_unit_name` varchar(20) DEFAULT NULL COMMENT '物料单位名称',
  `is_craft` int DEFAULT NULL COMMENT '是否工艺',
  `ie_name` varchar(255) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `base_each_expend` int DEFAULT NULL COMMENT '物料基本码用量',
  `old_package_name` varchar(100) DEFAULT NULL COMMENT '旧包材库名称',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `is_effective` int DEFAULT '1' COMMENT '是否有效',
  `version` varchar(200) DEFAULT NULL COMMENT '版本号',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2695 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='国家包材库明细';


--
-- Table structure for table `om_package_bom_info_change_record`
--

DROP TABLE IF EXISTS `om_package_bom_info_change_record`;


CREATE TABLE `om_package_bom_info_change_record` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `change_record_seq` int NOT NULL COMMENT '变更记录seq ',
  `uid` varchar(42) DEFAULT NULL,
  `no` int DEFAULT NULL COMMENT '顺序号',
  `pack_bom_seq` int DEFAULT NULL COMMENT '包材库序号',
  `package_name` varchar(100) DEFAULT NULL COMMENT '包材库名称',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `process_seq` int DEFAULT NULL COMMENT '制程seq',
  `loss_rate` decimal(10,4) DEFAULT NULL,
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料简码名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_infoIs_match_size` int DEFAULT NULL COMMENT '物料是否配码',
  `material_infoIs_each_expend` int DEFAULT NULL COMMENT '物料是否码段用量',
  `material_infoIs_out_sourcing` int DEFAULT NULL COMMENT '物料是否外加工',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位seq',
  `material_category_unit_name` varchar(20) DEFAULT NULL COMMENT '物料单位名称',
  `is_craft` int DEFAULT NULL COMMENT '是否工艺',
  `ie_name` varchar(255) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` decimal(12,2) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` decimal(10,2) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `base_each_expend` int DEFAULT NULL COMMENT '物料基本码用量',
  `is_new_data` int NOT NULL COMMENT '是否是新数据 旧数据仅做展示 1是 0否',
  `status` int NOT NULL COMMENT '操作状态 0未修改,1修改，2删除 3新增',
  `change_type` int DEFAULT NULL COMMENT '更改类型 1 变更用量  2变更数据',
  `change_remark` varchar(200) DEFAULT NULL COMMENT '变更备注',
  `dosage_info` text COMMENT '用量信息数据',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='包材库部位变更明细';


--
-- Table structure for table `om_package_bom_info_material`
--

DROP TABLE IF EXISTS `om_package_bom_info_material`;


CREATE TABLE `om_package_bom_info_material` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `pack_bom_seq` int DEFAULT NULL COMMENT '型体seq',
  `pack_bom_info_seq` int DEFAULT NULL COMMENT '型体部位序号',
  `parent_seq` int DEFAULT NULL COMMENT '物料父级seq',
  `no` int DEFAULT NULL,
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `base_each_expend` decimal(11,4) DEFAULT NULL COMMENT '当前物料单耗（(单耗=1*A1单耗)：1*子材料单耗*子材料单耗*...）\r\nA(外加工材料,单耗1)\r\nA1(单耗=1*A1单耗)\r\nA11(单耗=1*A1单耗*A11单耗)\r\nA12(单耗=1*A1单耗*A12单耗)\r\nA2(单耗=1*A2单耗)',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` text COMMENT '物料简码名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型seq',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_size` varchar(100) DEFAULT NULL COMMENT '物料编码size',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料编码颜色名称',
  `material_infoIs_match_size` varchar(100) DEFAULT NULL COMMENT '物料是否配码',
  `material_infoIs_each_expend` varchar(100) DEFAULT NULL COMMENT '物料是否码段用量',
  `material_infoIs_out_sourcing` varchar(100) DEFAULT NULL COMMENT '物料是否外加工',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位seq',
  `material_category_unit_name` varchar(20) DEFAULT NULL COMMENT '物料单位名称',
  `ie_name` varchar(255) DEFAULT NULL COMMENT '工艺名称',
  `grading_type_seq` int DEFAULT NULL COMMENT '物料单位级放类型seq',
  `grading_type_name` varchar(100) DEFAULT NULL COMMENT '物料单位级放类型',
  `grading_rate` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放比率',
  `grading_count` varchar(100) DEFAULT NULL COMMENT '产品类别级放类型级放数量',
  `brand_name` varchar(50) DEFAULT NULL COMMENT '产品类别',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `memo` text COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=35534 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='包材部位-物料明细';


--
-- Table structure for table `om_package_bom_info_size`
--

DROP TABLE IF EXISTS `om_package_bom_info_size`;


CREATE TABLE `om_package_bom_info_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `pack_bom_info_seq` int DEFAULT NULL COMMENT '型体部位',
  `is_effective` int DEFAULT '1' COMMENT '是否有效',
  `version` varchar(200) DEFAULT NULL COMMENT '版本号',
  `pack_size_seq` int DEFAULT NULL COMMENT '型体size',
  `position_seq` int DEFAULT NULL COMMENT '部位序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `size` varchar(255) DEFAULT NULL COMMENT '实际尺码',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1734 DEFAULT CHARSET=utf8mb3 COMMENT='包材库size';


--
-- Table structure for table `om_package_bom_order_po_change`
--

DROP TABLE IF EXISTS `om_package_bom_order_po_change`;


CREATE TABLE `om_package_bom_order_po_change` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `change_record_seq` int NOT NULL COMMENT '包材变更记录seq',
  `order_article_seq` int NOT NULL COMMENT '订单行标识Seq',
  `row_no` varchar(255) NOT NULL COMMENT '行标识',
  `sku` varchar(100) DEFAULT NULL COMMENT 'sku',
  `destination` varchar(100) DEFAULT NULL COMMENT '目的地',
  `color_name` varchar(100) DEFAULT NULL COMMENT 'sku颜色',
  `customer_code` varchar(200) DEFAULT NULL COMMENT '客人订单号',
  `status` int NOT NULL COMMENT '状态 0未变更 1已变更',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='包材库订单行变更数据';


--
-- Table structure for table `om_size`
--

DROP TABLE IF EXISTS `om_size`;


CREATE TABLE `om_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `is_many_each_expend` int DEFAULT '0' COMMENT '是否多码段',
  `memo` text COMMENT '描述',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `update_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='尺码size模版 ';


--
-- Table structure for table `om_size_info`
--

DROP TABLE IF EXISTS `om_size_info`;


CREATE TABLE `om_size_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `om_size_seq` int DEFAULT NULL COMMENT 'size模版seq',
  `no` int DEFAULT NULL COMMENT '顺序号',
  `code` varchar(255) DEFAULT NULL COMMENT 'size码号',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `size_group` varchar(50) DEFAULT NULL COMMENT '尺码组',
  `is_base_size` int DEFAULT NULL COMMENT '是否基本码',
  `is_deleted` int DEFAULT NULL COMMENT '是否删除',
  `enable` int DEFAULT NULL,
  `memo` text COMMENT '描述',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `update_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `om_size_seq` (`no`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3186 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='尺码size类别';


--
-- Table structure for table `om_size_properties`
--

DROP TABLE IF EXISTS `om_size_properties`;


CREATE TABLE `om_size_properties` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `om_size_seq` int DEFAULT NULL COMMENT 'size类别表',
  `properties_key` varchar(50) DEFAULT NULL COMMENT '属性key',
  `properties_value` varchar(50) DEFAULT NULL COMMENT '属性value',
  `name` varchar(50) DEFAULT NULL COMMENT '属性名',
  `is_query` varchar(50) DEFAULT NULL COMMENT '是否可查询',
  `type` varchar(50) DEFAULT NULL COMMENT '属性类型',
  `is_deleted` char(1) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='size类别属性表';


--
-- Table structure for table `omp_sys_coding`
--

DROP TABLE IF EXISTS `omp_sys_coding`;


CREATE TABLE `omp_sys_coding` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code_property` varchar(100) DEFAULT NULL COMMENT '编码性质',
  `code_receipt` varchar(100) DEFAULT NULL COMMENT '编码单据',
  `code_business` varchar(100) DEFAULT NULL COMMENT '业务类型',
  `code_prifix` varchar(100) DEFAULT NULL COMMENT '前缀',
  `code_suffix` varchar(100) DEFAULT NULL COMMENT '后缀',
  `fill_chars` varchar(100) DEFAULT NULL COMMENT '补填字符',
  `fixed_length` char(1) DEFAULT NULL COMMENT '固定长度:0-否；1-是',
  `ordinal_length` varchar(100) DEFAULT NULL COMMENT '序号长度',
  `system_produce` char(1) DEFAULT NULL COMMENT '系统产生:0-否；1-是',
  `is_con_number` char(1) DEFAULT NULL COMMENT '是否连号:0-否；1-是',
  `example

_code` varchar(150) DEFAULT NULL COMMENT '示例编码',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除:0-否；1-是',
  `created_by` varchar(100) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(100) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(100) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='编码规则';


--
-- Table structure for table `omp_sys_coding_info`
--

DROP TABLE IF EXISTS `omp_sys_coding_info`;


CREATE TABLE `omp_sys_coding_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `sys_coding_seq` int DEFAULT NULL COMMENT '编码规则外键',
  `key` varchar(100) DEFAULT NULL COMMENT '属性',
  `name` varchar(100) DEFAULT NULL COMMENT '属性名称',
  `field_length` varchar(100) DEFAULT NULL COMMENT '长度',
  `is_choose` char(1) DEFAULT NULL COMMENT '是否选择:0-否；1-是',
  `seat` int DEFAULT NULL COMMENT '位置排序',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除:0-否；1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='编码规则详情';


--
-- Table structure for table `output_feedback`
--

DROP TABLE IF EXISTS `output_feedback`;


CREATE TABLE `output_feedback` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `artrcle_seq` int DEFAULT NULL COMMENT '型体序号',
  `sample_order_seq` int DEFAULT NULL COMMENT '样品单号',
  `customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `name` varchar(255) DEFAULT NULL COMMENT '姓名',
  `process` varchar(255) DEFAULT NULL COMMENT '工序',
  `process_name` varchar(255) DEFAULT NULL COMMENT '工序名称',
  `size` double DEFAULT NULL COMMENT '尺码',
  `complete_time` timestamp NULL DEFAULT NULL COMMENT '完成日期',
  `is_delete` int DEFAULT '0' COMMENT '0：未删除  1：删除',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产能回馈';


--
-- Table structure for table `package_packing`
--

DROP TABLE IF EXISTS `package_packing`;


CREATE TABLE `package_packing` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `enable` int DEFAULT '1' COMMENT '是否可用\r\n变更过的单据为不可用（0）',
  `status` int DEFAULT NULL COMMENT '0：待处理\r\n10：草稿\r\n11：提交\r\n20：审批通过',
  `is_updated` int DEFAULT '0' COMMENT '是否已变更（1：是；0：否）',
  `id` int DEFAULT NULL COMMENT 'mes装箱单id',
  `zx_dh` varchar(255) DEFAULT NULL COMMENT '装箱单号',
  `po` varchar(255) DEFAULT NULL COMMENT 'po',
  `delivery_address` varchar(255) DEFAULT NULL COMMENT '收货地',
  `product_name` varchar(255) DEFAULT NULL COMMENT '产品名称',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `customer_order` varchar(255) DEFAULT NULL COMMENT '客户订单号',
  `season` varchar(255) DEFAULT NULL COMMENT '季节',
  `production_directives` varchar(255) DEFAULT NULL COMMENT '指令号',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `firm_id` int DEFAULT NULL COMMENT '公司Id',
  `firm_name` varchar(255) DEFAULT NULL COMMENT '公司',
  `warehouse_id` int DEFAULT NULL COMMENT '入库仓库id',
  `warehouse_name` varchar(255) DEFAULT NULL COMMENT '入库仓库',
  `warehouse_category` varchar(255) DEFAULT NULL COMMENT '入库仓库类别',
  `in_code` varchar(255) DEFAULT NULL COMMENT '入库单号',
  `cj_name` varchar(255) DEFAULT NULL,
  `cj_time` timestamp NULL DEFAULT NULL,
  `xg_name` varchar(255) DEFAULT NULL,
  `xg_time` timestamp NULL DEFAULT NULL,
  `art` varchar(255) DEFAULT NULL COMMENT '型体',
  `original_seq` int DEFAULT NULL COMMENT '原始序号',
  `created_by` varchar(255) DEFAULT NULL,
  `created_nick_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_nick_name` varchar(0) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 COMMENT='装箱单';


--
-- Table structure for table `package_packing_info`
--

DROP TABLE IF EXISTS `package_packing_info`;


CREATE TABLE `package_packing_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `package_packing_seq` int DEFAULT NULL COMMENT '装箱单序号',
  `no` int DEFAULT NULL,
  `id` varchar(200) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT '外箱条码',
  `cm` varchar(255) DEFAULT NULL COMMENT '包装尺寸',
  `packing_code` varchar(255) DEFAULT NULL COMMENT '箱号',
  `po` varchar(200) DEFAULT NULL COMMENT 'po',
  `art_colour` varchar(255) DEFAULT NULL COMMENT '型体颜色',
  `size_name` varchar(50) DEFAULT NULL COMMENT '尺码',
  `total` varchar(11) DEFAULT NULL COMMENT '总数量',
  `mkg` varchar(255) DEFAULT NULL COMMENT '总毛用量',
  `jkg` varchar(255) DEFAULT NULL COMMENT '总净用量',
  `way` varchar(255) DEFAULT NULL COMMENT '装箱方式',
  `position_seq` varchar(255) DEFAULT NULL COMMENT '部位序号',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `processing` varchar(255) DEFAULT NULL COMMENT '制程序号',
  `processing_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `material_category_seq` varchar(255) DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `material_category_unit_seq` varchar(255) DEFAULT NULL COMMENT '物料单位',
  `material_category_unit_name` varchar(255) DEFAULT NULL COMMENT '物料单位名称',
  `provider_seq` varchar(255) DEFAULT NULL COMMENT '物料供应商',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `provider_type_seq` varchar(255) DEFAULT NULL COMMENT '供方类型',
  `provider_type_name` varchar(255) DEFAULT NULL COMMENT '供方类型名称',
  `material_info_seq` varchar(255) DEFAULT NULL,
  `material_info_size` double DEFAULT NULL,
  `material_info_code` varchar(255) DEFAULT NULL,
  `material_info_colour` varchar(255) DEFAULT NULL,
  `material_info_colour_name` varchar(255) DEFAULT NULL,
  `material_info_is_match_size` double DEFAULT NULL,
  `material_info_is_each_expend` varchar(255) DEFAULT NULL,
  `material_info_is_out_sourcing` varchar(255) DEFAULT NULL,
  `is_craft` varchar(255) DEFAULT NULL,
  `ie_name` varchar(255) DEFAULT NULL,
  `memo` text,
  `is_updated` int DEFAULT '0' COMMENT '是否修改',
  `is_deleted` varchar(255) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` varchar(255) DEFAULT NULL,
  `updated_by` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_by` varchar(255) DEFAULT NULL,
  `deleted_at` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=1114 DEFAULT CHARSET=utf8mb3 COMMENT='装箱单明细';


--
-- Table structure for table `package_packing_size_info`
--

DROP TABLE IF EXISTS `package_packing_size_info`;


CREATE TABLE `package_packing_size_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `package_packing_seq` int DEFAULT NULL COMMENT '装箱单序号',
  `package_packing_info_seq` int DEFAULT NULL COMMENT '装箱单明细序号',
  `size_name` varchar(50) DEFAULT NULL COMMENT '尺码',
  `num` varchar(255) DEFAULT NULL COMMENT '数量',
  `mkg` varchar(255) DEFAULT NULL COMMENT '毛用量',
  `jkg` varchar(255) DEFAULT NULL COMMENT '净用量',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=1268 DEFAULT CHARSET=utf8mb3 COMMENT='装箱单明细尺码信息';


--
-- Table structure for table `package_packing_synchronize_records`
--

DROP TABLE IF EXISTS `package_packing_synchronize_records`;


CREATE TABLE `package_packing_synchronize_records` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `execute_at` timestamp NULL DEFAULT NULL COMMENT '执行时间',
  `start_time` timestamp NULL DEFAULT NULL COMMENT '数据时间范围起',
  `end_time` timestamp NULL DEFAULT NULL COMMENT '数据时间范围止',
  `operate_by` varchar(255) DEFAULT NULL COMMENT '执行人',
  `status` int DEFAULT '1' COMMENT '状态',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 COMMENT='装箱单数据同步记录';


--
-- Table structure for table `pdm_roll_store`
--

DROP TABLE IF EXISTS `pdm_roll_store`;


CREATE TABLE `pdm_roll_store` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `store_order_no` varchar(255) DEFAULT NULL COMMENT '转入单号',
  `busi_date` datetime DEFAULT NULL COMMENT '入库时间',
  `printing_frequency` int DEFAULT '0' COMMENT '打印次数',
  `printing_date` datetime DEFAULT NULL COMMENT '打印时间',
  `company_out_id` int NOT NULL COMMENT '转出工厂',
  `company_out_name` varchar(100) DEFAULT NULL COMMENT '转出工厂名称',
  `warehouse_out_id` int NOT NULL COMMENT '转出仓库id',
  `warehouse_out_name` varchar(50) NOT NULL COMMENT '转出仓库名称',
  `company_in_id` int NOT NULL COMMENT '转入工厂(公司)id',
  `company_in_name` varchar(100) NOT NULL COMMENT '转入工厂名称',
  `warehouse_in_id` int NOT NULL COMMENT '转入仓库id',
  `warehouse_in_name` varchar(50) DEFAULT NULL COMMENT '转入仓库名称',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `created_username` varchar(255) DEFAULT NULL COMMENT '创建人',
  `code` varchar(20) NOT NULL COMMENT '转仓出库单号',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COMMENT='转仓入库表';


--
-- Table structure for table `pdm_roll_store_info`
--

DROP TABLE IF EXISTS `pdm_roll_store_info`;


CREATE TABLE `pdm_roll_store_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `pdm_roll_store_seq` int DEFAULT NULL COMMENT '转仓入库表seq',
  `material_warehouse_out_info_seq` int DEFAULT NULL COMMENT '转出仓库明细id',
  `store_qty` decimal(11,4) DEFAULT NULL COMMENT '转入数量',
  `customer_seq` int NOT NULL COMMENT '客户Seq',
  `customer_name` varchar(100) NOT NULL COMMENT '客户名称',
  `prod_order_seq` int DEFAULT NULL COMMENT '生成订单seq',
  `prod_order_code` varchar(30) NOT NULL COMMENT '指令单号',
  `provider_seq` int NOT NULL COMMENT '供应商seq',
  `provider_name` varchar(100) NOT NULL COMMENT '供应商名称',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_info_seq` int NOT NULL COMMENT '物料编码主键',
  `material_info_code` varchar(100) NOT NULL COMMENT '物料编码',
  `material_name` text NOT NULL COMMENT '物料名称',
  `color_code` varchar(200) DEFAULT NULL COMMENT '颜色编码',
  `color_name` varchar(100) DEFAULT NULL COMMENT '物料颜色',
  `size_code` varchar(50) DEFAULT NULL COMMENT '物料尺码',
  `size_name` varchar(50) DEFAULT NULL COMMENT '尺码',
  `unit_seq` int NOT NULL COMMENT '物料单位seq',
  `unit_name` varchar(10) DEFAULT NULL COMMENT '物料单位',
  `location_code` varchar(100) DEFAULT NULL COMMENT '转出储位编号',
  `location_name` varchar(100) DEFAULT NULL COMMENT '转出储位名称',
  `sku` varchar(200) DEFAULT NULL COMMENT 'sku',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `quantity_to_be_transferred` decimal(14,4) DEFAULT '0.0000' COMMENT '待转数量',
  `position_seq` varchar(255) DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `manual_prod_code` varchar(255) DEFAULT NULL COMMENT '指令号',
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  `row_no` varchar(200) DEFAULT NULL COMMENT '行标识',
  `customer_article_code` varchar(200) DEFAULT NULL COMMENT '客户形体号',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COMMENT='转仓入库明细表';


--
-- Temporary view structure for view `pmli_all`
--

DROP TABLE IF EXISTS `pmli_all`;
/*!50001 DROP VIEW IF EXISTS `pmli_all`*/;
SET @saved_cs_client     = @@character_set_client;

/*!50001 CREATE VIEW `pmli_all` AS SELECT 
 1 AS `release_at`,
 1 AS `proc_material_list_code`,
 1 AS `total_purchase_quantity`,
 1 AS `remaining_quantity`,
 1 AS `created_by`,
 1 AS `position_name`,
 1 AS `mx_material_info_code`,
 1 AS `product_order_code`,
 1 AS `end_delivery_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `po_defective_product`
--

DROP TABLE IF EXISTS `po_defective_product`;


CREATE TABLE `po_defective_product` (
  `record_date` varchar(20) DEFAULT NULL COMMENT '日期',
  `firm_id` int DEFAULT NULL COMMENT '公司Id',
  `firm_name` varchar(50) DEFAULT NULL COMMENT '公司名称',
  `department_id` int DEFAULT NULL COMMENT '部门Id',
  `department_name` varchar(50) DEFAULT NULL COMMENT '部门名称',
  `group_id` int DEFAULT NULL COMMENT '组别Id',
  `group_name` varchar(50) DEFAULT NULL COMMENT '组别名称',
  `process` varchar(10) DEFAULT NULL COMMENT '制程名称',
  `check_num` double(13,2) DEFAULT NULL COMMENT '不良数量',
  `p_id` varchar(10) DEFAULT NULL COMMENT '制程代号',
  UNIQUE KEY `record_date` (`record_date`,`firm_id`,`department_id`,`group_id`,`p_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='品质不良数据';


--
-- Table structure for table `po_production_node`
--

DROP TABLE IF EXISTS `po_production_node`;


CREATE TABLE `po_production_node` (
  `po` varchar(50) DEFAULT NULL COMMENT 'po',
  `produce_code` varchar(100) DEFAULT NULL COMMENT '生产单号',
  `process` varchar(10) DEFAULT NULL COMMENT '制程名称',
  `section_name` varchar(10) DEFAULT NULL COMMENT '工段名称',
  `sequence` varchar(10) DEFAULT NULL COMMENT '工序顺序号',
  `node` varchar(50) DEFAULT NULL COMMENT '报产节点名称',
  `p_id` varchar(10) DEFAULT NULL COMMENT '制程代号',
  UNIQUE KEY `po` (`po`,`produce_code`,`process`,`section_name`,`sequence`,`node`,`p_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='报产节点基础资料数据';


--
-- Table structure for table `po_report_yie_id`
--

DROP TABLE IF EXISTS `po_report_yie_id`;


CREATE TABLE `po_report_yie_id` (
  `record_date` varchar(20) DEFAULT NULL COMMENT '日期',
  `po` varchar(50) DEFAULT NULL,
  `produce_code` varchar(100) DEFAULT NULL COMMENT '生产单号',
  `firm_id` int DEFAULT NULL COMMENT '公司Id',
  `firm_name` varchar(50) DEFAULT NULL COMMENT '公司名称',
  `p_id` varchar(10) DEFAULT NULL COMMENT '制程代号',
  `process` varchar(10) DEFAULT NULL COMMENT '制程名称',
  `section_name` varchar(10) DEFAULT NULL COMMENT '工段名称',
  `sequence` varchar(10) DEFAULT NULL COMMENT '工序顺序',
  `node` varchar(50) DEFAULT NULL COMMENT '工序名称',
  `order_year` varchar(10) DEFAULT NULL COMMENT '订单年份',
  `season` varchar(10) DEFAULT NULL COMMENT '订单季节',
  `dispatch_group_code` varchar(100) DEFAULT NULL COMMENT '组别派工单号',
  `dispatch_code` varchar(100) DEFAULT NULL COMMENT '员工派工单号',
  `size_name` varchar(13) DEFAULT NULL COMMENT '规格',
  `dis_num` double(13,2) DEFAULT NULL,
  `report_num` double(13,2) DEFAULT NULL,
  UNIQUE KEY `record_date` (`record_date`,`po`,`firm_id`,`p_id`,`node`,`dispatch_group_code`,`dispatch_code`,`size_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='MES-PO级 生产数据接口(时间段)';


--
-- Table structure for table `po_wms_info_data`
--

DROP TABLE IF EXISTS `po_wms_info_data`;


CREATE TABLE `po_wms_info_data` (
  `record_date` varchar(20) DEFAULT NULL COMMENT '日期',
  `po` varchar(50) DEFAULT NULL COMMENT 'po',
  `produce_code` varchar(100) DEFAULT NULL COMMENT '生产单号',
  `firm_id` int DEFAULT NULL COMMENT '公司Id',
  `firm_name` varchar(50) DEFAULT NULL COMMENT '公司名称',
  `p_id` varchar(10) DEFAULT NULL COMMENT '制程代号',
  `process` varchar(10) DEFAULT NULL COMMENT '制程名称',
  `section_name` varchar(10) DEFAULT NULL COMMENT '工段名称',
  `sequence` varchar(10) DEFAULT NULL COMMENT '工序顺序',
  `node` varchar(50) DEFAULT NULL COMMENT '工序名称',
  `order_year` varchar(10) DEFAULT NULL COMMENT '订单年份',
  `season` varchar(10) DEFAULT NULL COMMENT '订单季节',
  `size_name` varchar(5) DEFAULT NULL COMMENT '规格',
  `in_stock_num` double(13,2) DEFAULT NULL COMMENT '入库数量',
  `out_stock_num` double(13,2) DEFAULT NULL COMMENT '出库数量',
  `stock_num` double(13,2) DEFAULT NULL COMMENT '当日库存数量',
  UNIQUE KEY `record_date` (`record_date`,`po`,`produce_code`,`firm_id`,`p_id`,`section_name`,`node`,`size_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='MES-PO级仓库数据接口(时间段)';


--
-- Table structure for table `position`
--

DROP TABLE IF EXISTS `position`;


CREATE TABLE `position` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sys_dict_seq` int NOT NULL COMMENT '所属类',
  `no` int DEFAULT NULL COMMENT '排序',
  `id` varchar(255) DEFAULT NULL COMMENT '过滤值',
  `code` varchar(255) DEFAULT NULL COMMENT '代号',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  `name_en` varchar(255) DEFAULT NULL COMMENT '英文名称',
  `enable` varchar(50) DEFAULT '1' COMMENT '是否可用',
  `is_used` int DEFAULT '0' COMMENT '是否使用',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除',
  `processing` int DEFAULT NULL COMMENT '制程(制程维护)',
  `processing_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `material_type_seq` int DEFAULT NULL COMMENT '物料类型序号',
  `material_type_name` varchar(255) DEFAULT NULL COMMENT '物料类型名称',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5077 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='部位信息';


--
-- Table structure for table `position_20250520`
--

DROP TABLE IF EXISTS `position_20250520`;


CREATE TABLE `position_20250520` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '序号',
  `sys_dict_seq` int DEFAULT NULL COMMENT '所属类',
  `no` int DEFAULT NULL COMMENT '排序',
  `id` varchar(255) DEFAULT NULL COMMENT '过滤值',
  `code` varchar(255) DEFAULT NULL COMMENT '代号',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  `name_en` varchar(255) DEFAULT NULL COMMENT '英文名称',
  `enable` varchar(50) DEFAULT '1' COMMENT '是否可用',
  `is_used` int DEFAULT '0' COMMENT '是否使用',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除',
  `processing` int DEFAULT NULL COMMENT '制程(制程维护)',
  `processing_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `material_type_seq` int DEFAULT NULL COMMENT '物料类型序号',
  `material_type_name` varchar(255) DEFAULT NULL COMMENT '物料类型名称',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `proc_manual_warehouse_in`
--

DROP TABLE IF EXISTS `proc_manual_warehouse_in`;


CREATE TABLE `proc_manual_warehouse_in` (
  `seq` int unsigned NOT NULL AUTO_INCREMENT COMMENT '主键序列',
  `code` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '入库单号',
  `warehouse_in_type` int DEFAULT NULL COMMENT '入库类型',
  `warehouse_in_type_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '入库类型名称',
  `company_in_id` int DEFAULT NULL COMMENT '入库公司 ID',
  `company_in_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '入库公司名称',
  `warehouse_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '入库仓库编码',
  `warehouse_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '入库仓库名称',
  `warehouse_in_date` date DEFAULT NULL COMMENT '入库日期',
  `handle_user` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经办人',
  `apply_company_id` int DEFAULT NULL COMMENT '申请公司 ID',
  `apply_company_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '申请公司名称',
  `apply_department_id` int DEFAULT NULL COMMENT '申请部门ID',
  `apply_department_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '申请部门名称',
  `apply_workshop_id` int DEFAULT NULL COMMENT '车间小组',
  `apply_workshop_name` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '车间小组',
  `apply_provider_id` int DEFAULT NULL COMMENT '申请供应商 ID',
  `apply_provider_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '申请供应商名称',
  `status` int NOT NULL COMMENT '状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `submit_at` datetime DEFAULT NULL COMMENT '提交时间',
  `print_count` int NOT NULL DEFAULT '0' COMMENT '打印次数',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否删除（0-否，1-是）',
  `created_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '创建人',
  `created_by_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '创建人姓名',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`),
  UNIQUE KEY `idx_code_unique` (`code`),
  KEY `idx_company_in_id` (`company_in_id`),
  KEY `idx_warehouse_code` (`warehouse_code`),
  KEY `idx_warehouse_in_date` (`warehouse_in_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='手动入库单表';


--
-- Table structure for table `proc_manual_warehouse_in_info`
--

DROP TABLE IF EXISTS `proc_manual_warehouse_in_info`;


CREATE TABLE `proc_manual_warehouse_in_info` (
  `seq` int unsigned NOT NULL AUTO_INCREMENT COMMENT '主键序列',
  `manual_warehouse_in_id` int DEFAULT NULL COMMENT '入库单ID（关联主表）',
  `od_prod_order_position_seq` int DEFAULT NULL COMMENT '生产订单部位信息seq',
  `row_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '行标识',
  `manual_prod_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '指令号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `product_order_code` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生产订单号',
  `sku` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'sku',
  `customer_article_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '客户型体号',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '客户名称',
  `group_seq` int DEFAULT NULL COMMENT '物料分组id',
  `group_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物料分组名称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部位名称',
  `position_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部位编码',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `material_category_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物料名称',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '颜色code',
  `material_info_colour_name` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '材料颜色名称',
  `material_category_unit_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物料基本单位',
  `size` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '尺码',
  `warehouse_quantity_in` decimal(18,6) NOT NULL COMMENT '入库数量（不得大于申请数量）',
  `location_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '储位名称',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='手动入库单明细表';


--
-- Table structure for table `proc_manual_warehouse_out`
--

DROP TABLE IF EXISTS `proc_manual_warehouse_out`;


CREATE TABLE `proc_manual_warehouse_out` (
  `seq` int unsigned NOT NULL AUTO_INCREMENT COMMENT '主键序列',
  `code` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '出库单号',
  `warehouse_out_type` int DEFAULT NULL COMMENT '出库类型',
  `warehouse_out_type_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '出库类型名称',
  `issuing_company_id` int DEFAULT NULL COMMENT '发料公司 ID',
  `issuing_company_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '发料公司名称',
  `issuing_warehouse_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '发料仓库编码',
  `issuing_warehouse_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '发料仓库名称',
  `warehouse_out_date` date DEFAULT NULL COMMENT '出库日期',
  `handle_user` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经办人',
  `apply_company_id` int DEFAULT NULL COMMENT '申请公司 ID',
  `apply_company_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '申请公司名称',
  `apply_department_id` int DEFAULT NULL COMMENT '申请部门ID',
  `apply_department_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '申请部门名称',
  `apply_workshop_id` int DEFAULT NULL COMMENT '车间小组',
  `apply_workshop_name` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '车间小组',
  `apply_provider_id` int DEFAULT NULL COMMENT '申请供应商 ID',
  `apply_provider_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '申请供应商名称',
  `status` int NOT NULL COMMENT '状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `submit_at` datetime DEFAULT NULL COMMENT '提交时间',
  `print_count` int NOT NULL DEFAULT '0' COMMENT '打印次数',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否删除（0-否，1-是）',
  `created_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '创建人',
  `created_by_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '创建人姓名',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`),
  UNIQUE KEY `idx_code_unique` (`code`),
  KEY `idx_issuing_company_id` (`issuing_company_id`),
  KEY `idx_issuing_warehouse_code` (`issuing_warehouse_code`),
  KEY `idx_warehouse_out_date` (`warehouse_out_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='手动新增出库单';


--
-- Table structure for table `proc_manual_warehouse_out_info`
--

DROP TABLE IF EXISTS `proc_manual_warehouse_out_info`;


CREATE TABLE `proc_manual_warehouse_out_info` (
  `seq` int unsigned NOT NULL AUTO_INCREMENT COMMENT '主键序列',
  `manual_warehouse_out_id` int NOT NULL COMMENT '出库单ID（关联主表）',
  `store_id` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '库存Id',
  `row_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '行标识',
  `manual_prod_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '指令号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `product_order_code` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生产订单号',
  `sku` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'sku',
  `art_color_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '型体颜色',
  `customer_article_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '客户型体号',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '客户名称',
  `group_seq` int DEFAULT NULL COMMENT '物料分组id',
  `group_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物料分组名称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部位名称',
  `position_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部位编码',
  `material_category_seq` int NOT NULL COMMENT '物料简码seq',
  `material_category_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物料简码',
  `material_category_name` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物料名称',
  `material_info_seq` int NOT NULL COMMENT '物料编码seq',
  `material_info_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物料编码',
  `material_info_colour` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '颜色code',
  `material_info_colour_name` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '材料颜色名称',
  `material_category_unit_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物料基本单位',
  `size` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '尺码',
  `warehouse_quantity_out` decimal(18,6) NOT NULL COMMENT '出库数量（不得大于入库数量）',
  `location_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '储位编号',
  `location_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '储位名称',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='手动新增出库单明细表';


--
-- Table structure for table `proc_material_change_todo`
--

DROP TABLE IF EXISTS `proc_material_change_todo`;


CREATE TABLE `proc_material_change_todo` (
  `seq` int unsigned NOT NULL AUTO_INCREMENT COMMENT '主键序列',
  `change_code` varchar(30) NOT NULL COMMENT '变更单号（生产订单变更/包材变更）',
  `change_source` int NOT NULL COMMENT '变更来源',
  `change_record_seq` int DEFAULT NULL COMMENT '变更记录seq',
  `change_record_info_seq` int DEFAULT NULL COMMENT '变更明细记录seq',
  `business_type` int NOT NULL COMMENT '变更业务类型（1.原材料采购单；2.委外加工单）',
  `business_seq` int NOT NULL COMMENT '业务seq',
  `business_info_seq` int NOT NULL COMMENT '业务明细seq',
  `business_code` varchar(50) DEFAULT NULL COMMENT '业务单号',
  `sku` varchar(100) NOT NULL COMMENT 'sku',
  `customer_seq` int NOT NULL COMMENT '订单客户seq',
  `customer_name` varchar(255) NOT NULL COMMENT '订单客户名称',
  `company_id` int NOT NULL COMMENT '公司ID',
  `company_name` varchar(100) NOT NULL COMMENT '公司名称',
  `provider_seq` int NOT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) NOT NULL COMMENT '供应商名称',
  `procurement_seq` int NOT NULL COMMENT '采购需求Seq',
  `procurement_code` varchar(255) NOT NULL COMMENT '采购需求单号',
  `manual_prod_code` varchar(255) NOT NULL COMMENT '指令号',
  `prod_order_code` varchar(50) NOT NULL COMMENT '生产订单号',
  `row_no` varchar(255) NOT NULL COMMENT 'po',
  `quarter_code` varchar(255) DEFAULT NULL COMMENT '季度',
  `position_seq` int NOT NULL COMMENT '部件序号',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `material_category_seq` int NOT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料简码名称',
  `material_category_unit_seq` int DEFAULT NULL COMMENT '物料简码单位序号',
  `material_category_unit_name` varchar(255) DEFAULT NULL COMMENT '物料简码单位名称',
  `material_info_seq` int NOT NULL COMMENT '物料编码seq',
  `material_info_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour` varchar(255) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '物料编码颜色名称',
  `size` text COMMENT '尺码',
  `old_need_quantity` decimal(19,4) NOT NULL COMMENT '原需求数量',
  `old_procurement_quantity` decimal(19,4) NOT NULL COMMENT '原采购数量',
  `new_need_quantity` decimal(19,4) NOT NULL COMMENT '现需求数量',
  `new_procurement_quantity` decimal(19,4) NOT NULL COMMENT '现采购数量',
  `change_date` datetime NOT NULL COMMENT '变更日期',
  `change_by_user` varchar(255) NOT NULL COMMENT '变更人',
  `change_reason` varchar(255) DEFAULT NULL COMMENT '变更原因',
  `change_remark` varchar(255) DEFAULT NULL COMMENT '变更明细备注',
  `maintain_remark` varchar(255) DEFAULT NULL COMMENT '维持原单原因',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `status` int NOT NULL DEFAULT '0' COMMENT '确认状态（0未确认；1已确认；2维持原单）',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0未删除；1已删除）',
  `create_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '更新用户',
  `updated_user_id` varchar(255) DEFAULT NULL COMMENT '更新用户ID',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='采购变更待办表';


--
-- Table structure for table `proc_material_list`
--

DROP TABLE IF EXISTS `proc_material_list`;


CREATE TABLE `proc_material_list` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL COMMENT '采购单号',
  `procurement_type` varchar(255) DEFAULT NULL COMMENT '采购类型',
  `sum_price` varchar(12) DEFAULT NULL COMMENT '含税金额',
  `excluding_tax_price` varchar(12) DEFAULT NULL COMMENT '不含税金额',
  `tax_price` varchar(12) DEFAULT NULL COMMENT '税率',
  `mx_material_category_provider_seq` int DEFAULT NULL COMMENT '物料供应商',
  `mx_material_category_provider_name` varchar(100) DEFAULT NULL COMMENT '物料供应商',
  `payment_terms` varchar(255) DEFAULT NULL COMMENT '付款条件',
  `payment_method` varchar(255) DEFAULT NULL COMMENT '付款方式',
  `contract_currency` varchar(255) DEFAULT NULL COMMENT '合同币别',
  `supplier_contact_name` varchar(50) DEFAULT NULL COMMENT '供应商联系人姓名',
  `currency_rate` varchar(50) DEFAULT NULL COMMENT '币种汇率',
  `phone` varchar(50) DEFAULT NULL COMMENT '电话',
  `purchaser` varchar(50) DEFAULT NULL COMMENT '采购人信息',
  `receiving_company` varchar(50) DEFAULT NULL COMMENT '收料公司',
  `receiving_warehouse` varchar(50) DEFAULT NULL COMMENT '收料仓库',
  `receiving_contacts` varchar(50) DEFAULT NULL COMMENT '收料联系人',
  `invoice_contacts` varchar(50) DEFAULT NULL COMMENT '发票联系人',
  `demand_department` varchar(50) DEFAULT NULL COMMENT '需求部门',
  `receiving_address_abb` varchar(255) DEFAULT NULL COMMENT '收料地址简称',
  `receiving_contacts_phone` varchar(50) DEFAULT NULL COMMENT '收料联系人电话',
  `invoice_contacts_phone` varchar(50) DEFAULT NULL COMMENT '发票联系人电话',
  `purchase_date` datetime DEFAULT NULL COMMENT '采购日期',
  `invoice_address_abb` varchar(255) DEFAULT NULL COMMENT '发票地址简称',
  `current_account` varchar(255) DEFAULT NULL COMMENT '往来账户',
  `receiving_address` varchar(255) DEFAULT NULL COMMENT '收料地址',
  `invoice_address` varchar(255) DEFAULT NULL COMMENT '发票地址',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `contract_text` text COMMENT '合同文本',
  `status` int DEFAULT '0' COMMENT '状态(0暂存，1提交，27作废)',
  `change_type` int DEFAULT NULL COMMENT '变更类型 1修改 2删除 3新增, 4数量变更, 5数量增加, 6数量减少',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `first_delivery_at` datetime DEFAULT NULL COMMENT '首件交货日期',
  `latest_delivery_at` datetime DEFAULT NULL COMMENT '最晚交货日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `receiving_company_id` int DEFAULT NULL COMMENT '收料公司id',
  `created_by_name` varchar(255) DEFAULT NULL COMMENT '创建人名称',
  `mx_material_category_is_match_size` int DEFAULT NULL COMMENT '是否配码',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_seq_is_deleted` (`seq`,`is_deleted`),
  KEY `idx_code` (`code`),
  KEY `idx_receiving_company` (`receiving_company`)
) ENGINE=InnoDB AUTO_INCREMENT=597 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料采购单';


--
-- Table structure for table `proc_material_list_copy1`
--

DROP TABLE IF EXISTS `proc_material_list_copy1`;


CREATE TABLE `proc_material_list_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL COMMENT '采购单号',
  `procurement_type` varchar(255) DEFAULT NULL COMMENT '采购类型',
  `sum_price` varchar(12) DEFAULT NULL COMMENT '含税金额',
  `excluding_tax_price` varchar(12) DEFAULT NULL COMMENT '不含税金额',
  `tax_price` varchar(12) DEFAULT NULL COMMENT '税率',
  `mx_material_category_provider_seq` int DEFAULT NULL COMMENT '物料供应商',
  `mx_material_category_provider_name` varchar(100) DEFAULT NULL COMMENT '物料供应商',
  `payment_terms` varchar(255) DEFAULT NULL COMMENT '付款条件',
  `payment_method` varchar(255) DEFAULT NULL COMMENT '付款方式',
  `contract_currency` varchar(255) DEFAULT NULL COMMENT '合同币别',
  `supplier_contact_name` varchar(50) DEFAULT NULL COMMENT '供应商联系人姓名',
  `currency_rate` varchar(50) DEFAULT NULL COMMENT '币种汇率',
  `phone` varchar(50) DEFAULT NULL COMMENT '电话',
  `purchaser` varchar(50) DEFAULT NULL COMMENT '采购人信息',
  `receiving_company` varchar(50) DEFAULT NULL COMMENT '收料公司',
  `receiving_warehouse` varchar(50) DEFAULT NULL COMMENT '收料仓库',
  `receiving_contacts` varchar(50) DEFAULT NULL COMMENT '收料联系人',
  `invoice_contacts` varchar(50) DEFAULT NULL COMMENT '发票联系人',
  `demand_department` varchar(50) DEFAULT NULL COMMENT '需求部门',
  `receiving_address_abb` varchar(255) DEFAULT NULL COMMENT '收料地址简称',
  `receiving_contacts_phone` varchar(50) DEFAULT NULL COMMENT '收料联系人电话',
  `invoice_contacts_phone` varchar(50) DEFAULT NULL COMMENT '发票联系人电话',
  `purchase_date` datetime DEFAULT NULL COMMENT '采购日期',
  `invoice_address_abb` varchar(255) DEFAULT NULL COMMENT '发票地址简称',
  `current_account` varchar(255) DEFAULT NULL COMMENT '往来账户',
  `receiving_address` varchar(255) DEFAULT NULL COMMENT '收料地址',
  `invoice_address` varchar(255) DEFAULT NULL COMMENT '发票地址',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `contract_text` text COMMENT '合同文本',
  `status` int DEFAULT '0' COMMENT '状态(0暂存，1提交)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `first_delivery_at` datetime DEFAULT NULL COMMENT '首件交货日期',
  `latest_delivery_at` datetime DEFAULT NULL COMMENT '最晚交货日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `receiving_company_id` int DEFAULT NULL COMMENT '收料公司id',
  `created_by_name` varchar(255) DEFAULT NULL COMMENT '创建人名称',
  `mx_material_category_is_match_size` int DEFAULT NULL COMMENT '是否配码',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料采购单';


--
-- Table structure for table `proc_material_list_copy2`
--

DROP TABLE IF EXISTS `proc_material_list_copy2`;


CREATE TABLE `proc_material_list_copy2` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL COMMENT '采购单号',
  `procurement_type` varchar(255) DEFAULT NULL COMMENT '采购类型',
  `sum_price` varchar(12) DEFAULT NULL COMMENT '含税金额',
  `excluding_tax_price` varchar(12) DEFAULT NULL COMMENT '不含税金额',
  `tax_price` varchar(12) DEFAULT NULL COMMENT '税率',
  `mx_material_category_provider_seq` int DEFAULT NULL COMMENT '物料供应商',
  `mx_material_category_provider_name` varchar(100) DEFAULT NULL COMMENT '物料供应商',
  `payment_terms` varchar(255) DEFAULT NULL COMMENT '付款条件',
  `payment_method` varchar(255) DEFAULT NULL COMMENT '付款方式',
  `contract_currency` varchar(255) DEFAULT NULL COMMENT '合同币别',
  `supplier_contact_name` varchar(50) DEFAULT NULL COMMENT '供应商联系人姓名',
  `currency_rate` varchar(50) DEFAULT NULL COMMENT '币种汇率',
  `phone` varchar(50) DEFAULT NULL COMMENT '电话',
  `purchaser` varchar(50) DEFAULT NULL COMMENT '采购人信息',
  `receiving_company` varchar(50) DEFAULT NULL COMMENT '收料公司',
  `receiving_warehouse` varchar(50) DEFAULT NULL COMMENT '收料仓库',
  `receiving_contacts` varchar(50) DEFAULT NULL COMMENT '收料联系人',
  `invoice_contacts` varchar(50) DEFAULT NULL COMMENT '发票联系人',
  `demand_department` varchar(50) DEFAULT NULL COMMENT '需求部门',
  `receiving_address_abb` varchar(255) DEFAULT NULL COMMENT '收料地址简称',
  `receiving_contacts_phone` varchar(50) DEFAULT NULL COMMENT '收料联系人电话',
  `invoice_contacts_phone` varchar(50) DEFAULT NULL COMMENT '发票联系人电话',
  `purchase_date` datetime DEFAULT NULL COMMENT '采购日期',
  `invoice_address_abb` varchar(255) DEFAULT NULL COMMENT '发票地址简称',
  `current_account` varchar(255) DEFAULT NULL COMMENT '往来账户',
  `receiving_address` varchar(255) DEFAULT NULL COMMENT '收料地址',
  `invoice_address` varchar(255) DEFAULT NULL COMMENT '发票地址',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `contract_text` text COMMENT '合同文本',
  `status` int DEFAULT '0' COMMENT '状态(0暂存，1提交)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `first_delivery_at` datetime DEFAULT NULL COMMENT '首件交货日期',
  `latest_delivery_at` datetime DEFAULT NULL COMMENT '最晚交货日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `receiving_company_id` int DEFAULT NULL COMMENT '收料公司id',
  `created_by_name` varchar(255) DEFAULT NULL COMMENT '创建人名称',
  `mx_material_category_is_match_size` int DEFAULT NULL COMMENT '是否配码',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=207 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料采购单';


--
-- Table structure for table `proc_material_list_info`
--

DROP TABLE IF EXISTS `proc_material_list_info`;


CREATE TABLE `proc_material_list_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `proc_material_list_seq` int DEFAULT NULL COMMENT '采购订单表序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求计划表序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划表详情序号',
  `proc_material_procurement_code` varchar(255) DEFAULT NULL COMMENT '采购需求计划单号',
  `proc_material_list_info_sum_seq` int DEFAULT NULL COMMENT '采购订单用量汇总表seq',
  `inquiry_price_code` varchar(50) DEFAULT NULL COMMENT '报价单号',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `formal_order_seq` int DEFAULT NULL COMMENT '正式订单序号',
  `formal_order_code` varchar(255) DEFAULT NULL COMMENT '正式生产订单号',
  `row_no` varchar(255) DEFAULT NULL COMMENT '订单行号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `product_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `manual_prod_code` varchar(100) DEFAULT NULL COMMENT '手工排产单号',
  `art_code` varchar(255) DEFAULT NULL COMMENT '工厂型体号',
  `art_name` varchar(255) DEFAULT NULL COMMENT '工厂型体名称',
  `art_color` int DEFAULT NULL COMMENT '型体颜色序号',
  `art_color_name` varchar(255) DEFAULT NULL COMMENT '型体颜色',
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `quarter_code` int DEFAULT NULL COMMENT '季度编号',
  `proc_material_list_code` varchar(50) DEFAULT NULL COMMENT '采购订单号',
  `purchase_unit_price` decimal(4,0) DEFAULT NULL COMMENT '采购单价',
  `settlement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '结算单价',
  `mx_material_category_seq` int NOT NULL COMMENT '物料简码seq',
  `mx_material_category_name` varchar(2000) NOT NULL COMMENT '物料简码名称',
  `mx_material_category_code` varchar(255) NOT NULL COMMENT '物料简码',
  `mx_material_info_seq` int NOT NULL COMMENT '物料编码序号',
  `mx_material_info_code` varchar(255) NOT NULL COMMENT '物料编码',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `mx_material_info_colour` varchar(255) DEFAULT NULL COMMENT '物料颜色编码',
  `mx_material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '物料颜色名称',
  `mx_material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位序号',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料单位名称',
  `system_plan_storage` decimal(13,4) DEFAULT NULL COMMENT '系统计算采购数量',
  `current_planned_quantity` decimal(13,4) DEFAULT NULL COMMENT '本次计划数量',
  `total_purchase_quantity` decimal(13,4) DEFAULT NULL COMMENT '采购总数量',
  `mx_material_category_many_purchase_rate` decimal(13,4) DEFAULT NULL COMMENT '物料多采比率',
  `mx_material_category_purchase_hit_rate` decimal(13,4) DEFAULT NULL COMMENT '物料采购打大率',
  `mx_material_category_purchase_unit_seq` int DEFAULT NULL COMMENT '物料采购单位id',
  `mx_material_category_purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '物料采购单位名称',
  `mx_material_category_provider_type_seq` int DEFAULT NULL COMMENT '物料供方id',
  `mx_material_category_provider_type_name` varchar(100) DEFAULT NULL COMMENT '物料供方名称',
  `production_factory` varchar(255) DEFAULT NULL COMMENT '生产工厂',
  `return_factory_date` datetime DEFAULT NULL COMMENT '回厂日期',
  `check_and_accept_number` varchar(255) DEFAULT NULL COMMENT '验收单号',
  `material_delivery_time` datetime DEFAULT NULL COMMENT '物料行交期',
  `status` char(2) DEFAULT NULL COMMENT '状态\r\n（材料已入库、材料已评检）',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `size_category` int(1) unsigned zerofill DEFAULT '0' COMMENT '尺码类别(0-全,1-左,2右)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `delivery_at` datetime DEFAULT NULL COMMENT '交货时间',
  `sending_at` datetime DEFAULT NULL COMMENT '发货时间',
  `release_at` datetime DEFAULT NULL COMMENT '上线时间',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_first` int DEFAULT '0' COMMENT '是否首件(0-否,1-是)',
  `first_delivery_at` datetime DEFAULT NULL COMMENT '首件交货日期',
  `receiving_warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `receiving_warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `is_empty_price_create` int DEFAULT NULL COMMENT '是否是无单价建单，1是 0否',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '采购需求计划的状态监控表seq',
  `mx_material_category_is_match_size` int DEFAULT NULL COMMENT '是否配码',
  `seq_string` varchar(2000) DEFAULT NULL,
  `mx_material_category_is_exempt_verify` int DEFAULT NULL,
  `inv_remaining_quantity` decimal(13,4) DEFAULT NULL COMMENT '入库剩余量',
  `inspection_remaining_quantity` decimal(13,4) DEFAULT NULL COMMENT '品检剩余量',
  `remaining_quantity` decimal(13,4) DEFAULT NULL COMMENT '暂收剩余量',
  `size` varchar(1000) DEFAULT NULL COMMENT '配码size',
  `change_type` int DEFAULT NULL COMMENT '变更类型 1修改 2删除 3新增, 4数量变更, 5数量增加, 6数量减少',
  `change_num` varchar(500) DEFAULT NULL COMMENT '变更数量',
  `has_dispose` int DEFAULT NULL COMMENT '是否处理异常数据 1已处理 ',
  `end_delivery_date` datetime DEFAULT NULL COMMENT '订单交期',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_info` (`proc_material_list_seq`,`product_order_code`,`mx_material_info_code`),
  KEY `idx_proc_material_list_seq` (`proc_material_list_seq`),
  KEY `idx_product_order_code` (`product_order_code`),
  KEY `idx_mx_material_info_code` (`mx_material_info_code`),
  KEY `manual_prod_code_todo` (`manual_prod_code`),
  KEY `idx_proc_material_procurement_info_seq` (`proc_material_procurement_info_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=49166 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='采购订单详情';


--
-- Table structure for table `proc_material_list_info_copy1`
--

DROP TABLE IF EXISTS `proc_material_list_info_copy1`;


CREATE TABLE `proc_material_list_info_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `proc_material_list_seq` int DEFAULT NULL COMMENT '采购订单表序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求计划表序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划表详情序号',
  `proc_material_procurement_code` varchar(255) DEFAULT NULL COMMENT '采购需求计划单号',
  `proc_material_list_info_sum_seq` int DEFAULT NULL COMMENT '采购订单用量汇总表seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `formal_order_seq` int DEFAULT NULL COMMENT '正式订单序号',
  `formal_order_code` varchar(255) DEFAULT NULL COMMENT '正式生产订单号',
  `row_no` varchar(255) DEFAULT NULL COMMENT '订单行号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `product_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `art_code` varchar(255) DEFAULT NULL COMMENT '工厂型体号',
  `art_name` varchar(255) DEFAULT NULL COMMENT '工厂型体名称',
  `art_color` int DEFAULT NULL COMMENT '型体颜色序号',
  `art_color_name` varchar(255) DEFAULT NULL COMMENT '型体颜色',
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `quarter_code` int DEFAULT NULL COMMENT '季度编号',
  `proc_material_list_code` varchar(50) DEFAULT NULL COMMENT '采购订单号',
  `purchase_unit_price` decimal(4,0) DEFAULT NULL COMMENT '采购单价',
  `settlement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '结算单价',
  `mx_material_category_seq` int NOT NULL COMMENT '物料简码seq',
  `mx_material_category_name` varchar(2000) NOT NULL COMMENT '物料简码名称',
  `mx_material_category_code` varchar(255) NOT NULL COMMENT '物料简码',
  `mx_material_info_seq` int NOT NULL COMMENT '物料编码序号',
  `mx_material_info_code` varchar(255) NOT NULL COMMENT '物料编码',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `mx_material_info_colour` varchar(255) DEFAULT NULL COMMENT '物料颜色编码',
  `mx_material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '物料颜色名称',
  `mx_material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位序号',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料单位名称',
  `system_plan_storage` decimal(13,4) DEFAULT NULL COMMENT '系统计算采购数量',
  `current_planned_quantity` decimal(13,4) DEFAULT NULL COMMENT '本次计划数量',
  `total_purchase_quantity` decimal(13,4) DEFAULT NULL COMMENT '采购总数量',
  `mx_material_category_many_purchase_rate` decimal(13,4) DEFAULT NULL COMMENT '物料多采比率',
  `mx_material_category_purchase_hit_rate` decimal(13,4) DEFAULT NULL COMMENT '物料采购打大率',
  `mx_material_category_purchase_unit_seq` int DEFAULT NULL COMMENT '物料采购单位id',
  `mx_material_category_purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '物料采购单位名称',
  `mx_material_category_provider_type_seq` int DEFAULT NULL COMMENT '物料供方id',
  `mx_material_category_provider_type_name` varchar(100) DEFAULT NULL COMMENT '物料供方名称',
  `production_factory` varchar(255) DEFAULT NULL COMMENT '生产工厂',
  `return_factory_date` datetime DEFAULT NULL COMMENT '回厂日期',
  `check_and_accept_number` varchar(255) DEFAULT NULL COMMENT '验收单号',
  `material_delivery_time` datetime DEFAULT NULL COMMENT '物料行交期',
  `status` char(2) DEFAULT NULL COMMENT '状态\r\n（材料已入库、材料已评检）',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `size_category` int(1) unsigned zerofill DEFAULT '0' COMMENT '尺码类别(0-全,1-左,2右)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `delivery_at` datetime DEFAULT NULL COMMENT '交货时间',
  `sending_at` datetime DEFAULT NULL COMMENT '发货时间',
  `release_at` datetime DEFAULT NULL COMMENT '上线时间',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_first` int DEFAULT '0' COMMENT '是否首件(0-否,1-是)',
  `first_delivery_at` datetime DEFAULT NULL COMMENT '首件交货日期',
  `receiving_warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `receiving_warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `is_empty_price_create` int DEFAULT NULL COMMENT '是否是无单价建单，1是 0否',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '采购需求计划的状态监控表seq',
  `mx_material_category_is_match_size` int DEFAULT NULL COMMENT '是否配码',
  `seq_string` varchar(2000) DEFAULT NULL,
  `mx_material_category_is_exempt_verify` int DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7042 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='采购订单详情';


--
-- Table structure for table `proc_material_list_info_size`
--

DROP TABLE IF EXISTS `proc_material_list_info_size`;


CREATE TABLE `proc_material_list_info_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proc_material_list_seq` int DEFAULT NULL COMMENT '采购单序号',
  `proc_material_list_info_seq` int DEFAULT NULL COMMENT '采购单明细序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求单序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划单明细序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体尺码序号',
  `size_seq` int DEFAULT NULL COMMENT '尺码序号',
  `size_code` varchar(50) DEFAULT NULL COMMENT 'size编码',
  `size_name` varchar(50) DEFAULT NULL COMMENT 'size名称',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_size` (`proc_material_list_seq`,`proc_material_list_info_seq`,`size_code`),
  KEY `idx_proc_material_list_seq_info` (`proc_material_list_seq`,`proc_material_list_info_seq`),
  KEY `idx_size_code` (`size_code`)
) ENGINE=InnoDB AUTO_INCREMENT=160183 DEFAULT CHARSET=utf8mb3 COMMENT='采购单型体各size';


--
-- Table structure for table `proc_material_list_info_size_copy1`
--

DROP TABLE IF EXISTS `proc_material_list_info_size_copy1`;


CREATE TABLE `proc_material_list_info_size_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proc_material_list_seq` int DEFAULT NULL COMMENT '采购单序号',
  `proc_material_list_info_seq` int DEFAULT NULL COMMENT '采购单明细序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求单序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划单明细序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体尺码序号',
  `size_seq` int DEFAULT NULL COMMENT '尺码序号',
  `size_code` varchar(50) DEFAULT NULL COMMENT 'size编码',
  `size_name` varchar(50) DEFAULT NULL COMMENT 'size名称',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=52017 DEFAULT CHARSET=utf8mb3 COMMENT='采购单型体各size';


--
-- Table structure for table `proc_material_list_info_size_dosage`
--

DROP TABLE IF EXISTS `proc_material_list_info_size_dosage`;


CREATE TABLE `proc_material_list_info_size_dosage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proc_material_list_seq` int DEFAULT NULL COMMENT '采购单序号',
  `proc_material_list_info_seq` int DEFAULT NULL COMMENT '采购单明细序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求计划单序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划单明细序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` varchar(255) DEFAULT NULL COMMENT '用量',
  `change_num` decimal(12,4) DEFAULT NULL COMMENT '变更数量',
  `unused_storage` varchar(255) DEFAULT NULL COMMENT '剩余可用量',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_dosage` (`proc_material_list_seq`,`proc_material_list_info_seq`,`key`),
  KEY `idx_proc_material_list_seq_info_key` (`proc_material_list_seq`,`proc_material_list_info_seq`,`key`)
) ENGINE=InnoDB AUTO_INCREMENT=127616 DEFAULT CHARSET=utf8mb3 COMMENT='采购单明细部位各码总用量';


--
-- Table structure for table `proc_material_list_info_size_dosage_copy1`
--

DROP TABLE IF EXISTS `proc_material_list_info_size_dosage_copy1`;


CREATE TABLE `proc_material_list_info_size_dosage_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proc_material_list_seq` int DEFAULT NULL COMMENT '采购单序号',
  `proc_material_list_info_seq` int DEFAULT NULL COMMENT '采购单明细序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求计划单序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划单明细序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` varchar(255) DEFAULT NULL COMMENT '用量',
  `unused_storage` varchar(255) DEFAULT NULL COMMENT '剩余可用量',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=44693 DEFAULT CHARSET=utf8mb3 COMMENT='采购单明细部位各码总用量';


--
-- Table structure for table `proc_material_list_info_sum`
--

DROP TABLE IF EXISTS `proc_material_list_info_sum`;


CREATE TABLE `proc_material_list_info_sum` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `proc_material_list_seq` int DEFAULT NULL COMMENT '采购订单表序号',
  `inquiry_price_code` varchar(50) DEFAULT NULL COMMENT '报价单号',
  `mx_material_category_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `mx_material_category_name` varchar(2000) DEFAULT NULL COMMENT '物料简码名称',
  `mx_material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `mx_material_info_colour` varchar(255) DEFAULT NULL COMMENT '物料颜色编码',
  `mx_material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '物料颜色名称',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料单位名称',
  `system_plan_storage` decimal(13,4) DEFAULT NULL COMMENT '系统计算采购数量',
  `current_planned_quantity` decimal(13,4) DEFAULT NULL COMMENT '本次计划数量',
  `total_purchase_quantity` decimal(13,4) DEFAULT NULL COMMENT '采购总数量',
  `remaining_quantity` double(18,4) DEFAULT NULL COMMENT '剩余用量',
  `return_material_quantity` decimal(13,4) NOT NULL DEFAULT '0.0000' COMMENT '退料数量',
  `mx_material_category_is_match_size` int DEFAULT NULL COMMENT '是否配码',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `od_order_doc_seq` varchar(200) DEFAULT NULL COMMENT '正式订单号seq',
  `od_order_doc_code` text COMMENT '正式订单号',
  `od_prod_order_seq` varchar(200) DEFAULT NULL COMMENT '生产订单号seq',
  `od_prod_order_code` text COMMENT '生产订单号',
  `manual_prod_code` text COMMENT '手工排产单号',
  `art_customer_article_code` text COMMENT '客户型体号',
  `art_code` text COMMENT '工厂型体号',
  `mx_material_category_provider_type_name` varchar(200) DEFAULT NULL COMMENT '供应商类型',
  `purchase_unit_price` varchar(200) DEFAULT NULL COMMENT '采购单价',
  `art_product_class_seq` varchar(200) DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(200) DEFAULT NULL COMMENT '产品类别',
  `art_customer_seq` varchar(200) DEFAULT NULL COMMENT '客户seq',
  `art_customer_name` varchar(200) DEFAULT NULL COMMENT '客户名称',
  `receiving_warehouse_code` varchar(200) DEFAULT NULL COMMENT '收料仓库',
  `receiving_warehouse_name` varchar(200) DEFAULT NULL COMMENT '收料仓库名称',
  `material_info_code` varchar(200) DEFAULT NULL COMMENT '物料编码(停用)',
  `mx_material_category_is_exempt_verify` varchar(200) DEFAULT NULL COMMENT '是否免检',
  `position_name` varchar(200) DEFAULT NULL COMMENT '部位',
  `provider_seq` varchar(200) DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(200) DEFAULT NULL COMMENT '供应商名称',
  `version` int DEFAULT '0' COMMENT '版本号',
  `status` int DEFAULT NULL COMMENT '状态',
  `sku` text COMMENT 'sku',
  `size_dosage_map` varchar(255) DEFAULT NULL,
  `mx_material_info_seq` int DEFAULT NULL COMMENT '物料编码',
  `mx_material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `size` varchar(1000) DEFAULT NULL COMMENT '配码size',
  `process_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `row_no` varchar(255) DEFAULT NULL COMMENT '订单行号',
  `quarter_code` int DEFAULT NULL COMMENT '季度编号',
  `material_delivery_time` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `is_first` int DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `first_delivery_at` datetime DEFAULT NULL,
  `mx_material_category_purchase_unit_name` varchar(500) DEFAULT NULL,
  `art_color` varchar(500) DEFAULT NULL,
  `art_color_name` varchar(500) DEFAULT NULL,
  `art_name` varchar(500) DEFAULT NULL,
  `mx_material_category_many_purchase_rate` decimal(13,4) DEFAULT NULL COMMENT '物料多采比率',
  `mx_material_category_purchase_hit_rate` decimal(13,4) DEFAULT NULL COMMENT '物料采购打大率',
  `proc_material_procurement_code` text COMMENT '采购需求计划单号',
  `first_confirm_date` date DEFAULT NULL COMMENT '第一次交期',
  `second_confirm_date` date DEFAULT NULL COMMENT '第二次交期',
  `third_confirm_date` date DEFAULT NULL COMMENT '第三次交期',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15101 DEFAULT CHARSET=utf8mb3 COMMENT='采购订单详情汇总';


--
-- Table structure for table `proc_material_list_info_sum_size_dosage`
--

DROP TABLE IF EXISTS `proc_material_list_info_sum_size_dosage`;


CREATE TABLE `proc_material_list_info_sum_size_dosage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proc_material_list_info_sum_seq` int DEFAULT NULL COMMENT '采购单序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` varchar(255) DEFAULT NULL COMMENT '用量',
  `unused_storage` varchar(255) DEFAULT NULL COMMENT '剩余可用量',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=25106 DEFAULT CHARSET=utf8mb3 COMMENT='采购单明细部位各码汇总用量';


--
-- Table structure for table `proc_material_list_info_sum_size_dosage_copy1`
--

DROP TABLE IF EXISTS `proc_material_list_info_sum_size_dosage_copy1`;


CREATE TABLE `proc_material_list_info_sum_size_dosage_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proc_material_list_info_sum_seq` int DEFAULT NULL COMMENT '采购单序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` varchar(255) DEFAULT NULL COMMENT '用量',
  `unused_storage` varchar(255) DEFAULT NULL COMMENT '剩余可用量',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9980 DEFAULT CHARSET=utf8mb3 COMMENT='采购单明细部位各码汇总用量';


--
-- Table structure for table `proc_material_list_prod`
--

DROP TABLE IF EXISTS `proc_material_list_prod`;


CREATE TABLE `proc_material_list_prod` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `material_list_seq` int DEFAULT NULL COMMENT '采购清单序号',
  `material_prod_seq` int DEFAULT NULL COMMENT '采购计划序号',
  `material_id` varchar(255) DEFAULT NULL COMMENT '物料',
  `price` double(11,2) DEFAULT NULL COMMENT '价格',
  `num` int DEFAULT NULL COMMENT '数量',
  `total_price` decimal(10,2) DEFAULT NULL COMMENT '金额',
  `is_delete` int DEFAULT '0',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料采购单-采购计划关联表';


--
-- Table structure for table `proc_material_list_prod_copy1`
--

DROP TABLE IF EXISTS `proc_material_list_prod_copy1`;


CREATE TABLE `proc_material_list_prod_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `material_list_seq` int DEFAULT NULL COMMENT '采购清单序号',
  `material_prod_seq` int DEFAULT NULL COMMENT '采购计划序号',
  `material_id` varchar(255) DEFAULT NULL COMMENT '物料',
  `price` double(11,2) DEFAULT NULL COMMENT '价格',
  `num` int DEFAULT NULL COMMENT '数量',
  `total_price` decimal(10,2) DEFAULT NULL COMMENT '金额',
  `is_delete` int DEFAULT '0',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料采购单-采购计划关联表';


--
-- Table structure for table `proc_material_list_todo`
--

DROP TABLE IF EXISTS `proc_material_list_todo`;


CREATE TABLE `proc_material_list_todo` (
  `proc_material_procurement_info_seq` int NOT NULL COMMENT '采购需求计划明细表序号',
  `proc_material_procurement_seq` int DEFAULT NULL,
  `proc_material_procurement_code` varchar(255) DEFAULT NULL,
  `end_delivery_date` datetime DEFAULT NULL,
  `product_order_code` varchar(255) DEFAULT NULL,
  `manual_prod_code` varchar(100) DEFAULT NULL COMMENT '手工排产单号',
  `od_product_order_order_position_seq` int DEFAULT NULL,
  `mx_material_info_colour` varchar(255) DEFAULT NULL,
  `mx_material_info_colour_name` varchar(500) DEFAULT NULL,
  `position_seq` int DEFAULT NULL,
  `position_code` varchar(255) DEFAULT NULL,
  `position_name` varchar(500) DEFAULT NULL,
  `process_name` varchar(255) DEFAULT NULL,
  `mx_material_info_seq` int DEFAULT NULL,
  `material_parent_seq` varchar(255) DEFAULT NULL,
  `mx_material_info_code` varchar(255) DEFAULT NULL,
  `mx_material_category_seq` int DEFAULT NULL,
  `mx_material_category_name` varchar(400) DEFAULT NULL,
  `mx_material_category_code` varchar(255) DEFAULT NULL,
  `mx_material_category_type_name` varchar(255) DEFAULT NULL,
  `mx_material_category_type_seq` int DEFAULT NULL,
  `mx_material_category_class_seq` int DEFAULT NULL,
  `mx_material_category_class_name` varchar(255) DEFAULT NULL,
  `mx_material_category_class_path_name` varchar(255) DEFAULT NULL,
  `mx_material_category_group_seq` int DEFAULT NULL,
  `mx_material_category_group_name` varchar(255) DEFAULT NULL,
  `mx_material_category_unit_seq` int DEFAULT NULL,
  `mx_material_category_unit_name` varchar(255) DEFAULT NULL,
  `mx_material_category_provider_seq` int DEFAULT NULL,
  `mx_material_category_provider_name` varchar(255) DEFAULT NULL,
  `mx_material_category_is_exempt_verify` int DEFAULT NULL,
  `mx_material_category_is_out_sourcing` int DEFAULT NULL,
  `mx_material_category_is_color_constraint` int DEFAULT NULL,
  `mx_material_category_is_each_expend` int DEFAULT NULL,
  `mx_material_category_is_match_size` int DEFAULT NULL,
  `mx_material_category_money_type_seq` int DEFAULT NULL,
  `mx_material_category_money_type_name` varchar(50) DEFAULT NULL,
  `mx_material_category_purchase_unit_seq` int DEFAULT NULL,
  `mx_material_category_purchase_unit_name` varchar(255) DEFAULT NULL,
  `mx_material_category_purchase_convert_rate` decimal(11,4) DEFAULT NULL,
  `mx_material_category_provider_type_seq` int DEFAULT NULL,
  `mx_material_category_provider_type_name` varchar(255) DEFAULT NULL,
  `mx_material_category_purchase_hit_rate` decimal(11,4) DEFAULT NULL,
  `mx_material_category_many_purchase_rate` decimal(11,4) DEFAULT NULL,
  `mx_material_category_many_receive_rate` decimal(11,4) DEFAULT NULL,
  `storage` double(11,4) DEFAULT NULL,
  `system_calculation_quantity` double(15,4) DEFAULT NULL,
  `unused_storage` double(15,4) DEFAULT NULL,
  `plan_storage` double(15,4) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `size_category` double(15,4) DEFAULT NULL,
  `quarter_code` varchar(255) DEFAULT NULL,
  `memo` varchar(255) DEFAULT NULL,
  `purchase_unit_price` decimal(11,4) DEFAULT NULL,
  `system_plan_storage` varchar(255) DEFAULT NULL,
  `formal_order_code` varchar(255) DEFAULT NULL,
  `row_no` varchar(255) DEFAULT NULL,
  `art_code` varchar(255) DEFAULT NULL,
  `art_customer_article_code` varchar(255) DEFAULT NULL,
  `art_color_name` varchar(255) DEFAULT NULL,
  `art_name` varchar(255) DEFAULT NULL,
  `sku` varchar(150) DEFAULT NULL,
  `sku_logo` varchar(255) DEFAULT NULL,
  `art_customer_name` varchar(255) DEFAULT NULL,
  `art_product_class_name` varchar(255) DEFAULT NULL,
  `size_dosage_map` text COMMENT '尺码用量',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户seq',
  `material_replenishment_seq` int DEFAULT NULL COMMENT '材料补单seq',
  `material_replenishment_code` varchar(255) DEFAULT NULL COMMENT '材料补单号',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `is_deleted` int DEFAULT '0',
  `seq_string` varchar(2000) DEFAULT NULL,
  `receiving_warehouse_code` varchar(255) DEFAULT NULL,
  `receiving_warehouse_name` varchar(255) DEFAULT NULL,
  `version` int DEFAULT '0',
  `company_name` varchar(255) DEFAULT NULL COMMENT '公司名称',
  `company_seq` int DEFAULT NULL COMMENT '公司seq',
  `data_source` varchar(20) DEFAULT NULL COMMENT '数据来源',
  `size_key` varchar(20) DEFAULT NULL COMMENT '尺码',
  PRIMARY KEY (`proc_material_procurement_info_seq`),
  KEY `is_deleted_2` (`is_deleted`,`created_at`,`mx_material_category_is_out_sourcing`,`mx_material_category_provider_type_name`,`status`),
  KEY `is_deleted` (`proc_material_procurement_seq`,`created_at`,`mx_material_category_is_out_sourcing`,`mx_material_category_provider_type_name`,`status`,`mx_material_category_provider_name`,`is_deleted`),
  KEY `mx_material_category_provider_seq` (`mx_material_category_provider_seq`,`product_order_code`,`mx_material_info_code`),
  KEY `manual_prod_code_index` (`manual_prod_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='物料采购待处理表';


--
-- Temporary view structure for view `proc_material_list_view`
--

DROP TABLE IF EXISTS `proc_material_list_view`;
/*!50001 DROP VIEW IF EXISTS `proc_material_list_view`*/;
SET @saved_cs_client     = @@character_set_client;

/*!50001 CREATE VIEW `proc_material_list_view` AS SELECT 
 1 AS `product_order_code`,
 1 AS `size_code`,
 1 AS `code`,
 1 AS `mx_material_info_code`,
 1 AS `position_seq`,
 1 AS `mx_material_info_colour`,
 1 AS `bjcgl`,
 1 AS `dccgl`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `proc_material_out_bound`
--

DROP TABLE IF EXISTS `proc_material_out_bound`;


CREATE TABLE `proc_material_out_bound` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `outbound_type` int DEFAULT NULL COMMENT '出库类型 加工材料出库1 车间领料出库2 转仓出库 3',
  `outbound_number` varchar(50) DEFAULT NULL COMMENT '出库单号',
  `picking_number` varchar(255) DEFAULT NULL COMMENT '领料单号',
  `outbound_at` datetime DEFAULT NULL COMMENT '出库日期',
  `operator` varchar(50) DEFAULT NULL COMMENT '经办人',
  `factory` varchar(255) DEFAULT NULL COMMENT '工厂',
  `warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库',
  `picking_type` varchar(50) DEFAULT NULL COMMENT '领料类型',
  `status` int DEFAULT NULL COMMENT '状态(0暂存，1提交)',
  `printing_frequency` varchar(50) DEFAULT NULL COMMENT '打印次数',
  `submit_at` datetime DEFAULT NULL COMMENT '提交日期',
  `workshop_team` varchar(50) DEFAULT NULL COMMENT '车间小组',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `picking_factory` varchar(50) DEFAULT NULL COMMENT '领料工厂',
  `picking_workshop` varchar(50) DEFAULT NULL COMMENT '领料车间',
  `picking_warehouse` varchar(50) DEFAULT NULL COMMENT '领料仓库',
  `outbound_nature` varchar(100) DEFAULT NULL COMMENT '出库性质',
  `undertaking_party` varchar(50) DEFAULT NULL COMMENT '承担方',
  `undertaking_explain` varchar(50) DEFAULT NULL COMMENT '承担说明',
  `is_effective` int DEFAULT '0' COMMENT '是否可用(0-否,1-是)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `picking_division` varchar(255) DEFAULT NULL COMMENT '领料部门',
  `picking_factory_id` int DEFAULT NULL COMMENT '领料工厂id',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `factory_id` int DEFAULT NULL,
  `requisition_factory_id` int DEFAULT NULL COMMENT '发料工厂',
  `requisition_factory` varchar(255) DEFAULT NULL COMMENT '发料工厂',
  `warehouse_code` varchar(255) DEFAULT NULL COMMENT '仓库code',
  `picking_division_id` int DEFAULT NULL COMMENT '领料部门id',
  `group_id` int DEFAULT NULL COMMENT '组别id',
  `group_name` varchar(255) DEFAULT NULL COMMENT '组别名称',
  `outbound_type_name` varchar(50) DEFAULT NULL COMMENT '出库类型名称',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=117 DEFAULT CHARSET=utf8mb3 COMMENT='材料出库';


--
-- Table structure for table `proc_material_out_bound_info`
--

DROP TABLE IF EXISTS `proc_material_out_bound_info`;


CREATE TABLE `proc_material_out_bound_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `material_out_bound_seq` int DEFAULT NULL COMMENT '材料出库表seq',
  `formal_order_code` varchar(100) DEFAULT NULL COMMENT '正式订单号',
  `od_prod_order_code` varchar(100) DEFAULT NULL COMMENT '生产订单号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单号seq',
  `sku` varchar(100) DEFAULT NULL COMMENT 'sku',
  `customer_article_code` varchar(100) DEFAULT NULL COMMENT '客户型体号',
  `batch_number` varchar(10) DEFAULT NULL COMMENT '批次号',
  `storage_location` varchar(50) DEFAULT NULL COMMENT '储位',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `position_seq` int DEFAULT NULL,
  `position_name` varchar(100) DEFAULT NULL COMMENT '部位',
  `position_code` varchar(100) DEFAULT NULL COMMENT '部位',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '颜色',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料基本单位',
  `mx_material_category_purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '物料采购单位',
  `material_category_code` varchar(100) DEFAULT NULL COMMENT '物料简码',
  `material_manager` varchar(100) DEFAULT NULL COMMENT '材料负责人',
  `order_doc_aritcle_seq` varchar(100) DEFAULT NULL COMMENT '正式订单行标识',
  `mx_material_category_purchase_convert_rate` varchar(100) DEFAULT NULL COMMENT '转换比率',
  `customer_delivery_time` datetime DEFAULT NULL COMMENT '客户交期',
  `art_color_name` varchar(100) DEFAULT NULL COMMENT '型体颜色',
  `cumulative_return_materials_number` varchar(50) DEFAULT NULL COMMENT '累计退料数量',
  `thistime_return_materials_number` decimal(13,4) DEFAULT NULL COMMENT '本次退料数量 , 本次数量',
  `inventory_quantity` decimal(13,4) DEFAULT NULL COMMENT '库存量',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `total_inventory` decimal(13,4) DEFAULT NULL COMMENT '总库存量',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `row_no` varchar(255) DEFAULT NULL COMMENT '行标识',
  `location_name` varchar(50) DEFAULT NULL COMMENT '储位名称',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位编号',
  `warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '上游单据seq',
  `return_materials_number` varchar(100) DEFAULT NULL,
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `provider_seq` int DEFAULT NULL,
  `provider_name` varchar(255) DEFAULT NULL,
  `size` varchar(255) DEFAULT NULL,
  `material_info_seq` int DEFAULT NULL,
  `material_category_seq` int DEFAULT NULL,
  `material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '材料颜色名称',
  `picking_number` varchar(255) NOT NULL COMMENT '领料单号',
  `customer_seq` int DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `manual_prod_code` varchar(255) DEFAULT NULL COMMENT '指令号',
  `return_apply_status` int NOT NULL DEFAULT '0' COMMENT '材料退料申请状态 0未申请 1已申请',
  `return_apply_total` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT '已申请退料数量',
  `group_dispatch_code` varchar(255) DEFAULT NULL COMMENT '组别派工单号',
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  `actual_usage` decimal(12,4) DEFAULT NULL COMMENT '申请数量',
  `mx_material_category_class_name` varchar(255) DEFAULT NULL COMMENT '物料类别名称',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2975 DEFAULT CHARSET=utf8mb3 COMMENT='材料出库明细';


--
-- Table structure for table `proc_material_out_process_order`
--

DROP TABLE IF EXISTS `proc_material_out_process_order`;


CREATE TABLE `proc_material_out_process_order` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL COMMENT '委外加工单号',
  `procurement_type` varchar(255) DEFAULT NULL COMMENT '采购类型',
  `sum_price` varchar(12) DEFAULT NULL COMMENT '含税金额',
  `excluding_tax_price` varchar(12) DEFAULT NULL COMMENT '不含税金额',
  `tax_price` varchar(12) DEFAULT NULL COMMENT '税率',
  `mx_material_category_provider_seq` int DEFAULT NULL COMMENT '物料供应商',
  `mx_material_category_provider_name` varchar(100) DEFAULT NULL COMMENT '物料供应商',
  `payment_terms` varchar(255) DEFAULT NULL COMMENT '付款条件',
  `payment_method` varchar(255) DEFAULT NULL COMMENT '付款方式',
  `contract_currency` varchar(255) DEFAULT NULL COMMENT '合同币别',
  `supplier_contact_name` varchar(50) DEFAULT NULL COMMENT '供应商联系人姓名',
  `currency_rate` varchar(50) DEFAULT NULL COMMENT '币种汇率',
  `phone` varchar(50) DEFAULT NULL COMMENT '电话',
  `purchaser` varchar(50) DEFAULT NULL COMMENT '采购人信息',
  `receiving_company_id` int DEFAULT NULL,
  `receiving_company` varchar(50) DEFAULT NULL COMMENT '收料公司',
  `receiving_warehouse` varchar(50) DEFAULT NULL COMMENT '收料仓库',
  `receiving_contacts` varchar(50) DEFAULT NULL COMMENT '收料联系人',
  `invoice_contacts` varchar(50) DEFAULT NULL COMMENT '发票联系人',
  `demand_department` varchar(50) DEFAULT NULL COMMENT '需求部门',
  `receiving_address_abb` varchar(255) DEFAULT NULL COMMENT '收料地址简称',
  `receiving_contacts_phone` varchar(50) DEFAULT NULL COMMENT '收料联系人电话',
  `invoice_contacts_phone` varchar(50) DEFAULT NULL COMMENT '发票联系人电话',
  `purchase_date` datetime DEFAULT NULL COMMENT '采购日期',
  `invoice_address_abb` varchar(255) DEFAULT NULL COMMENT '发票地址简称',
  `current_account` varchar(255) DEFAULT NULL COMMENT '往来账户',
  `receiving_address` varchar(255) DEFAULT NULL COMMENT '收料地址',
  `invoice_address` varchar(255) DEFAULT NULL COMMENT '发票地址',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `contract_text` text COMMENT '合同文本',
  `status` int DEFAULT '0' COMMENT '状态(0暂存，1提交，27作废)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `first_delivery_at` datetime DEFAULT NULL COMMENT '首件交货日期',
  `latest_delivery_at` datetime DEFAULT NULL COMMENT '最晚交货日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `created_by_name` varchar(500) DEFAULT NULL COMMENT '创建人名称',
  `change_type` int DEFAULT NULL COMMENT '变更类型 1修改 2删除 3新增, 4数量变更, 5数量增加, 6数量减少',
  `mx_material_category_is_match_size` int DEFAULT NULL COMMENT '是否配码',
  PRIMARY KEY (`seq`) USING BTREE,
  UNIQUE KEY `codeIdx` (`code`),
  KEY `idx_seq_is_deleted` (`seq`,`is_deleted`),
  KEY `idx_code` (`code`),
  KEY `idx_receiving_company` (`receiving_company`)
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料委外加工单';


--
-- Table structure for table `proc_material_out_process_order_info`
--

DROP TABLE IF EXISTS `proc_material_out_process_order_info`;


CREATE TABLE `proc_material_out_process_order_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `uuid` varchar(40) DEFAULT NULL,
  `out_process_order_seq` int DEFAULT NULL COMMENT '材料外加工单序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求计划表序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划表详情序号',
  `proc_material_procurement_code` varchar(255) DEFAULT NULL COMMENT '采购需求计划单号',
  `formal_order_seq` int DEFAULT NULL COMMENT '正式订单序号',
  `formal_order_code` varchar(255) DEFAULT NULL COMMENT '正式生产订单号',
  `row_no` varchar(255) DEFAULT NULL COMMENT '订单行号',
  `manual_prod_code` varchar(200) DEFAULT NULL COMMENT '手工排产单号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `product_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `art_code` varchar(255) DEFAULT NULL COMMENT '工厂型体号',
  `art_name` varchar(255) DEFAULT NULL COMMENT '工厂型体名称',
  `art_color` int DEFAULT NULL COMMENT '型体颜色序号',
  `art_color_name` varchar(255) DEFAULT NULL COMMENT '型体颜色',
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `mx_material_category_seq` int NOT NULL COMMENT '物料简码seq',
  `mx_material_category_name` varchar(2000) NOT NULL COMMENT '物料简码名称',
  `mx_material_category_code` varchar(255) NOT NULL COMMENT '物料简码',
  `mx_material_info_seq` int NOT NULL COMMENT '物料编码序号',
  `mx_material_info_code` varchar(255) NOT NULL COMMENT '物料编码',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `mx_material_info_colour` varchar(255) DEFAULT NULL COMMENT '物料颜色编码',
  `mx_material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '物料颜色名称',
  `mx_material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位序号',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料单位名称',
  `system_plan_storage` decimal(20,4) DEFAULT NULL COMMENT '系统计算采购数量',
  `current_planned_quantity` decimal(20,4) DEFAULT NULL COMMENT '本次计划数量',
  `total_purchase_quantity` decimal(20,4) DEFAULT NULL COMMENT '采购总数量',
  `mx_material_category_many_purchase_rate` decimal(11,2) DEFAULT NULL COMMENT '物料多采比率',
  `mx_material_category_purchase_hit_rate` decimal(11,2) DEFAULT NULL COMMENT '物料采购打大率',
  `mx_material_category_purchase_unit_seq` int DEFAULT NULL COMMENT '物料采购单位id',
  `mx_material_category_purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '物料采购单位名称',
  `mx_material_category_provider_type_seq` int DEFAULT NULL COMMENT '物料供方id',
  `mx_material_category_provider_type_name` varchar(100) DEFAULT NULL COMMENT '物料供方名称',
  `production_factory` varchar(255) DEFAULT NULL COMMENT '生产工厂',
  `return_factory_date` datetime DEFAULT NULL COMMENT '回厂日期',
  `check_and_accept_number` varchar(255) DEFAULT NULL COMMENT '验收单号',
  `material_delivery_time` datetime DEFAULT NULL COMMENT '物料行交期',
  `mx_material_category_is_match_size` int DEFAULT '0' COMMENT '是否配码 1是 0否',
  `status` char(2) DEFAULT NULL COMMENT '状态\r\n（材料已入库、材料已评检）',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `delivery_at` datetime DEFAULT NULL COMMENT '交货时间',
  `sending_at` datetime DEFAULT NULL COMMENT '发货时间',
  `release_at` datetime DEFAULT NULL COMMENT '上线时间',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `receiving_warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `receiving_warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '采购需求计划的状态监控表seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `seq_string` varchar(2000) DEFAULT NULL,
  `size` varchar(1000) DEFAULT NULL,
  `size_dosage_map` text,
  `out_process_order_subtotal_seq` int DEFAULT NULL,
  `proc_material_list_code` varchar(100) DEFAULT NULL COMMENT '委外加工单号',
  `purchase_unit_price` decimal(10,2) DEFAULT NULL COMMENT '采购单价',
  `quarter_code` int DEFAULT NULL COMMENT '季节编号',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位',
  `location_name` varchar(100) DEFAULT NULL COMMENT '储位',
  `remaining_quantity` decimal(13,4) DEFAULT NULL COMMENT '暂收剩余量',
  `inspection_remaining_quantity` decimal(13,4) DEFAULT NULL COMMENT '品检剩余量',
  `inv_remaining_quantity` decimal(13,4) DEFAULT NULL COMMENT '入库剩余量',
  `warehouse_code` varchar(255) DEFAULT NULL COMMENT '仓库编码',
  `warehouse_name` varchar(255) DEFAULT NULL COMMENT '仓库名称',
  `change_type` int DEFAULT NULL COMMENT '变更类型 1修改 2删除 3新增, 4数量变更, 5数量增加, 6数量减少',
  `change_num` varchar(50) DEFAULT NULL COMMENT '变更数量',
  `has_dispose` int DEFAULT NULL COMMENT '是否处理异常数据 1已处理 ',
  `inquiry_price_code` varchar(50) DEFAULT NULL COMMENT '报价单号',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_out_process_order_seq` (`out_process_order_seq`),
  KEY `idx_product_order_code` (`product_order_code`),
  KEY `idx_mx_material_info_code` (`mx_material_info_code`),
  KEY `proc_material_out_process_order_info_uuid_index` (`uuid`),
  KEY `idx_proc_material_procurement_info_seq` (`proc_material_procurement_info_seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10605 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料外加工单';


--
-- Table structure for table `proc_material_out_process_order_info_copy`
--

DROP TABLE IF EXISTS `proc_material_out_process_order_info_copy`;


CREATE TABLE `proc_material_out_process_order_info_copy` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `uuid` varchar(40) DEFAULT NULL,
  `out_process_order_seq` int DEFAULT NULL COMMENT '材料外加工单序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求计划表序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划表详情序号',
  `proc_material_procurement_code` varchar(255) DEFAULT NULL COMMENT '采购需求计划单号',
  `formal_order_seq` int DEFAULT NULL COMMENT '正式订单序号',
  `formal_order_code` varchar(255) DEFAULT NULL COMMENT '正式生产订单号',
  `row_no` varchar(255) DEFAULT NULL COMMENT '订单行号',
  `manual_prod_code` varchar(200) DEFAULT NULL COMMENT '手工排产单号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `product_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `art_code` varchar(255) DEFAULT NULL COMMENT '工厂型体号',
  `art_name` varchar(255) DEFAULT NULL COMMENT '工厂型体名称',
  `art_color` int DEFAULT NULL COMMENT '型体颜色序号',
  `art_color_name` varchar(255) DEFAULT NULL COMMENT '型体颜色',
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `mx_material_category_seq` int NOT NULL COMMENT '物料简码seq',
  `mx_material_category_name` varchar(2000) NOT NULL COMMENT '物料简码名称',
  `mx_material_category_code` varchar(255) NOT NULL COMMENT '物料简码',
  `mx_material_info_seq` int NOT NULL COMMENT '物料编码序号',
  `mx_material_info_code` varchar(255) NOT NULL COMMENT '物料编码',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `mx_material_info_colour` varchar(255) DEFAULT NULL COMMENT '物料颜色编码',
  `mx_material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '物料颜色名称',
  `mx_material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位序号',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料单位名称',
  `system_plan_storage` decimal(20,4) DEFAULT NULL COMMENT '系统计算采购数量',
  `current_planned_quantity` decimal(20,4) DEFAULT NULL COMMENT '本次计划数量',
  `total_purchase_quantity` decimal(20,4) DEFAULT NULL COMMENT '采购总数量',
  `mx_material_category_many_purchase_rate` decimal(11,2) DEFAULT NULL COMMENT '物料多采比率',
  `mx_material_category_purchase_hit_rate` decimal(11,2) DEFAULT NULL COMMENT '物料采购打大率',
  `mx_material_category_purchase_unit_seq` int DEFAULT NULL COMMENT '物料采购单位id',
  `mx_material_category_purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '物料采购单位名称',
  `mx_material_category_provider_type_seq` int DEFAULT NULL COMMENT '物料供方id',
  `mx_material_category_provider_type_name` varchar(100) DEFAULT NULL COMMENT '物料供方名称',
  `production_factory` varchar(255) DEFAULT NULL COMMENT '生产工厂',
  `return_factory_date` datetime DEFAULT NULL COMMENT '回厂日期',
  `check_and_accept_number` varchar(255) DEFAULT NULL COMMENT '验收单号',
  `material_delivery_time` datetime DEFAULT NULL COMMENT '物料行交期',
  `mx_material_category_is_match_size` int DEFAULT '0' COMMENT '是否配码 1是 0否',
  `status` char(2) DEFAULT NULL COMMENT '状态\r\n（材料已入库、材料已评检）',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `delivery_at` datetime DEFAULT NULL COMMENT '交货时间',
  `sending_at` datetime DEFAULT NULL COMMENT '发货时间',
  `release_at` datetime DEFAULT NULL COMMENT '上线时间',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `receiving_warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `receiving_warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '采购需求计划的状态监控表seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `seq_string` varchar(2000) DEFAULT NULL,
  `size` varchar(1000) DEFAULT NULL,
  `size_dosage_map` text,
  `out_process_order_subtotal_seq` int DEFAULT NULL,
  `proc_material_list_code` varchar(100) DEFAULT NULL COMMENT '委外加工单号',
  `purchase_unit_price` decimal(10,2) DEFAULT NULL COMMENT '采购单价',
  `quarter_code` int DEFAULT NULL COMMENT '季节编号',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位',
  `location_name` varchar(100) DEFAULT NULL COMMENT '储位',
  `remaining_quantity` decimal(13,4) DEFAULT NULL COMMENT '暂收剩余量',
  `inspection_remaining_quantity` decimal(13,4) DEFAULT NULL COMMENT '品检剩余量',
  `inv_remaining_quantity` decimal(13,4) DEFAULT NULL COMMENT '入库剩余量',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_out_process_order_seq` (`out_process_order_seq`),
  KEY `idx_product_order_code` (`product_order_code`),
  KEY `idx_mx_material_info_code` (`mx_material_info_code`),
  KEY `proc_material_out_process_order_info_uuid_index` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=2253 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料外加工单';


--
-- Table structure for table `proc_material_out_process_order_info_size`
--

DROP TABLE IF EXISTS `proc_material_out_process_order_info_size`;


CREATE TABLE `proc_material_out_process_order_info_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `info_uuid` varchar(40) DEFAULT NULL COMMENT '明细uuid',
  `proc_material_list_seq` int DEFAULT NULL COMMENT '采购单序号',
  `proc_material_list_info_seq` int DEFAULT NULL COMMENT '采购单明细序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求单序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划单明细序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体尺码序号',
  `size_seq` int DEFAULT NULL COMMENT '尺码序号',
  `size_code` varchar(50) DEFAULT NULL COMMENT 'size编码',
  `size_name` varchar(50) DEFAULT NULL COMMENT 'size名称',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_size` (`proc_material_list_seq`,`proc_material_list_info_seq`,`size_code`) USING BTREE,
  KEY `idx_proc_material_list_seq_info` (`proc_material_list_seq`,`proc_material_list_info_seq`),
  KEY `idx_size_code` (`size_code`),
  KEY `proc_material_out_process_order_info_size_info_uuid_index` (`info_uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=114413 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='采购单型体各size';


--
-- Table structure for table `proc_material_out_process_order_info_size_dosage`
--

DROP TABLE IF EXISTS `proc_material_out_process_order_info_size_dosage`;


CREATE TABLE `proc_material_out_process_order_info_size_dosage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `out_process_order_seq` int DEFAULT NULL COMMENT '材料外加工单序号',
  `out_process_order_info_seq` int DEFAULT NULL COMMENT '材料外加工单明细序号',
  `info_uuid` varchar(40) DEFAULT NULL COMMENT '明细uuid',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求计划单序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划单明细序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` varchar(255) DEFAULT NULL COMMENT '用量',
  `change_num` decimal(12,4) DEFAULT NULL COMMENT '变更数量',
  `unused_storage` varchar(255) DEFAULT NULL COMMENT '剩余可用量',
  `out_process_order_subtotal_seq` int DEFAULT NULL COMMENT 'sub seq',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_out_process_seq_info_key` (`out_process_order_seq`,`out_process_order_info_seq`,`key`),
  KEY `proc_material_out_process_order_info_size_dosage_info_uuid_index` (`info_uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=8310 DEFAULT CHARSET=utf8mb3 COMMENT='材料外加工单明细部位各码总用量';


--
-- Table structure for table `proc_material_out_process_order_subtotal`
--

DROP TABLE IF EXISTS `proc_material_out_process_order_subtotal`;


CREATE TABLE `proc_material_out_process_order_subtotal` (
  `seq` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `out_process_order_seq` bigint NOT NULL COMMENT '外加工seq',
  `mx_material_category_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `mx_material_category_code` varchar(200) DEFAULT NULL COMMENT '物料简码',
  `mx_material_category_name` text COMMENT '物料简码名称',
  `mx_material_info_seq` int NOT NULL COMMENT '物料编码序号',
  `mx_material_info_code` varchar(300) DEFAULT NULL COMMENT '物料编码',
  `mx_material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料颜色编码',
  `mx_material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '物料颜色名称',
  `mx_material_category_is_match_size` int NOT NULL DEFAULT '0' COMMENT '是否配码 0否 1是',
  `plan_quantity` decimal(18,2) DEFAULT NULL COMMENT '计划数量',
  `system_quantity` decimal(18,2) DEFAULT NULL COMMENT '系统计算采购数量',
  `total_quantity` decimal(18,2) DEFAULT NULL COMMENT '采购总数量',
  `dosage_info` varchar(400) DEFAULT NULL COMMENT '尺码用量信息',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否删除 0未删除 1删除',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `size` varchar(1000) DEFAULT NULL,
  `process_name` varchar(50) DEFAULT NULL COMMENT '制程',
  `material_delivery_time` varchar(50) DEFAULT NULL COMMENT '交期',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库',
  `warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库',
  `location_code` varchar(50) DEFAULT NULL COMMENT '库位',
  `location_name` varchar(50) DEFAULT NULL COMMENT '库位',
  `version` int DEFAULT NULL COMMENT '版本',
  `provider_seq` int DEFAULT NULL,
  `provider_name` varchar(100) DEFAULT NULL,
  `od_order_doc_code` text,
  `out_process_order_subtotal_seq` int DEFAULT NULL COMMENT '汇总表seq',
  `system_plan_storage` decimal(13,4) DEFAULT NULL,
  `current_planned_quantity` decimal(13,4) DEFAULT NULL,
  `total_purchase_quantity` decimal(13,4) DEFAULT NULL,
  `remaining_quantity` decimal(13,4) DEFAULT NULL,
  `return_material_quantity` decimal(13,4) NOT NULL DEFAULT '0.0000' COMMENT '退料数量',
  `created_by` varchar(50) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `od_order_doc_seq` varchar(400) DEFAULT NULL,
  `od_prod_order_seq` varchar(400) DEFAULT NULL,
  `od_prod_order_code` text,
  `manual_prod_code` text COMMENT '手工排产单号',
  `mx_material_category_is_exempt_verify` varchar(50) DEFAULT NULL,
  `art_customer_article_code` text,
  `mx_material_category_provider_type_name` varchar(255) DEFAULT NULL,
  `purchase_unit_price` varchar(200) DEFAULT NULL,
  `position_name` text,
  `sku` text,
  `art_product_class_seq` varchar(255) DEFAULT NULL,
  `art_product_class_name` varchar(255) DEFAULT NULL,
  `art_customer_seq` varchar(255) DEFAULT NULL,
  `art_customer_name` varchar(255) DEFAULT NULL,
  `receiving_warehouse_code` varchar(255) DEFAULT NULL,
  `receiving_warehouse_name` varchar(255) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(255) DEFAULT NULL,
  `size_dosage_map` varchar(1000) DEFAULT NULL,
  `po` varchar(255) DEFAULT NULL,
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  `is_first` int DEFAULT NULL COMMENT '是否首件',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `first_delivery_at` datetime DEFAULT NULL COMMENT '首件交期时间',
  `mx_material_category_unit_name` varchar(50) DEFAULT NULL COMMENT '物料单位名称',
  `mx_material_category_purchase_unit_name` varchar(50) DEFAULT NULL COMMENT '物料采购单位名称',
  `art_color` varchar(200) DEFAULT NULL COMMENT '型体颜色序号',
  `art_color_name` varchar(500) DEFAULT NULL COMMENT '型体颜色',
  `art_name` varchar(500) DEFAULT NULL COMMENT '工厂型体名称',
  `art_code` varchar(200) DEFAULT NULL COMMENT '工厂型体号',
  `mx_material_category_many_purchase_rate` decimal(13,4) DEFAULT NULL COMMENT '物料多采比率',
  `mx_material_category_purchase_hit_rate` decimal(13,4) DEFAULT NULL COMMENT '物料采购打大率',
  `inquiry_price_code` varchar(50) DEFAULT NULL COMMENT '报价单号',
  `proc_material_procurement_code` text COMMENT '采购需求计划单号',
  `first_confirm_date` date DEFAULT NULL COMMENT '第一次交期',
  `second_confirm_date` date DEFAULT NULL COMMENT '第二次交期',
  `third_confirm_date` date DEFAULT NULL COMMENT '第三次交期',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4258 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='外加工物料采购小计信息表';


--
-- Table structure for table `proc_material_out_process_receiving_todo`
--

DROP TABLE IF EXISTS `proc_material_out_process_receiving_todo`;


CREATE TABLE `proc_material_out_process_receiving_todo` (
  `seq` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `out_process_order_seq` int DEFAULT NULL COMMENT '委外加工Seq',
  `out_process_order_info_seq` int DEFAULT NULL,
  `total` decimal(18,2) DEFAULT NULL COMMENT '总量',
  `actual_usage` decimal(18,2) DEFAULT NULL COMMENT '实际用量',
  `remaining_quantity` decimal(18,2) DEFAULT NULL COMMENT '剩余用量',
  `version` int DEFAULT '1' COMMENT '版本号',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否删除 1是 0否',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `mx_material_category_provider_type_seq` int DEFAULT NULL COMMENT '供应商seq',
  `mx_material_category_provider_type_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `mx_material_info_seq` int DEFAULT NULL,
  `mx_material_info_code` varchar(255) DEFAULT NULL,
  `mx_material_category_seq` int DEFAULT NULL,
  `mx_material_category_code` varchar(255) DEFAULT NULL,
  `mx_material_category_name` varchar(500) DEFAULT NULL,
  `mx_material_info_colour` varchar(100) DEFAULT NULL COMMENT '颜色编号',
  `mx_material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `out_process_code` varchar(255) DEFAULT NULL COMMENT '加工单号',
  `product_order_code` varchar(255) DEFAULT NULL COMMENT '生产指令',
  `position_seq` int DEFAULT NULL,
  `position_code` varchar(100) DEFAULT NULL,
  `position_name` varchar(100) DEFAULT NULL,
  `process_name` varchar(50) DEFAULT NULL,
  `provider_seq` int DEFAULT NULL,
  `provider_name` varchar(255) DEFAULT NULL,
  `material_delivery_time` datetime DEFAULT NULL,
  `receiving_company_name` varchar(255) DEFAULT NULL,
  `receiving_company_id` int DEFAULT NULL,
  `provider_type_name` varchar(255) DEFAULT NULL,
  `total_purchase_quantity` decimal(18,4) DEFAULT NULL,
  `purchase_order_number` varchar(255) DEFAULT NULL,
  `out_process_order_code` varchar(255) DEFAULT NULL,
  `mx_material_category_unit_name` varchar(255) DEFAULT NULL,
  `mx_material_category_purchase_hit_rate` decimal(18,4) DEFAULT NULL,
  `mx_material_category_many_purchase_rate` decimal(18,4) DEFAULT NULL,
  `size` varchar(500) DEFAULT NULL,
  `formal_order_code` varchar(255) DEFAULT NULL,
  `row_no` varchar(500) DEFAULT NULL,
  `art_code` varchar(255) DEFAULT NULL,
  `art_customer_article_code` varchar(255) DEFAULT NULL,
  `art_color_name` varchar(255) DEFAULT NULL,
  `art_name` varchar(255) DEFAULT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `art_customer_name` varchar(255) DEFAULT NULL,
  `art_product_class_name` varchar(255) DEFAULT NULL,
  `size_dosage_map` varchar(3000) DEFAULT NULL,
  `seq_string` varchar(2000) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_by_name` varchar(255) DEFAULT NULL,
  `mx_material_category_purchase_unit_name` varchar(255) DEFAULT NULL,
  `receiving_warehouse_code` varchar(255) DEFAULT NULL,
  `receiving_warehouse_name` varchar(255) DEFAULT NULL,
  `receiving_location_code` varchar(255) DEFAULT NULL,
  `receiving_location_name` varchar(255) DEFAULT NULL,
  `mx_material_category_type_name` varchar(100) DEFAULT NULL COMMENT '物料类别名称',
  `mx_material_category_type_seq` int DEFAULT NULL COMMENT '物料类别seq',
  `mx_material_category_class_seq` int DEFAULT NULL COMMENT '物料类别seq',
  `mx_material_category_class_name` varchar(100) DEFAULT NULL COMMENT '物料类别名称',
  `mx_material_category_group_seq` int DEFAULT NULL,
  `mx_material_category_group_name` text,
  `mx_material_category_unit_seq` int DEFAULT NULL,
  `mx_material_category_provider_seq` int DEFAULT NULL,
  `mx_material_category_provider_name` text,
  `mx_material_category_many_receive_rate` decimal(18,4) DEFAULT NULL,
  `plan_storage` decimal(18,4) DEFAULT NULL,
  `STATUS` char(2) DEFAULT NULL,
  `quarter_code` varchar(50) DEFAULT NULL,
  `memo` text,
  `purchase_unit_price` decimal(18,4) DEFAULT NULL,
  `out_process_order_subtotal_seq` int DEFAULT NULL COMMENT '汇总表seq',
  `out_process_total_purchase_quantity` decimal(13,4) DEFAULT NULL,
  `parent_mx_material_category_seq` int DEFAULT NULL COMMENT '组合材料seq',
  `parent_mx_material_category_code` text,
  `parent_mx_material_info_seq` int DEFAULT NULL COMMENT '组合物料编码',
  `parent_mx_material_info_code` varchar(100) DEFAULT NULL COMMENT '组合物料编码',
  `factory` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci COMMENT '出料工厂',
  `factory_id` int DEFAULT NULL COMMENT '出料工厂id',
  `manual_prod_code` varchar(200) DEFAULT NULL COMMENT '指令号',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx` (`out_process_order_seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10716 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='外加工物料接收待办表';


--
-- Table structure for table `proc_material_out_process_temporarily_receiving`
--

DROP TABLE IF EXISTS `proc_material_out_process_temporarily_receiving`;


CREATE TABLE `proc_material_out_process_temporarily_receiving` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `receiving_materials_numbers` varchar(200) DEFAULT NULL COMMENT '收料单号',
  `is_quality_inspection` int DEFAULT '0' COMMENT '是否品检',
  `is_appearance_quality_inspection` int DEFAULT '0' COMMENT '是否外观品检',
  `receiving_date` datetime DEFAULT NULL COMMENT '收货日期',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `receiving_factory_id` int DEFAULT NULL COMMENT '收料工厂id',
  `receiving_factory` varchar(255) DEFAULT NULL COMMENT '收料工厂',
  `consignee` varchar(255) DEFAULT NULL COMMENT '收货人',
  `receiving_department` varchar(255) DEFAULT NULL COMMENT '收货部门',
  `receiving_warehouse` varchar(255) DEFAULT NULL COMMENT '收料仓库',
  `is_attached_receipt` int DEFAULT '0' COMMENT '附收货回单',
  `is_attached_inspection_report` int DEFAULT '0' COMMENT '附验货报告',
  `is_attached_accessories` int DEFAULT '0' COMMENT '附搭配件',
  `is_attached_invoice` int DEFAULT '0' COMMENT '附发票',
  `batch_number` varchar(255) DEFAULT NULL COMMENT '批号',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `is_receive_again` char(1) DEFAULT '0' COMMENT '是否再次接收',
  `created_by_name` varchar(500) DEFAULT NULL COMMENT '创建人名称',
  `zs_type` varchar(255) DEFAULT NULL COMMENT '采购暂收、委外加工单暂收、采购品检不良退暂收、委外加工单品检不良退暂收',
  PRIMARY KEY (`seq`) USING BTREE,
  UNIQUE KEY `codeIdx` (`receiving_materials_numbers`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='加工材料暂收';


--
-- Table structure for table `proc_material_out_process_temporarily_receiving_file`
--

DROP TABLE IF EXISTS `proc_material_out_process_temporarily_receiving_file`;


CREATE TABLE `proc_material_out_process_temporarily_receiving_file` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `proc_material_temporarily_receiving_seq` int NOT NULL DEFAULT '0' COMMENT '材料暂收表seq',
  `attachment_name` varchar(255) DEFAULT NULL COMMENT '附件名称',
  `attachment_type` varchar(255) DEFAULT NULL COMMENT '附件类型',
  `download_path` varchar(255) DEFAULT NULL COMMENT '下载路径',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='加工材料暂收附件';


--
-- Table structure for table `proc_material_out_process_temporarily_receiving_info`
--

DROP TABLE IF EXISTS `proc_material_out_process_temporarily_receiving_info`;


CREATE TABLE `proc_material_out_process_temporarily_receiving_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `proc_material_temporarily_receiving_seq` int DEFAULT NULL COMMENT '材料暂收表seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `proc_material_list_info_seq` int DEFAULT NULL COMMENT '采购单明细序号--对应委外加工单明细seq',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '物料状态监控表seq --对应暂收todo  seq',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批次号',
  `od_prod_order_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `od_prod_order_code` text COMMENT '生产订单号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '正式订单seq',
  `od_order_doc_code` text COMMENT '正式订单号',
  `code` varchar(50) DEFAULT NULL COMMENT '采购单号-委外加工单号',
  `total_purchase_quantity` decimal(13,4) NOT NULL COMMENT '采购数量',
  `receiving_materials_quantity` decimal(13,4) NOT NULL COMMENT '剩余收料数量',
  `total_receiving_materials_quantity` decimal(13,4) NOT NULL COMMENT '总收料数量',
  `delivery_note_number` varchar(50) DEFAULT NULL COMMENT '送货单号',
  `pre_paid_quantity` int NOT NULL DEFAULT '0' COMMENT '预补数量',
  `unit_price` decimal(13,4) DEFAULT NULL COMMENT '单价',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `quantity_of_returned_materials` decimal(11,2) DEFAULT NULL COMMENT '退货数量',
  `allow_collect_more_quantity` decimal(11,2) DEFAULT NULL COMMENT '允许多收数量',
  `allow_collect_less_quantity` decimal(11,2) DEFAULT NULL COMMENT '允许少收数量',
  `duocai_pre_supplement_quantity` decimal(11,2) DEFAULT NULL COMMENT '多采预补数量',
  `disparity` decimal(11,2) DEFAULT NULL COMMENT '差异量',
  `tax_included_unit_price` decimal(11,2) DEFAULT NULL COMMENT '含税单价',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `size_category` int DEFAULT NULL COMMENT '尺码类别',
  `temporary_unit_price` decimal(13,4) unsigned DEFAULT NULL COMMENT '暂收单价',
  `settlement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '结算单价',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `is_receive_again` char(1) DEFAULT '1',
  `warehouse_code` varchar(500) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(500) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(500) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(500) DEFAULT NULL COMMENT '储位名称',
  `source` varchar(255) DEFAULT NULL COMMENT '来源单据',
  `return_materials_number` varchar(255) DEFAULT NULL COMMENT '退料单号',
  `size` varchar(100) DEFAULT NULL COMMENT '规格',
  `out_process_receiving_todo_seq` int DEFAULT NULL COMMENT 'todo加工待办seq',
  `sku` varchar(255) NOT NULL,
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号',
  `is_match_size` int DEFAULT NULL,
  `version` int DEFAULT NULL,
  `mx_material_info_seq` varchar(255) DEFAULT NULL COMMENT '物料seq',
  `mx_material_info_code` varchar(255) DEFAULT NULL COMMENT '编码 ',
  `process_name` varchar(255) DEFAULT NULL COMMENT '制程',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位',
  `manual_prod_code` text COMMENT '指令号',
  `purchase_order_number` varchar(500) DEFAULT NULL COMMENT '采购计划单号',
  `mx_material_category_seq` int DEFAULT NULL COMMENT '简码 seq',
  `mx_material_category_code` varchar(255) DEFAULT NULL COMMENT '简码 ',
  `mx_material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '颜色',
  `out_process_order_subtotal_seq` int DEFAULT NULL COMMENT '汇总seq',
  `material_category_code` varchar(255) DEFAULT NULL,
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  `po` varchar(255) DEFAULT NULL COMMENT 'po',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_od_position_seq_info_size` (`od_product_order_order_position_seq`,`proc_material_list_info_seq`,`size`)
) ENGINE=InnoDB AUTO_INCREMENT=372 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='加工材料暂收明细';


--
-- Table structure for table `proc_material_out_process_temporarily_receiving_info_ext`
--

DROP TABLE IF EXISTS `proc_material_out_process_temporarily_receiving_info_ext`;


CREATE TABLE `proc_material_out_process_temporarily_receiving_info_ext` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `proc_material_temporarily_receiving_seq` int DEFAULT NULL COMMENT '材料暂收表seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `proc_material_list_info_seq` int DEFAULT NULL COMMENT '采购单明细序号--对应委外加工单明细seq',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '物料状态监控表seq --对应暂收todo  seq',
  `proc_material_out_process_temporarily_receiving_seq` int DEFAULT NULL COMMENT '委外暂收主表seq 废弃',
  `proc_material_out_process_temporarily_receiving_info_seq` varchar(255) DEFAULT NULL COMMENT '委外暂收明细表seq',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批次号',
  `od_prod_order_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `od_prod_order_code` text COMMENT '生产订单号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '正式订单seq',
  `od_order_doc_code` text COMMENT '正式订单号',
  `code` varchar(50) DEFAULT NULL COMMENT '采购单号-委外加工单号',
  `total_purchase_quantity` decimal(13,4) DEFAULT NULL COMMENT '采购数量',
  `receiving_materials_quantity` decimal(13,4) DEFAULT NULL COMMENT '剩余收料数量',
  `total_receiving_materials_quantity` decimal(13,4) DEFAULT NULL COMMENT '总收料数量',
  `delivery_note_number` varchar(50) DEFAULT NULL COMMENT '送货单号',
  `pre_paid_quantity` int DEFAULT '0' COMMENT '预补数量',
  `unit_price` decimal(13,4) DEFAULT NULL COMMENT '单价',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `quantity_of_returned_materials` decimal(11,2) DEFAULT NULL COMMENT '退货数量',
  `allow_collect_more_quantity` decimal(11,2) DEFAULT NULL COMMENT '允许多收数量',
  `allow_collect_less_quantity` decimal(11,2) DEFAULT NULL COMMENT '允许少收数量',
  `duocai_pre_supplement_quantity` decimal(11,2) DEFAULT NULL COMMENT '多采预补数量',
  `disparity` decimal(11,2) DEFAULT NULL COMMENT '差异量',
  `tax_included_unit_price` decimal(11,2) DEFAULT NULL COMMENT '含税单价',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `size_category` int DEFAULT NULL COMMENT '尺码类别',
  `temporary_unit_price` decimal(13,4) unsigned DEFAULT NULL COMMENT '暂收单价',
  `settlement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '结算单价',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `is_receive_again` char(1) DEFAULT '1',
  `warehouse_code` varchar(500) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(500) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(500) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(500) DEFAULT NULL COMMENT '储位名称',
  `source` varchar(255) DEFAULT NULL COMMENT '来源单据',
  `return_materials_number` varchar(255) DEFAULT NULL COMMENT '退料单号',
  `size` varchar(100) DEFAULT NULL COMMENT '规格',
  `out_process_receiving_todo_seq` int DEFAULT NULL COMMENT 'todo加工待办seq 废弃',
  `sku` varchar(255) NOT NULL,
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号',
  `is_match_size` int DEFAULT NULL,
  `version` int DEFAULT NULL,
  `mx_material_info_seq` varchar(255) DEFAULT NULL COMMENT '物料seq',
  `mx_material_info_code` varchar(255) DEFAULT NULL COMMENT '编码 ',
  `process_name` varchar(255) DEFAULT NULL COMMENT '制程',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位',
  `purchase_order_number` varchar(500) DEFAULT NULL COMMENT '采购计划单号',
  `mx_material_category_seq` int DEFAULT NULL COMMENT '简码 seq',
  `mx_material_category_code` varchar(255) DEFAULT NULL COMMENT '简码 ',
  `mx_material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '颜色',
  `out_process_order_subtotal_seq` int DEFAULT NULL COMMENT '汇总seq',
  `proc_material_out_process_order_info_seq` int DEFAULT NULL COMMENT '加工单明细seq ',
  `facotry_id` int DEFAULT NULL COMMENT '工厂id',
  `facotry_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `po` varchar(500) DEFAULT NULL COMMENT '订单标识号=行号和生产指令号一一对应',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1469 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='加工材料暂收明细-汇总前';


--
-- Table structure for table `proc_material_procurement`
--

DROP TABLE IF EXISTS `proc_material_procurement`;


CREATE TABLE `proc_material_procurement` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(255) DEFAULT NULL COMMENT '计划单号',
  `type` int DEFAULT NULL COMMENT '计划类型',
  `procurement_type` int DEFAULT NULL COMMENT '采购类型',
  `formal_order_seq` varchar(255) DEFAULT NULL COMMENT '正式订单序号',
  `formal_order_code` varchar(255) DEFAULT NULL COMMENT '正式订单编号（合同号）',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `product_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `manual_prod_code` varchar(100) DEFAULT NULL COMMENT '手工排产单号',
  `art_seq` int DEFAULT NULL COMMENT '产品资料序号',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `sku_logo` varchar(255) DEFAULT NULL COMMENT '产品资料主图',
  `art_code` varchar(255) DEFAULT NULL COMMENT '工厂型体号',
  `art_name` varchar(255) DEFAULT NULL COMMENT '工厂型体名称',
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号',
  `art_quarter_code` varchar(255) DEFAULT NULL COMMENT '产品季度编号',
  `art_color` int DEFAULT NULL COMMENT '产品资料颜色序号',
  `art_color_name` varchar(255) DEFAULT NULL COMMENT '产品资料颜色名称',
  `art_customer_seq` varchar(255) DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(150) DEFAULT NULL COMMENT '客户名称',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `procurement_type_seq` int DEFAULT NULL COMMENT '采购类型序号（字典表序号）存code',
  `procurement_type_name` varchar(255) DEFAULT NULL COMMENT '采购类型名称（字典表名称）',
  `employee` int DEFAULT NULL COMMENT '计划部门',
  `plan_date` date DEFAULT NULL COMMENT '计划时间',
  `demand_date` datetime DEFAULT NULL COMMENT '需求日期',
  `warehouse` varchar(255) DEFAULT NULL COMMENT '承接仓库',
  `warehouse_seq` int DEFAULT NULL COMMENT '承接仓库序号',
  `planner_seq` int DEFAULT NULL COMMENT '计划人序号',
  `planner` varchar(255) DEFAULT NULL COMMENT '计划人',
  `company_seq` int DEFAULT NULL COMMENT '接单工厂序号',
  `company_name` varchar(255) DEFAULT NULL COMMENT '接单工厂名称',
  `status` char(2) DEFAULT '0' COMMENT '状态',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `row_no` varchar(255) DEFAULT NULL COMMENT '行标识',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `enable` tinyint(1) DEFAULT NULL COMMENT '是否可用',
  `created_at` datetime DEFAULT NULL COMMENT '创建日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `material_replenishment_seq` int DEFAULT NULL COMMENT '材料补料单seq',
  `material_replenishment_code` varchar(255) DEFAULT NULL COMMENT '材料补料单code',
  `receiving_department` varchar(255) DEFAULT NULL COMMENT '接单部门',
  `upstream_code` varchar(200) DEFAULT NULL COMMENT '上游单据号',
  `process_status` int DEFAULT NULL COMMENT '数据进度状态',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `manual_prod_code_index` (`manual_prod_code`),
  KEY `proc_material_list_todo` (`manual_prod_code`),
  KEY `idx_proc_material_procurement_sku` (`formal_order_code`,`sku`,`row_no`)
) ENGINE=InnoDB AUTO_INCREMENT=5290 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='采购需求计划';


--
-- Table structure for table `proc_material_procurement_copy_0`
--

DROP TABLE IF EXISTS `proc_material_procurement_copy_0`;


CREATE TABLE `proc_material_procurement_copy_0` (
  `seq` int NOT NULL DEFAULT '0' COMMENT '主键',
  `code` varchar(255) DEFAULT NULL COMMENT '计划单号',
  `type` int DEFAULT NULL COMMENT '计划类型',
  `procurement_type` int DEFAULT NULL COMMENT '采购类型',
  `formal_order_seq` varchar(255) DEFAULT NULL COMMENT '正式订单序号',
  `formal_order_code` varchar(255) DEFAULT NULL COMMENT '正式订单编号（合同号）',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单序号',
  `product_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `manual_prod_code` varchar(100) DEFAULT NULL COMMENT '手工排产单号',
  `art_seq` int DEFAULT NULL COMMENT '产品资料序号',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `sku_logo` varchar(255) DEFAULT NULL COMMENT '产品资料主图',
  `art_code` varchar(255) DEFAULT NULL COMMENT '工厂型体号',
  `art_name` varchar(255) DEFAULT NULL COMMENT '工厂型体名称',
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号',
  `art_quarter_code` varchar(255) DEFAULT NULL COMMENT '产品季度编号',
  `art_color` int DEFAULT NULL COMMENT '产品资料颜色序号',
  `art_color_name` varchar(255) DEFAULT NULL COMMENT '产品资料颜色名称',
  `art_customer_seq` varchar(255) DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(150) DEFAULT NULL COMMENT '客户名称',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `procurement_type_seq` int DEFAULT NULL COMMENT '采购类型序号（字典表序号）存code',
  `procurement_type_name` varchar(255) DEFAULT NULL COMMENT '采购类型名称（字典表名称）',
  `employee` int DEFAULT NULL COMMENT '计划部门',
  `plan_date` date DEFAULT NULL COMMENT '计划时间',
  `demand_date` datetime DEFAULT NULL COMMENT '需求日期',
  `warehouse` varchar(255) DEFAULT NULL COMMENT '承接仓库',
  `warehouse_seq` int DEFAULT NULL COMMENT '承接仓库序号',
  `planner_seq` int DEFAULT NULL COMMENT '计划人序号',
  `planner` varchar(255) DEFAULT NULL COMMENT '计划人',
  `company_seq` int DEFAULT NULL COMMENT '接单工厂序号',
  `company_name` varchar(255) DEFAULT NULL COMMENT '接单工厂名称',
  `status` char(2) DEFAULT '0' COMMENT '状态',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `row_no` varchar(255) DEFAULT NULL COMMENT '行标识',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `enable` tinyint(1) DEFAULT NULL COMMENT '是否可用',
  `created_at` datetime DEFAULT NULL COMMENT '创建日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `material_replenishment_seq` int DEFAULT NULL COMMENT '材料补料单seq',
  `material_replenishment_code` varchar(255) DEFAULT NULL COMMENT '材料补料单code',
  `receiving_department` varchar(255) DEFAULT NULL COMMENT '接单部门',
  `upstream_code` varchar(200) DEFAULT NULL COMMENT '上游单据号',
  `process_status` int DEFAULT NULL COMMENT '数据进度状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `proc_material_procurement_info`
--

DROP TABLE IF EXISTS `proc_material_procurement_info`;


CREATE TABLE `proc_material_procurement_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `proc_material_procurement_seq` int NOT NULL COMMENT '采购需求计划表序号',
  `uuid` varchar(40) DEFAULT NULL COMMENT 'uuid',
  `proc_material_procurement_code` varchar(255) NOT NULL DEFAULT '' COMMENT '采购需求计划单号',
  `od_product_order_order_position_seq` text COMMENT '生产订单与部位关联表seq',
  `quarter_code` int DEFAULT NULL COMMENT '季度编号',
  `product_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `manual_prod_code` varchar(100) DEFAULT NULL COMMENT '手工排产单号',
  `position_seq` int NOT NULL COMMENT '部件序号',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `process_name` varchar(55) DEFAULT NULL COMMENT '制程名称',
  `mx_material_info_seq` int DEFAULT NULL COMMENT '物料编码序号',
  `mx_material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `mx_material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料颜色编码',
  `mx_material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '物料颜色名称',
  `material_parent_seq` int DEFAULT NULL COMMENT '外加工原材料父材料seq',
  `mx_material_category_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `mx_material_category_name` varchar(400) DEFAULT NULL COMMENT '物料简码名称',
  `mx_material_category_code` varchar(100) DEFAULT NULL COMMENT '物料简码',
  `mx_material_category_type_name` varchar(255) DEFAULT NULL COMMENT '物料类型名称',
  `mx_material_category_type_seq` int DEFAULT NULL COMMENT '物料类型序号',
  `mx_material_category_class_seq` varchar(10) DEFAULT NULL COMMENT '物料类别序号',
  `mx_material_category_class_name` varchar(50) DEFAULT NULL COMMENT '物料类别名称',
  `mx_material_category_class_path_name` varchar(100) DEFAULT NULL COMMENT '物料类别路径名称',
  `mx_material_category_group_seq` int DEFAULT NULL COMMENT '物料分组序号',
  `mx_material_category_group_name` varchar(100) DEFAULT NULL COMMENT '物料分组名称',
  `mx_material_category_unit_seq` int DEFAULT NULL COMMENT '物料单位序号',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '物料单位名称',
  `mx_material_category_provider_seq` int DEFAULT NULL COMMENT '物料默认供应商seq',
  `mx_material_category_provider_name` varchar(100) DEFAULT NULL COMMENT '物料默认供应商',
  `mx_material_category_is_exempt_verify` int DEFAULT '0' COMMENT '物料是否免检(0-否,1-是)',
  `mx_material_category_is_out_sourcing` int DEFAULT '0' COMMENT '物料是否外发加工(0-否,1-是)',
  `mx_material_category_is_each_expend` int DEFAULT NULL COMMENT '是否码段用量',
  `mx_material_category_is_match_size` int DEFAULT NULL COMMENT '是否配码',
  `mx_material_category_is_color_constraint` int DEFAULT '0' COMMENT '物料是否颜色约束',
  `mx_material_category_money_type_seq` int DEFAULT NULL COMMENT '物料币种id',
  `mx_material_category_money_type_name` varchar(100) DEFAULT NULL COMMENT '物料币种名称',
  `mx_material_category_purchase_unit_seq` int DEFAULT NULL COMMENT '物料采购单位id',
  `mx_material_category_purchase_unit_name` varchar(100) DEFAULT NULL COMMENT '物料采购单位名称',
  `mx_material_category_purchase_convert_rate` decimal(18,4) DEFAULT NULL COMMENT '物料采购转换比率',
  `mx_material_category_provider_type_seq` int DEFAULT NULL COMMENT '物料供方id',
  `mx_material_category_provider_type_name` varchar(100) DEFAULT NULL COMMENT '物料供方类型',
  `mx_material_category_purchase_hit_rate` decimal(18,4) DEFAULT NULL COMMENT '物料采购打大率',
  `mx_material_category_many_purchase_rate` decimal(18,4) DEFAULT NULL COMMENT '物料允许多采比率',
  `mx_material_category_many_receive_rate` decimal(18,4) DEFAULT NULL COMMENT '物料允许多收比率',
  `storage` double(13,4) DEFAULT NULL COMMENT '需求数量（物料各尺码正式订单数量总和）',
  `system_calculation_quantity` double(13,4) DEFAULT NULL COMMENT '系统计算最大采购量\r\n（需求数量+需求数量*采购大大率）',
  `unused_storage` double(13,4) DEFAULT NULL COMMENT '剩余需求数量（系统计算最大采购量-计划数量）',
  `plan_storage` double(13,4) DEFAULT NULL COMMENT '计划数量（页面输入各尺码计划数量总和）默认等于需求数量',
  `status` char(2) DEFAULT NULL COMMENT '状态\r\n（0：草稿\r\n10：提交\r\n61：审批完成\r\n62：部分创建采购单\r\n63：全部创建采购单\r\n64：部分创建委外加工单\r\n65：全部创建委外加工单）',
  `size_key` varchar(20) DEFAULT NULL COMMENT '尺码',
  `change_type` int DEFAULT NULL COMMENT '变更类型 1修改 2删除 3新增, 4数量变更, 5数量增加, 6数量减少',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `size_category` int(1) unsigned zerofill DEFAULT '0' COMMENT '尺码类别(0-全,1-左,2右)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `material_replenishment_seq` int DEFAULT NULL COMMENT '采购类型序号（字典表序号）存code',
  `material_replenishment_code` varchar(100) DEFAULT NULL,
  `art_customer_name` varchar(100) DEFAULT NULL COMMENT '客户名',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户seq',
  `art_product_class_name` varchar(200) DEFAULT NULL COMMENT '产品类别',
  `receiving_warehouse_code` varchar(100) DEFAULT NULL COMMENT '仓库编号',
  `receiving_warehouse_name` varchar(500) DEFAULT NULL COMMENT '仓库名称',
  `end_delivery_date` varchar(50) DEFAULT NULL COMMENT '交期',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `material_procurement_foregin_key` (`proc_material_procurement_seq`) USING BTREE,
  KEY `uuid_index` (`uuid`),
  KEY `manual_prod_code_index` (`manual_prod_code`),
  CONSTRAINT `material_procurement_foregin_key` FOREIGN KEY (`proc_material_procurement_seq`) REFERENCES `proc_material_procurement` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=1470829 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='采购需求计划物料详情';


--
-- Table structure for table `proc_material_procurement_info_size`
--

DROP TABLE IF EXISTS `proc_material_procurement_info_size`;


CREATE TABLE `proc_material_procurement_info_size` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求单序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求单明细序号',
  `art_size_seq` int DEFAULT NULL COMMENT '型体尺码序号',
  `size_seq` int DEFAULT NULL COMMENT '尺码序号',
  `size_code` varchar(50) DEFAULT NULL COMMENT 'size编码',
  `size_name` varchar(50) DEFAULT NULL COMMENT 'size名称',
  `info_uuid` varchar(40) DEFAULT NULL COMMENT '采购明细uuid',
  `uuid` varchar(40) DEFAULT NULL COMMENT '尺码uuid',
  PRIMARY KEY (`seq`),
  KEY `uuid_index` (`uuid`,`info_uuid`),
  KEY `proc_seq_index` (`proc_material_procurement_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=15651774 DEFAULT CHARSET=utf8mb3 COMMENT='采购需求计划单型体各size';


--
-- Table structure for table `proc_material_procurement_info_size_dosage`
--

DROP TABLE IF EXISTS `proc_material_procurement_info_size_dosage`;


CREATE TABLE `proc_material_procurement_info_size_dosage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proc_material_procurement_seq` int DEFAULT NULL COMMENT '采购需求计划单序号',
  `proc_material_procurement_info_seq` int DEFAULT NULL COMMENT '采购需求计划单明细序号',
  `proc_material_procurement_info_size_seq` int DEFAULT NULL COMMENT '采购需求计划单明细尺码序号',
  `key` varchar(255) DEFAULT NULL COMMENT 'key',
  `each_expend` varchar(255) DEFAULT NULL COMMENT '用量',
  `unused_storage` varchar(255) DEFAULT NULL COMMENT '剩余可用量',
  `info_uuid` varchar(40) DEFAULT NULL COMMENT '采购明细uuid',
  `size_uuid` varchar(40) DEFAULT NULL COMMENT '尺码uuid',
  PRIMARY KEY (`seq`),
  KEY `uuid_index` (`info_uuid`,`size_uuid`),
  KEY `proc_seq_index` (`proc_material_procurement_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=2038491 DEFAULT CHARSET=utf8mb3 COMMENT='采购需求计划单明细部位各码总用量';


--
-- Temporary view structure for view `proc_material_procurement_view`
--

DROP TABLE IF EXISTS `proc_material_procurement_view`;
/*!50001 DROP VIEW IF EXISTS `proc_material_procurement_view`*/;
SET @saved_cs_client     = @@character_set_client;

/*!50001 CREATE VIEW `proc_material_procurement_view` AS SELECT 
 1 AS `mx_material_category_code`,
 1 AS `mx_material_category_purchase_hit_rate`,
 1 AS `mx_material_category_many_purchase_rate`,
 1 AS `mx_material_category_many_receive_rate`,
 1 AS `size_code`,
 1 AS `size_name`,
 1 AS `xql`,
 1 AS `cgl`,
 1 AS `wcg`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `proc_material_quality_spection`
--

DROP TABLE IF EXISTS `proc_material_quality_spection`;


CREATE TABLE `proc_material_quality_spection` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `code` varchar(255) DEFAULT NULL COMMENT '品检单号',
  `test_by` varchar(255) DEFAULT NULL COMMENT '品检员',
  `test_by_username` varchar(255) DEFAULT NULL COMMENT '品检员账号',
  `test_department_name` varchar(255) DEFAULT NULL COMMENT '品检部门',
  `test_department_seq` int DEFAULT NULL COMMENT '品检部门序号',
  `record_status` int DEFAULT '0' COMMENT '品检记录状态',
  `test_date` datetime DEFAULT NULL COMMENT '品检日期',
  `inspection_standards` varchar(255) DEFAULT NULL COMMENT '检验标准',
  `inspection_standards_seq` int DEFAULT NULL COMMENT '检验标准序号',
  `inspection_results` varchar(255) DEFAULT NULL COMMENT '检验结果',
  `inspection_results_seq` int DEFAULT NULL COMMENT '检验结果序号',
  `if_pending` varchar(50) DEFAULT NULL COMMENT '是否待定',
  `status` char(2) DEFAULT '0' COMMENT '状态',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `enable` tinyint(1) DEFAULT NULL COMMENT '是否可用',
  `created_at` datetime DEFAULT NULL COMMENT '创建日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_by_name` varchar(255) DEFAULT NULL COMMENT '创建人名称',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `receiving_factory_id` int DEFAULT NULL COMMENT '收料工厂id',
  `receiving_factory` varchar(50) DEFAULT NULL COMMENT '收料工厂',
  `is_out_sourcing` int DEFAULT NULL COMMENT '0，原材料；1外加工',
  `is_unispection_inv` varchar(500) DEFAULT NULL COMMENT '不合格品是否入库',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=234 DEFAULT CHARSET=utf8mb3 COMMENT='原材料品检';


--
-- Table structure for table `proc_material_quality_spection_info`
--

DROP TABLE IF EXISTS `proc_material_quality_spection_info`;


CREATE TABLE `proc_material_quality_spection_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '物料状态监控表seq',
  `proc_material_quality_spection_seq` int DEFAULT NULL COMMENT '原材料品检单序号',
  `proc_material_temporarily_receiving_info_seq` int DEFAULT NULL COMMENT '材料暂收明细表序号',
  `sampling_quantity` decimal(11,2) DEFAULT NULL COMMENT '抽检数量',
  `sampling_rate` decimal(5,2) DEFAULT NULL COMMENT '抽检比率',
  `qualified_rate` decimal(5,2) DEFAULT NULL COMMENT '合格比率',
  `qualified_quantity` decimal(11,2) DEFAULT NULL COMMENT '合格数量',
  `unqualified_quantity` decimal(11,2) DEFAULT NULL COMMENT '不合格数量',
  `verified_quantity` decimal(11,2) DEFAULT NULL COMMENT '已检数量',
  `inventory_quantity` decimal(11,2) DEFAULT NULL COMMENT '入库数量',
  `inspection_quantity` decimal(11,2) DEFAULT NULL COMMENT '检验数量',
  `accounting_quantity` decimal(11,2) DEFAULT NULL COMMENT '记账数量',
  `not_accounting_quantity` decimal(11,2) DEFAULT NULL COMMENT '不记账数量',
  `if_qualified` int DEFAULT NULL COMMENT '是否合格',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `status` char(2) DEFAULT '0' COMMENT '状态（0：未处理,1:已处理）',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `enable` tinyint(1) DEFAULT NULL COMMENT '是否可用',
  `created_at` datetime DEFAULT NULL COMMENT '创建日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `size_category` int DEFAULT NULL COMMENT '尺码类别',
  `purchase_order_number` varchar(255) DEFAULT NULL COMMENT '采购单号',
  `inspection_unit_price` decimal(12,2) DEFAULT NULL COMMENT '品检单价',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(50) DEFAULT NULL COMMENT '储位名称',
  `delivery_note_number` varchar(100) DEFAULT NULL COMMENT '送货单号',
  `batch_number` varchar(100) DEFAULT NULL COMMENT '送货批次号',
  `receiving_materials_quantity` decimal(11,2) DEFAULT NULL COMMENT '计划品检数量',
  `treat_inspection_quantity` decimal(11,2) DEFAULT NULL COMMENT '待品检的数量',
  `return_materials_number` varchar(255) DEFAULT NULL COMMENT '退料单号',
  `mx_material_info_seq` int DEFAULT NULL COMMENT '物料seq',
  `mx_material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料颜色',
  `art_customer_article_code` text COMMENT '客户型体',
  `size` varchar(100) DEFAULT NULL,
  `sku` varchar(2000) DEFAULT NULL,
  `mx_material_category_code` varchar(255) DEFAULT NULL COMMENT '简码 seq',
  `mx_material_info_code` varchar(255) DEFAULT NULL COMMENT '简码 seq',
  `mx_material_category_seq` varchar(500) DEFAULT NULL COMMENT '物料简码',
  `provider_seq` int DEFAULT NULL COMMENT '供应商',
  `provider_name` varchar(1000) DEFAULT NULL COMMENT '供应商',
  `is_out_sourcing` smallint DEFAULT '0' COMMENT '是否委外单',
  `actual_unqualified_quantity` decimal(11,2) DEFAULT '0.00' COMMENT '实际不合格数量',
  `is_unispection_inv` int DEFAULT '0' COMMENT '不合格品是否退供应商',
  `manual_prod_code` text COMMENT '手工排产单号',
  `position_name` varchar(200) DEFAULT NULL COMMENT '部位昵称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(200) DEFAULT NULL COMMENT '部位编码',
  `receiving_materials_numbers` varchar(200) DEFAULT NULL COMMENT '收货单号',
  `po` varchar(255) DEFAULT NULL,
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  `material_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  PRIMARY KEY (`seq`),
  KEY `qaidx1` (`proc_material_quality_spection_seq`,`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1148 DEFAULT CHARSET=utf8mb3 COMMENT='原材料品检物料明细';


--
-- Table structure for table `proc_material_quality_spection_info_ext`
--

DROP TABLE IF EXISTS `proc_material_quality_spection_info_ext`;


CREATE TABLE `proc_material_quality_spection_info_ext` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '物料状态监控表seq',
  `proc_material_quality_spection_seq` int DEFAULT NULL COMMENT '原材料品检单序号',
  `proc_material_temporarily_receiving_info_seq` int DEFAULT NULL COMMENT '材料暂收明细表序号（含外加工和原材料）',
  `sampling_quantity` decimal(11,2) DEFAULT NULL COMMENT '抽检数量',
  `sampling_rate` decimal(5,2) DEFAULT '10.00' COMMENT '抽检比率',
  `qualified_rate` decimal(5,2) DEFAULT NULL COMMENT '合格比率',
  `qualified_quantity` decimal(11,2) DEFAULT NULL COMMENT '合格数量',
  `unqualified_quantity` decimal(11,2) DEFAULT NULL COMMENT '不合格数量',
  `verified_quantity` decimal(11,2) DEFAULT NULL COMMENT '已检数量',
  `inventory_quantity` decimal(11,2) DEFAULT NULL COMMENT '入库数量',
  `inspection_quantity` decimal(11,2) DEFAULT NULL COMMENT '检验数量',
  `accounting_quantity` decimal(11,2) DEFAULT NULL COMMENT '记账数量',
  `not_accounting_quantity` decimal(11,2) DEFAULT NULL COMMENT '不记账数量',
  `if_qualified` int DEFAULT NULL COMMENT '是否合格',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `status` char(2) DEFAULT '0' COMMENT '状态（0：未处理,1:已处理）',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `enable` tinyint(1) DEFAULT NULL COMMENT '是否可用',
  `created_at` datetime DEFAULT NULL COMMENT '创建日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `size_category` int DEFAULT NULL COMMENT '尺码类别',
  `purchase_order_number` varchar(255) DEFAULT NULL COMMENT '采购单号',
  `inspection_unit_price` decimal(12,2) DEFAULT NULL COMMENT '品检单价',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(50) DEFAULT NULL COMMENT '储位名称',
  `delivery_note_number` varchar(100) DEFAULT NULL COMMENT '送货单号',
  `batch_number` varchar(100) DEFAULT NULL COMMENT '送货批次号',
  `receiving_materials_quantity` decimal(11,2) DEFAULT NULL COMMENT '计划品检数量',
  `treat_inspection_quantity` decimal(11,2) DEFAULT NULL COMMENT '待品检的数量',
  `return_materials_number` varchar(255) DEFAULT NULL COMMENT '退料单号',
  `mx_material_info_seq` int DEFAULT NULL COMMENT '物料seq',
  `mx_material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料颜色',
  `art_customer_article_code` varchar(100) DEFAULT NULL COMMENT '客户型体',
  `size` varchar(100) DEFAULT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `mx_material_category_code` varchar(255) DEFAULT NULL COMMENT '简码 seq',
  `mx_material_info_code` varchar(255) DEFAULT NULL COMMENT '简码 seq',
  `mx_material_category_seq` varchar(500) DEFAULT NULL COMMENT '物料简码',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(1000) DEFAULT NULL COMMENT '供应商',
  `is_out_sourcing` smallint DEFAULT '0' COMMENT '默认为原材料',
  `proc_material_quality_spection_info_seq` int DEFAULT NULL COMMENT '品检单明细seq',
  `proc_material_list_info_seq` int DEFAULT NULL COMMENT '采购单明细seq(is_out_sourcing区分原材料和加工暂收)',
  `product_order_code` varchar(255) DEFAULT NULL,
  `manual_prod_code` text COMMENT '手工排产单号',
  `formal_order_code` varchar(255) DEFAULT NULL,
  `row_no` varchar(255) DEFAULT NULL,
  `subtotal_seq` int DEFAULT NULL,
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `receiving_materials_numbers` varchar(200) DEFAULT NULL COMMENT '收货单号',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `qaidx1` (`proc_material_quality_spection_seq`,`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4142 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='原材料品检物料明细';


--
-- Table structure for table `proc_material_quality_spection_record`
--

DROP TABLE IF EXISTS `proc_material_quality_spection_record`;


CREATE TABLE `proc_material_quality_spection_record` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `proc_material_quality_spection_seq` int DEFAULT NULL COMMENT '原材料品检单序号',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `receiving_factory_id` int DEFAULT NULL COMMENT '收料工厂id',
  `receiving_factory` varchar(50) DEFAULT NULL COMMENT '收料工厂',
  `sku` varchar(2000) DEFAULT NULL,
  `position_name` varchar(200) DEFAULT NULL COMMENT '部位昵称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `provider_seq` int DEFAULT NULL COMMENT '供应商',
  `provider_name` varchar(1000) DEFAULT NULL COMMENT '供应商',
  `mx_material_info_seq` int DEFAULT NULL COMMENT '物料seq',
  `material_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `mx_material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `mx_material_info_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `mx_material_category_seq` varchar(500) DEFAULT NULL COMMENT '物料简码',
  `mx_material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料颜色',
  `size` varchar(100) DEFAULT NULL COMMENT '尺码',
  `unit_seq` int DEFAULT NULL COMMENT '单位seq',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位',
  `purchase_quantity` decimal(14,2) DEFAULT NULL COMMENT '采购数量',
  `temporarily_quantity` decimal(14,2) DEFAULT NULL COMMENT '暂收数量',
  `cacoethic_quantity` decimal(14,2) DEFAULT NULL COMMENT '不良数量',
  `inspection_quantity` decimal(14,2) DEFAULT NULL COMMENT '品检数量',
  `cacoethic_desc` varchar(500) DEFAULT NULL COMMENT '不良描述',
  `cacoethic_img` varchar(100) DEFAULT NULL COMMENT '不良图片',
  `processing_result` varchar(100) DEFAULT NULL COMMENT '处理结果',
  `risk_level` varchar(100) DEFAULT NULL COMMENT '风险等级',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `status` char(2) DEFAULT '0' COMMENT '状态（0：未处理,1:已处理）',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  `created_at` datetime DEFAULT NULL COMMENT '创建日期',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `proc_material_quality_spection_seq` (`proc_material_quality_spection_seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='品检记录';


--
-- Table structure for table `proc_material_quality_spection_todo`
--

DROP TABLE IF EXISTS `proc_material_quality_spection_todo`;


CREATE TABLE `proc_material_quality_spection_todo` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `business_type` int NOT NULL COMMENT '30原材料暂收，31加工材料暂收',
  `business_seq` int DEFAULT NULL COMMENT '业务seq(原材料暂收、加工材料暂收)',
  `business_info_seq` int DEFAULT NULL COMMENT '业务详情seq',
  `total` double(18,4) DEFAULT NULL COMMENT '总量',
  `actual_usage` double(18,4) DEFAULT NULL COMMENT '实际暂收量',
  `remaining_quantity` double(18,4) DEFAULT NULL COMMENT '剩余暂收量',
  `inventory_quantity` double(18,4) DEFAULT '0.0000' COMMENT '实际入库数量',
  `total_inventory_quantity` double(18,4) DEFAULT '0.0000' COMMENT '本次入库量',
  `return_materials_quantity` double(18,4) DEFAULT '0.0000' COMMENT '退料数量',
  `total_return_materials_quantity` double(18,4) DEFAULT '0.0000' COMMENT '本次退料数量',
  `total_accounting_quantity` double(18,4) DEFAULT '0.0000' COMMENT '本次入库记账数量',
  `status` char(2) DEFAULT '0' COMMENT '状态（草稿51提交10待审批20审批中21转办22委派23抄送24退回25驳回26撤回1审批通过50）',
  `material_delivery_time` datetime DEFAULT NULL COMMENT '物料行交期（采购交期）',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '收货人账号',
  `created_by_name` varchar(255) DEFAULT NULL COMMENT '收货人名',
  `created_at` datetime DEFAULT NULL COMMENT '收货时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(50) DEFAULT NULL COMMENT '储位名称',
  `version` int DEFAULT '0' COMMENT '版本号',
  `receiving_factory_id` int DEFAULT NULL,
  `receiving_factory` varchar(255) DEFAULT NULL COMMENT '收料工厂',
  `delivery_note_number` varchar(255) DEFAULT NULL COMMENT '送货单号',
  `batch_number` varchar(255) DEFAULT NULL COMMENT '送货批次号',
  `source` varchar(255) DEFAULT NULL COMMENT '来源单号（材料暂收单、委外暂收单）',
  `art_customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体号',
  `od_prod_order_code` text COMMENT '生产订单号',
  `manual_prod_code` text COMMENT '手工排产单号',
  `od_order_doc_code` text COMMENT '正式订单号',
  `sku` varchar(2000) DEFAULT NULL COMMENT 'sku',
  `mx_material_info_seq` varchar(255) DEFAULT NULL COMMENT '物料seq',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编码',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `size` varchar(255) DEFAULT NULL COMMENT '接收size',
  `receiving_date` datetime DEFAULT NULL COMMENT '收货日期',
  `receiving_department` varchar(255) DEFAULT NULL COMMENT '收货部门',
  `process_name` varchar(255) DEFAULT NULL COMMENT '部位',
  `provider_seq` int DEFAULT NULL COMMENT '供应商',
  `provider_name` varchar(255) DEFAULT NULL,
  `is_out_sourcing` int DEFAULT '0' COMMENT '1\\0\\2',
  `purchase_order_number` varchar(500) DEFAULT NULL COMMENT '采购单号',
  `material_category_seq` int DEFAULT NULL COMMENT '简码 seq',
  `mx_material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '颜色',
  `consignee` varchar(255) DEFAULT NULL COMMENT '收货人',
  `mx_material_category_seq` int DEFAULT NULL COMMENT '简码 seq',
  `mx_material_category_code` varchar(255) DEFAULT NULL COMMENT '简码 seq',
  `art_customer_name` varchar(500) DEFAULT NULL,
  `mx_material_info_code` varchar(500) DEFAULT NULL COMMENT '物料编码',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `po` varchar(255) DEFAULT NULL COMMENT 'po',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `od_product_order_order_position_seq` (`business_seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=971 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='品检待办表';


--
-- Table structure for table `proc_material_requisition`
--

DROP TABLE IF EXISTS `proc_material_requisition`;


CREATE TABLE `proc_material_requisition` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `please_material_code` varchar(100) DEFAULT NULL COMMENT '领料单号',
  `please_material_division` varchar(255) DEFAULT NULL COMMENT '请料部门',
  `picking_type` int DEFAULT NULL COMMENT '领料类型1车间领料出库 ；2加工材料出库；3转仓出库',
  `please_material_date` datetime DEFAULT NULL COMMENT '请料日期',
  `please_material_people` varchar(100) DEFAULT NULL COMMENT '请料人',
  `please_material_factory_id` int DEFAULT NULL,
  `please_material_factory` varchar(255) DEFAULT NULL COMMENT '请料工厂',
  `material_warehouse` varchar(255) DEFAULT NULL COMMENT '发料仓库',
  `please_material_workshop` varchar(255) DEFAULT NULL COMMENT '请料车间',
  `require_issue_date` datetime DEFAULT NULL COMMENT '要求发料日期',
  `workshop_team` varchar(255) DEFAULT NULL COMMENT '车间小组',
  `status` int DEFAULT NULL COMMENT '状态(0暂存，1提交，69待领料，71采购单交期申请待处理, 10提交, 51草稿, 20待审批, 21审批中, 22转办, 23委派, 24抄送, 25退回, 26驳回, 1撤回, 70完成)',
  `source` varchar(255) DEFAULT NULL COMMENT '来源',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_effective` int DEFAULT '0' COMMENT '是否可用(0-否,1-是)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `requisition_factory_id` int DEFAULT NULL COMMENT '发料工厂',
  `requisition_factory` varchar(255) DEFAULT NULL COMMENT '发料工厂',
  `picking_type_name` varchar(255) DEFAULT NULL COMMENT '类型名称',
  `please_material_division_id` int DEFAULT NULL COMMENT '请料部门',
  `workshop_team_id` int DEFAULT NULL COMMENT '车间小组',
  `please_material_workshop_id` int DEFAULT NULL COMMENT '请料车间',
  `requisition_warehouse_id` int DEFAULT NULL COMMENT '发料仓库code',
  `requisition_warehouse` varchar(255) DEFAULT NULL COMMENT '发料仓库',
  `busi_user_name` varchar(255) DEFAULT NULL COMMENT '经办人',
  `requisition_warehouse_code` varchar(255) DEFAULT NULL COMMENT '发料仓库code',
  PRIMARY KEY (`seq`) USING BTREE,
  UNIQUE KEY `idx` (`please_material_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='材料领料';


--
-- Table structure for table `proc_material_requisition_info`
--

DROP TABLE IF EXISTS `proc_material_requisition_info`;


CREATE TABLE `proc_material_requisition_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `proc_material_requisition_seq` int DEFAULT NULL COMMENT '材料领料seq',
  `row_no` varchar(255) DEFAULT NULL COMMENT '行标识也就是PO',
  `order_doc_aritcle_seq` int DEFAULT NULL COMMENT '正式订单型体seq',
  `formal_order_code` varchar(255) DEFAULT NULL COMMENT 'order_doc_cod正式订单号',
  `od_prod_order_seq` int DEFAULT NULL,
  `od_prod_order_code` varchar(255) DEFAULT NULL COMMENT '生产订单号',
  `sku` varchar(255) DEFAULT NULL COMMENT '产品编号',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `planned_quantity` decimal(18,4) DEFAULT NULL COMMENT '计划数量',
  `received_quantity` decimal(18,4) DEFAULT NULL COMMENT '已领数量',
  `order_quantity` decimal(18,4) DEFAULT NULL COMMENT '下单数量',
  `inventory_level` decimal(18,4) DEFAULT NULL COMMENT '库存量',
  `available_inventory` decimal(18,4) DEFAULT NULL COMMENT '可用库存量',
  `mx_material_category_purchase_unit_name` varchar(255) DEFAULT NULL COMMENT '采购单位',
  `mx_material_category_unit_name` varchar(100) DEFAULT NULL COMMENT '单位',
  `material_category_code` varchar(100) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料简码名称',
  `material_info_code` varchar(50) DEFAULT NULL COMMENT '物料编码',
  `material_info_colour_name` varchar(50) DEFAULT NULL COMMENT '物料编码颜色名称',
  `position_seq` int DEFAULT NULL,
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `status` int DEFAULT NULL COMMENT '状态(0暂存，1提交)',
  `is_effective` int DEFAULT '0' COMMENT '是否可用(0-否,1-是)',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `p_seq` int DEFAULT NULL COMMENT '来源单',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '领料仓库',
  `warehouse_name` varchar(255) DEFAULT NULL COMMENT '领料仓库',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位',
  `location_name` varchar(255) DEFAULT NULL COMMENT '储位',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '上游单据seq',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `manual_prod_code` varchar(255) DEFAULT NULL COMMENT '手工排产单号',
  `position_code` varchar(200) DEFAULT NULL COMMENT '部位名称',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `requisition_quantity` decimal(18,4) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL COMMENT '组别派工单',
  `po` varchar(255) DEFAULT NULL COMMENT 'po',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='材料领料详情';


--
-- Table structure for table `proc_material_return`
--

DROP TABLE IF EXISTS `proc_material_return`;


CREATE TABLE `proc_material_return` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `outbound_order_number` varchar(50) DEFAULT NULL COMMENT '出库单号',
  `outbound_type` varchar(50) DEFAULT NULL COMMENT '出库类型',
  `manu_factory` varchar(50) DEFAULT NULL COMMENT '工厂',
  `warehouse` varchar(50) DEFAULT NULL COMMENT '仓库',
  `outbound_date` datetime DEFAULT NULL COMMENT '出库日期',
  `handled_by` varchar(50) DEFAULT NULL COMMENT '经办人',
  `picking_factory` varchar(50) DEFAULT NULL COMMENT '领料工厂',
  `picking_workshop` varchar(50) DEFAULT NULL COMMENT '领料车间',
  `workshop_team` varchar(50) DEFAULT NULL COMMENT '车间小组',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `is_effective` int DEFAULT '1' COMMENT '是否有效(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='材料退回';


--
-- Table structure for table `proc_material_return_apply`
--

DROP TABLE IF EXISTS `proc_material_return_apply`;


CREATE TABLE `proc_material_return_apply` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `apply_code` varchar(30) DEFAULT NULL COMMENT '退料申请单号',
  `apply_type` varchar(20) NOT NULL COMMENT '退料类型',
  `apply_type_name` varchar(100) DEFAULT NULL COMMENT '退料类型名称',
  `apply_date` datetime NOT NULL COMMENT '申请日期',
  `receive_factory_id` int NOT NULL COMMENT '收料工厂',
  `receive_factory_name` varchar(150) NOT NULL COMMENT '收料工厂',
  `receive_warehouse_code` varchar(60) DEFAULT NULL COMMENT '收料仓库编码',
  `receive_warehouse_name` varchar(100) DEFAULT NULL COMMENT '收料仓库',
  `return_apply_factory_id` int DEFAULT NULL COMMENT '退料申请工厂',
  `return_apply_factory_name` varchar(150) DEFAULT NULL COMMENT '退料工厂',
  `return_department_id` int DEFAULT NULL COMMENT '退料部门ID',
  `return_department` varchar(100) DEFAULT NULL COMMENT '退料部门',
  `return_workshop_team_id` int DEFAULT NULL COMMENT '退料车间ID',
  `return_workshop_team` varchar(100) DEFAULT NULL COMMENT '退料车间',
  `handle_user` varchar(50) DEFAULT NULL COMMENT '经办人',
  `print_count` int NOT NULL DEFAULT '0' COMMENT '打印次数',
  `status` int NOT NULL COMMENT '流程状态',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_user_id` varchar(50) DEFAULT NULL COMMENT '创建人ID',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`),
  KEY `proc_material_return_index` (`apply_date`,`apply_code`,`return_apply_factory_id`,`receive_warehouse_code`,`return_workshop_team`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='退料申请单';


--
-- Table structure for table `proc_material_return_apply_info`
--

DROP TABLE IF EXISTS `proc_material_return_apply_info`;


CREATE TABLE `proc_material_return_apply_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `return_apply_seq` int NOT NULL COMMENT '退料申请seq',
  `material_out_bound_seq` int NOT NULL COMMENT '材料出库表seq',
  `material_out_bound_info_seq` int NOT NULL COMMENT '材料出库明细seq',
  `formal_order_code` varchar(100) DEFAULT NULL COMMENT '正式订单号',
  `od_prod_order_code` varchar(100) DEFAULT NULL COMMENT '生产订单号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `picking_code` varchar(50) NOT NULL COMMENT '领料单号',
  `row_no` varchar(255) NOT NULL COMMENT '行标识',
  `sku` varchar(100) NOT NULL COMMENT 'sku',
  `manual_prod_code` varchar(255) NOT NULL COMMENT '指令号',
  `customer_article_code` varchar(100) DEFAULT NULL COMMENT '客户型体号',
  `customer_seq` int NOT NULL COMMENT '客户Id',
  `customer_name` varchar(255) NOT NULL COMMENT '客户名称',
  `group_seq` int DEFAULT NULL COMMENT '物料分组id',
  `group_name` varchar(100) DEFAULT NULL COMMENT '物料分组名称',
  `position_seq` int NOT NULL COMMENT '部位seq',
  `position_name` varchar(100) NOT NULL COMMENT '部位名称',
  `position_code` varchar(100) NOT NULL COMMENT '部位编码',
  `material_category_seq` int NOT NULL COMMENT '物料简码seq',
  `material_category_code` varchar(100) NOT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) NOT NULL COMMENT '物料名称',
  `material_info_seq` int NOT NULL COMMENT '物料编码seq',
  `material_info_code` varchar(100) NOT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '颜色code',
  `material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '材料颜色名称',
  `material_category_unit_name` varchar(100) NOT NULL COMMENT '物料基本单位',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(300) DEFAULT NULL COMMENT '供应商名称',
  `size` varchar(100) DEFAULT NULL COMMENT '尺码',
  `out_bound_quantity` decimal(13,4) NOT NULL COMMENT '已出库数量',
  `apply_return_materials_number` decimal(13,4) NOT NULL DEFAULT '0.0000' COMMENT '退料申请数量 不得大于已领用数量',
  `store_in_total` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT '已入库数量',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_user_id` varchar(50) DEFAULT NULL COMMENT '创建人ID',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='退料申请单明细';


--
-- Table structure for table `proc_material_return_scene_apply`
--

DROP TABLE IF EXISTS `proc_material_return_scene_apply`;


CREATE TABLE `proc_material_return_scene_apply` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `apply_code` varchar(30) DEFAULT NULL COMMENT '现场退料申请单号',
  `apply_type` varchar(20) NOT NULL COMMENT '退料类型',
  `apply_type_name` varchar(50) DEFAULT NULL COMMENT '申请类型翻译',
  `apply_date` datetime NOT NULL COMMENT '申请日期',
  `receive_factory_id` int NOT NULL COMMENT '收料工厂',
  `receive_factory_name` varchar(150) NOT NULL COMMENT '收料工厂',
  `receive_warehouse_code` varchar(60) DEFAULT NULL COMMENT '收料仓库编码',
  `receive_warehouse_name` varchar(100) DEFAULT NULL COMMENT '收料仓库',
  `return_apply_factory_id` int DEFAULT NULL COMMENT '退料申请工厂',
  `return_apply_factory_name` varchar(150) DEFAULT NULL COMMENT '退料工厂',
  `return_department_id` int DEFAULT NULL COMMENT '退料部门ID',
  `return_department` varchar(100) DEFAULT NULL COMMENT '退料部门',
  `return_workshop_team_id` int DEFAULT NULL COMMENT '退料车间ID',
  `return_workshop_team` varchar(100) DEFAULT NULL COMMENT '退料车间',
  `handle_user` varchar(50) DEFAULT NULL COMMENT '经办人',
  `print_count` int NOT NULL DEFAULT '0' COMMENT '打印次数',
  `status` int NOT NULL COMMENT '流程状态',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `submit_at` datetime DEFAULT NULL COMMENT '提交时间',
  `created_user_id` varchar(50) DEFAULT NULL COMMENT '创建人ID',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`),
  KEY `proc_material_return_scene_index` (`apply_date`,`apply_code`,`return_apply_factory_id`,`receive_warehouse_code`,`return_workshop_team`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='现场材料退料申请单';


--
-- Table structure for table `proc_material_return_scene_apply_info`
--

DROP TABLE IF EXISTS `proc_material_return_scene_apply_info`;


CREATE TABLE `proc_material_return_scene_apply_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `return_scene_apply_seq` int NOT NULL COMMENT '现场材料退料seq',
  `return_apply_seq` int NOT NULL COMMENT '退料申请seq',
  `return_apply_info_seq` int NOT NULL COMMENT '退料申请明细seq',
  `return_apply_code` varchar(100) NOT NULL COMMENT '退料申请单号',
  `picking_code` varchar(100) NOT NULL COMMENT '领料申请单号',
  `formal_order_code` varchar(100) DEFAULT NULL COMMENT '正式订单号',
  `od_prod_order_code` varchar(100) DEFAULT NULL COMMENT '生产订单号',
  `product_order_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `customer_seq` int NOT NULL COMMENT '客户Id',
  `customer_name` varchar(255) NOT NULL COMMENT '客户名称',
  `row_no` varchar(255) NOT NULL COMMENT '行标识',
  `sku` varchar(100) NOT NULL COMMENT 'sku',
  `manual_prod_code` varchar(255) NOT NULL COMMENT '指令号',
  `customer_article_code` varchar(100) DEFAULT NULL COMMENT '客户型体号',
  `group_seq` int DEFAULT NULL COMMENT '物料分组id',
  `group_name` varchar(100) DEFAULT NULL COMMENT '物料分组名称',
  `position_seq` int NOT NULL COMMENT '部位seq',
  `position_name` varchar(100) NOT NULL COMMENT '部位名称',
  `position_code` varchar(100) NOT NULL COMMENT '部位编码',
  `material_category_seq` int NOT NULL COMMENT '物料简码seq',
  `material_category_code` varchar(100) NOT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) NOT NULL COMMENT '物料名称',
  `material_info_seq` int NOT NULL COMMENT '物料编码seq',
  `material_info_code` varchar(100) NOT NULL COMMENT '物料编码',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '颜色code',
  `material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '材料颜色名称',
  `material_category_unit_name` varchar(100) NOT NULL COMMENT '物料基本单位',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(300) DEFAULT NULL COMMENT '供应商名称',
  `size` varchar(100) DEFAULT NULL COMMENT '尺码',
  `apply_return_materials_number` decimal(13,4) NOT NULL DEFAULT '0.0000' COMMENT '退料申请数量',
  `warehouse_quantity_in` decimal(13,4) NOT NULL COMMENT '入库数量 不得大于申请数量 ',
  `factory_id` int DEFAULT NULL COMMENT '工厂ID',
  `factory_name` varchar(100) DEFAULT NULL COMMENT '工厂名称',
  `warehouse_code` varchar(100) NOT NULL COMMENT '仓库编码',
  `warehouse_name` varchar(80) NOT NULL COMMENT '仓库名称',
  `location_code` varchar(80) NOT NULL COMMENT '储位编号',
  `location_name` varchar(80) NOT NULL COMMENT '储位名称',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_user_id` varchar(50) DEFAULT NULL COMMENT '创建人ID',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='现场材料退料申请单明细';


--
-- Table structure for table `proc_material_status_monitor_info`
--

DROP TABLE IF EXISTS `proc_material_status_monitor_info`;


CREATE TABLE `proc_material_status_monitor_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `uuid` varchar(40) DEFAULT NULL,
  `business_type` int NOT NULL COMMENT '业务类型(10需求计划，20采购单，30暂收，31委外暂收，40品检，50退料，60入库，70领料，71领料待处理，80出库，81委外领料，82转仓入库，83委外出库料，)',
  `business_seq` int DEFAULT NULL COMMENT '业务seq',
  `business_info_seq` int DEFAULT NULL COMMENT '业务详情seq',
  `total` double(18,4) DEFAULT NULL COMMENT '总量',
  `actual_usage` double(18,4) DEFAULT NULL COMMENT '实际用量',
  `remaining_quantity` double(18,4) DEFAULT NULL COMMENT '剩余用量',
  `total_inventory_quantity` double(18,4) DEFAULT '0.0000' COMMENT '累计入库量',
  `inventory_quantity` double(18,4) DEFAULT '0.0000' COMMENT '入库数量',
  `return_materials_quantity` double(18,4) DEFAULT '0.0000' COMMENT '退料数量',
  `total_return_materials_quantity` double(18,4) DEFAULT '0.0000',
  `status` char(2) DEFAULT '0' COMMENT '状态（草稿51提交10待审批20审批中21转办22委派23抄送24退回25驳回26撤回1审批通过50）',
  `material_delivery_time` datetime DEFAULT NULL COMMENT '物料行交期',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `enable` int DEFAULT '1' COMMENT '是否启用（0：未启用；1：已启用）',
  `p_seq` int DEFAULT NULL COMMENT '父seq',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(50) DEFAULT NULL COMMENT '储位名称',
  `to_warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `to_warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `to_location_code` varchar(50) DEFAULT NULL COMMENT '储位编号',
  `to_location_name` varchar(50) DEFAULT NULL COMMENT '储位名称',
  `version` int DEFAULT '0' COMMENT '版本号',
  `total_accounting_quantity` double(18,4) DEFAULT '0.0000' COMMENT '累计入库记账数量',
  PRIMARY KEY (`seq`),
  KEY `od_product_order_order_position_seq` (`od_product_order_order_position_seq`),
  KEY `uuid_index` (`uuid`),
  KEY `index_proc_material_status_monitor_info_1` (`business_type`,`business_info_seq`,`remaining_quantity`)
) ENGINE=InnoDB AUTO_INCREMENT=1330437 DEFAULT CHARSET=utf8mb3 COMMENT='物料状态监控表';


--
-- Table structure for table `proc_material_status_monitor_info_copy1`
--

DROP TABLE IF EXISTS `proc_material_status_monitor_info_copy1`;


CREATE TABLE `proc_material_status_monitor_info_copy1` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `business_type` int NOT NULL COMMENT '业务类型(10需求计划，20采购单，30暂收，40品检，50退料，60入库，70领料，71领料待处理，80出库，81委外领料，82转仓入库，83委外出库料，)',
  `business_seq` int DEFAULT NULL COMMENT '业务seq',
  `business_info_seq` int DEFAULT NULL COMMENT '业务详情seq',
  `total` double(18,4) DEFAULT NULL COMMENT '总量',
  `actual_usage` double(18,4) DEFAULT NULL COMMENT '实际用量',
  `remaining_quantity` double(18,4) DEFAULT NULL COMMENT '剩余用量',
  `total_inventory_quantity` double(18,4) DEFAULT '0.0000' COMMENT '累计入库量',
  `inventory_quantity` double(18,4) DEFAULT '0.0000' COMMENT '入库数量',
  `return_materials_quantity` double(18,4) DEFAULT '0.0000' COMMENT '退料数量',
  `total_return_materials_quantity` double(18,4) DEFAULT '0.0000',
  `status` char(2) DEFAULT '0' COMMENT '状态（草稿51提交10待审批20审批中21转办22委派23抄送24退回25驳回26撤回1审批通过50）',
  `material_delivery_time` datetime DEFAULT NULL COMMENT '物料行交期',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `enable` int DEFAULT '1' COMMENT '是否启用（0：未启用；1：已启用）',
  `p_seq` int DEFAULT NULL COMMENT '父seq',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(50) DEFAULT NULL COMMENT '储位名称',
  `to_warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `to_warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `to_location_code` varchar(50) DEFAULT NULL COMMENT '储位编号',
  `to_location_name` varchar(50) DEFAULT NULL COMMENT '储位名称',
  `version` int DEFAULT '0' COMMENT '版本号',
  `total_accounting_quantity` double(18,4) DEFAULT '0.0000' COMMENT '累计入库记账数量',
  PRIMARY KEY (`seq`),
  KEY `od_product_order_order_position_seq` (`od_product_order_order_position_seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='物料状态监控表';


--
-- Table structure for table `proc_material_temporarily_receiving`
--

DROP TABLE IF EXISTS `proc_material_temporarily_receiving`;


CREATE TABLE `proc_material_temporarily_receiving` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `receiving_materials_numbers` varchar(200) DEFAULT NULL COMMENT '收料单号',
  `is_quality_inspection` int DEFAULT '0' COMMENT '是否品检',
  `is_appearance_quality_inspection` int DEFAULT '0' COMMENT '是否外观品检',
  `receiving_date` datetime DEFAULT NULL COMMENT '收货日期',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `receiving_factory` varchar(255) DEFAULT NULL COMMENT '收料工厂',
  `consignee` varchar(255) DEFAULT NULL COMMENT '收货人',
  `receiving_department` varchar(255) DEFAULT NULL COMMENT '收货部门',
  `receiving_warehouse` varchar(255) DEFAULT NULL COMMENT '收料仓库',
  `is_attached_receipt` int DEFAULT '0' COMMENT '附收货回单',
  `is_attached_inspection_report` int DEFAULT '0' COMMENT '附验货报告',
  `is_attached_accessories` int DEFAULT '0' COMMENT '附搭配件',
  `is_attached_invoice` int DEFAULT '0' COMMENT '附发票',
  `batch_number` varchar(255) DEFAULT NULL COMMENT '批号',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `is_receive_again` char(1) DEFAULT '1' COMMENT '是否重收',
  `receiving_factory_id` int DEFAULT NULL COMMENT '收料工厂id',
  `created_by_name` varchar(500) DEFAULT NULL COMMENT '创建人名称',
  `proc_material_list_info_code` text COMMENT '采购单号',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb3 COMMENT='材料暂收';


--
-- Table structure for table `proc_material_temporarily_receiving_file`
--

DROP TABLE IF EXISTS `proc_material_temporarily_receiving_file`;


CREATE TABLE `proc_material_temporarily_receiving_file` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `proc_material_temporarily_receiving_seq` int NOT NULL DEFAULT '0' COMMENT '材料暂收表seq',
  `attachment_name` varchar(255) DEFAULT NULL COMMENT '附件名称',
  `attachment_type` varchar(255) DEFAULT NULL COMMENT '附件类型',
  `download_path` varchar(255) DEFAULT NULL COMMENT '下载路径',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='材料暂收附件';


--
-- Table structure for table `proc_material_temporarily_receiving_info`
--

DROP TABLE IF EXISTS `proc_material_temporarily_receiving_info`;


CREATE TABLE `proc_material_temporarily_receiving_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `proc_material_temporarily_receiving_seq` int DEFAULT NULL COMMENT '材料暂收表seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `proc_material_list_info_seq` int DEFAULT NULL COMMENT '采购单明细序号',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '物料状态监控表seq',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批次号',
  `od_prod_order_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `od_prod_order_code` text COMMENT '生产订单号',
  `manual_prod_code` text COMMENT '手工排产单号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '正式订单seq',
  `od_order_doc_code` text COMMENT '正式订单号',
  `code` varchar(50) DEFAULT NULL COMMENT '采购单号',
  `total_purchase_quantity` decimal(13,4) NOT NULL DEFAULT '0.0000' COMMENT '采购数量',
  `receiving_materials_quantity` decimal(13,4) NOT NULL DEFAULT '0.0000' COMMENT '剩余收料数量',
  `total_receiving_materials_quantity` decimal(13,4) NOT NULL DEFAULT '0.0000' COMMENT '总收料数量',
  `delivery_note_number` varchar(50) DEFAULT NULL COMMENT '送货单号',
  `pre_paid_quantity` int NOT NULL DEFAULT '0' COMMENT '预补数量',
  `unit_price` decimal(13,4) DEFAULT NULL COMMENT '单价',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `quantity_of_returned_materials` decimal(11,2) DEFAULT NULL COMMENT '退货数量',
  `allow_collect_more_quantity` decimal(11,2) DEFAULT NULL COMMENT '允许多收数量',
  `allow_collect_less_quantity` decimal(11,2) DEFAULT NULL COMMENT '允许少收数量',
  `duocai_pre_supplement_quantity` decimal(11,2) DEFAULT NULL COMMENT '多采预补数量',
  `disparity` decimal(11,2) DEFAULT NULL COMMENT '差异量',
  `tax_included_unit_price` decimal(11,2) DEFAULT NULL COMMENT '含税单价',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `size_category` int DEFAULT NULL COMMENT '尺码类别',
  `temporary_unit_price` decimal(13,4) unsigned DEFAULT '0.0000' COMMENT '暂收单价',
  `settlement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '结算单价',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `is_receive_again` char(1) DEFAULT '1',
  `warehouse_code` varchar(500) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(500) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(500) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(500) DEFAULT NULL COMMENT '储位名称',
  `source` varchar(255) DEFAULT NULL COMMENT '来源单据',
  `return_materials_number` varchar(255) DEFAULT NULL COMMENT '退料单号',
  `size` int DEFAULT NULL,
  `proc_material_list_info_sum_seq` int DEFAULT NULL COMMENT '采购明细seq',
  `material_category_seq` int DEFAULT NULL COMMENT '物料seq',
  `proc_material_list_info_code` varchar(150) DEFAULT NULL COMMENT '采购单号',
  `art_customer_article_code` varchar(150) DEFAULT NULL COMMENT '客户型体号',
  `art_code` text COMMENT '工厂型体号',
  `material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '颜色',
  `sku` varchar(500) DEFAULT NULL COMMENT 'sku',
  `material_category_code` varchar(255) DEFAULT NULL,
  `material_info_seq` int DEFAULT NULL,
  `material_info_code` varchar(255) DEFAULT NULL,
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `po` varchar(255) DEFAULT NULL COMMENT 'po',
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_ra_order_position_info` (`od_prod_order_seq`,`od_product_order_order_position_seq`,`proc_material_list_info_seq`),
  KEY `idx_od_position_seq_info_size` (`od_product_order_order_position_seq`,`proc_material_list_info_seq`,`size`)
) ENGINE=InnoDB AUTO_INCREMENT=575 DEFAULT CHARSET=utf8mb3 COMMENT='材料暂收明细';


--
-- Table structure for table `proc_material_temporarily_receiving_info_ext`
--

DROP TABLE IF EXISTS `proc_material_temporarily_receiving_info_ext`;


CREATE TABLE `proc_material_temporarily_receiving_info_ext` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `proc_material_temporarily_receiving_seq` int DEFAULT NULL COMMENT '材料暂收表seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `proc_material_list_info_seq` varchar(500) DEFAULT NULL COMMENT '采购单明细序号集',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '物料状态监控表seq',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批次号',
  `od_prod_order_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `od_prod_order_code` text COMMENT '生产订单号',
  `od_order_doc_seq` int DEFAULT NULL COMMENT '正式订单seq',
  `od_order_doc_code` text COMMENT '正式订单号',
  `code` varchar(50) DEFAULT NULL COMMENT '采购单号',
  `manual_prod_code` varchar(200) DEFAULT NULL COMMENT '指令号',
  `total_purchase_quantity` decimal(13,4) NOT NULL COMMENT '采购数量',
  `receiving_materials_quantity` decimal(13,4) NOT NULL COMMENT '剩余收料数量',
  `total_receiving_materials_quantity` decimal(13,4) NOT NULL COMMENT '总收料数量',
  `delivery_note_number` varchar(50) DEFAULT NULL COMMENT '送货单号',
  `pre_paid_quantity` int NOT NULL DEFAULT '0' COMMENT '预补数量',
  `unit_price` decimal(13,4) DEFAULT NULL COMMENT '单价',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `quantity_of_returned_materials` decimal(11,2) DEFAULT NULL COMMENT '退货数量',
  `allow_collect_more_quantity` decimal(11,2) DEFAULT NULL COMMENT '允许多收数量',
  `allow_collect_less_quantity` decimal(11,2) DEFAULT NULL COMMENT '允许少收数量',
  `duocai_pre_supplement_quantity` decimal(11,2) DEFAULT NULL COMMENT '多采预补数量',
  `disparity` decimal(11,2) DEFAULT NULL COMMENT '差异量',
  `tax_included_unit_price` decimal(11,2) DEFAULT NULL COMMENT '含税单价',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `size_category` int DEFAULT NULL COMMENT '尺码类别',
  `temporary_unit_price` decimal(13,4) unsigned DEFAULT NULL COMMENT '暂收单价',
  `settlement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '结算单价',
  `art_product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `art_product_class_name` varchar(255) DEFAULT NULL COMMENT '产品类别名称',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `is_receive_again` char(1) DEFAULT '1',
  `warehouse_code` varchar(500) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(500) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(500) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(500) DEFAULT NULL COMMENT '储位名称',
  `source` varchar(255) DEFAULT NULL COMMENT '来源单据',
  `return_materials_number` varchar(255) DEFAULT NULL COMMENT '退料单号',
  `size` varchar(1000) DEFAULT NULL,
  `proc_material_list_info_sum_seq` int DEFAULT NULL COMMENT '采购明细seq',
  `material_category_seq` int DEFAULT NULL COMMENT '物料seq',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码sql',
  `material_info_code` varchar(255) DEFAULT NULL COMMENT '物料编码code',
  `proc_material_list_info_code` varchar(150) DEFAULT NULL COMMENT '采购单号',
  `art_customer_article_code` varchar(150) DEFAULT NULL COMMENT '客户型体号',
  `material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '颜色',
  `sku` varchar(500) DEFAULT NULL COMMENT 'sku',
  `proc_material_temporarily_receiving_info_seq` int DEFAULT NULL COMMENT '暂收表明细seq',
  `subtotal_seq` int DEFAULT NULL COMMENT '汇总行seq',
  `facotry_id` int DEFAULT NULL COMMENT '工厂id',
  `facotry_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `po` varchar(500) DEFAULT NULL COMMENT '订单标识号=行号和生产指令号一一对应',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `idx_rinfo_order_position_size` (`od_product_order_order_position_seq`,`size`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3243 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料暂收明细';


--
-- Table structure for table `proc_material_temporarily_receiving_requirements`
--

DROP TABLE IF EXISTS `proc_material_temporarily_receiving_requirements`;


CREATE TABLE `proc_material_temporarily_receiving_requirements` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `proc_material_temporarily_receiving_seq` int NOT NULL DEFAULT '0' COMMENT '材料暂收表seq',
  `requirements_name` varchar(255) DEFAULT NULL COMMENT '名称',
  `requirements_content` varchar(255) DEFAULT NULL COMMENT '内容',
  `requirements_desc` varchar(255) DEFAULT NULL COMMENT '说明',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='材料暂收特殊要求';


--
-- Table structure for table `proc_material_warehousing`
--

DROP TABLE IF EXISTS `proc_material_warehousing`;


CREATE TABLE `proc_material_warehousing` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `warehouse_entry_number` varchar(50) DEFAULT NULL COMMENT '入库单号',
  `manu_factory` varchar(50) DEFAULT NULL COMMENT '工厂',
  `handled_by` varchar(50) DEFAULT NULL COMMENT '经办人',
  `warehouse_entry_date` datetime DEFAULT NULL COMMENT '入库时间',
  `position` varchar(50) DEFAULT NULL COMMENT '仓位',
  `invoice_number` varchar(50) DEFAULT NULL COMMENT '发票号码',
  `material_properties` varchar(50) DEFAULT NULL COMMENT '物料性质',
  `storage_location` varchar(50) DEFAULT NULL COMMENT '储位',
  `personal_account` varchar(50) DEFAULT NULL COMMENT '来往账户',
  `storage_type` varchar(50) DEFAULT NULL COMMENT '入库类型',
  `supplier` varchar(50) DEFAULT NULL COMMENT '供应商',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `is_effective` int DEFAULT '0' COMMENT '是否有效(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `upstream_status` varchar(10) DEFAULT NULL COMMENT '上游状态',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `inventory_quantity` decimal(20,2) DEFAULT NULL COMMENT '入库数量',
  `already_settlement_quantity` decimal(20,2) unsigned DEFAULT '0.00' COMMENT '已结算数量',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `manu_factory_id` int DEFAULT NULL COMMENT '收料工厂id',
  `supplier_reconciliation_status` int DEFAULT '0' COMMENT '供应商对账状态',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `is_unispection_inv` int DEFAULT '0' COMMENT '不合格品是否入库',
  `printing_frequency` int DEFAULT '0' COMMENT '打印次数',
  PRIMARY KEY (`seq`),
  UNIQUE KEY `codeIdx` (`warehouse_entry_number`)
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8mb3 COMMENT='材料入库';


--
-- Table structure for table `proc_material_warehousing_info`
--

DROP TABLE IF EXISTS `proc_material_warehousing_info`;


CREATE TABLE `proc_material_warehousing_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `proc_material_warehousing_seq` int DEFAULT NULL COMMENT '材料入库单主表seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '物料状态监控表seq',
  `inventory_quantity_purchase` decimal(11,4) DEFAULT NULL COMMENT '入库数量（采购单位）',
  `this_time_inventory_quantity` decimal(11,4) DEFAULT NULL COMMENT '本次入库量',
  `pluralistic_number` decimal(11,4) DEFAULT NULL COMMENT '多采数量',
  `accounting_quantity` decimal(11,4) DEFAULT NULL COMMENT '记账数量',
  `storage_location` varchar(50) DEFAULT NULL COMMENT '储位',
  `receiving_quantity` decimal(11,4) DEFAULT NULL COMMENT '收料量',
  `receiving_materials_quantity` varchar(255) DEFAULT NULL,
  `purchase_quantity` decimal(11,4) DEFAULT NULL COMMENT '采购数量',
  `quality_inspection_qualified_quantity` decimal(11,4) DEFAULT NULL COMMENT '品检合格数量',
  `purchase_order_number` varchar(255) DEFAULT NULL COMMENT '采购单号',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批次号',
  `if_qualified` char(1) DEFAULT NULL COMMENT '是否合格',
  `status` char(2) DEFAULT '0' COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `size_category` int DEFAULT NULL COMMENT '尺码类别',
  `already_settlement_quantity` decimal(20,4) unsigned DEFAULT '0.0000' COMMENT '已结算数量',
  `store_unit_price` decimal(13,4) unsigned DEFAULT '0.0000' COMMENT '入库单价',
  `store_rate` decimal(13,4) DEFAULT NULL,
  `settlement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '结算单价',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `location_name` varchar(50) NOT NULL COMMENT '储位名称',
  `location_code` varchar(50) NOT NULL COMMENT '储位编号',
  `warehouse_name` varchar(50) NOT NULL COMMENT '仓库名称',
  `warehouse_code` varchar(50) NOT NULL COMMENT '仓库编号',
  `delivery_note_number` varchar(100) DEFAULT NULL COMMENT '送货单号',
  `mx_material_category_unit_seq` int DEFAULT NULL,
  `mx_material_category_unit_name` varchar(255) DEFAULT NULL,
  `mx_material_category_purchase_unit_seq` int DEFAULT NULL,
  `mx_material_category_purchase_unit_name` varchar(255) DEFAULT NULL,
  `return_qty` decimal(11,4) DEFAULT NULL,
  `many_receive_rate` decimal(11,4) DEFAULT NULL,
  `return_materials_number` varchar(255) DEFAULT NULL COMMENT '退料单号',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `size` varchar(255) DEFAULT NULL,
  `is_unispection_inv` int DEFAULT '0' COMMENT '不合格品是否入库',
  `unqualified_quantity` decimal(11,4) DEFAULT NULL COMMENT '抽检不合格数量',
  `actual_unqualified_quantity` decimal(11,4) DEFAULT NULL COMMENT '实际不合格数量',
  `sku` varchar(500) DEFAULT NULL,
  `mx_material_info_seq` int DEFAULT NULL COMMENT '物料编码',
  `mx_material_info_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `mx_material_category_seq` int DEFAULT NULL COMMENT '物料简码',
  `mx_material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `quarter_code` int DEFAULT NULL COMMENT '季度',
  `mx_material_category_Name` text COMMENT '物料名称',
  `uninspection_quantity` decimal(18,4) DEFAULT NULL COMMENT '不合格数量（后版废弃使用，用实际不合格数量）',
  `mx_material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '物料颜色',
  `manual_prod_code` varchar(200) DEFAULT NULL COMMENT '指令号',
  `quality_code` varchar(50) DEFAULT NULL COMMENT '品检单号',
  `po` varchar(255) DEFAULT NULL COMMENT 'po',
  `sampling_quantity` decimal(11,2) DEFAULT NULL COMMENT '抽检数量',
  `sampling_rate` decimal(5,2) DEFAULT NULL COMMENT '抽检比率',
  `art_customer_article_code` text COMMENT '客户型体号',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编码',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=679 DEFAULT CHARSET=utf8mb3 COMMENT='材料入库单明细';


--
-- Table structure for table `proc_material_warehousing_info_ext`
--

DROP TABLE IF EXISTS `proc_material_warehousing_info_ext`;


CREATE TABLE `proc_material_warehousing_info_ext` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `proc_material_warehousing_seq` int DEFAULT NULL COMMENT '材料入库单主表seq',
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `proc_material_status_monitor_info_seq` int DEFAULT NULL COMMENT '物料状态监控表seq',
  `inventory_quantity_purchase` decimal(11,4) DEFAULT NULL COMMENT '入库数量（采购单位）',
  `this_time_inventory_quantity` decimal(11,4) DEFAULT NULL COMMENT '本次入库量',
  `pluralistic_number` decimal(11,4) DEFAULT NULL COMMENT '多采数量',
  `accounting_quantity` decimal(11,4) DEFAULT NULL COMMENT '记账数量',
  `storage_location` varchar(50) DEFAULT NULL COMMENT '储位',
  `receiving_quantity` decimal(11,4) DEFAULT NULL COMMENT '收料量',
  `receiving_materials_quantity` varchar(255) DEFAULT NULL,
  `purchase_quantity` decimal(11,4) DEFAULT NULL COMMENT '采购数量',
  `quality_inspection_qualified_quantity` decimal(11,4) DEFAULT NULL COMMENT '品检合格数量',
  `purchase_order_number` varchar(255) DEFAULT NULL COMMENT '采购单号',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批次号',
  `if_qualified` char(1) DEFAULT NULL COMMENT '是否合格',
  `status` char(2) DEFAULT '0' COMMENT '状态',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `size_category` int DEFAULT NULL COMMENT '尺码类别',
  `already_settlement_quantity` decimal(20,4) unsigned DEFAULT NULL COMMENT '已结算数量',
  `store_unit_price` decimal(13,4) unsigned DEFAULT NULL COMMENT '入库单价',
  `store_rate` decimal(13,4) DEFAULT NULL,
  `settlement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '结算单价',
  `art_customer_seq` int DEFAULT NULL COMMENT '客户序号',
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `location_name` varchar(50) NOT NULL COMMENT '储位名称',
  `location_code` varchar(50) NOT NULL COMMENT '储位编号',
  `warehouse_name` varchar(50) NOT NULL COMMENT '仓库名称',
  `warehouse_code` varchar(50) NOT NULL COMMENT '仓库编号',
  `delivery_note_number` varchar(100) DEFAULT NULL COMMENT '送货单号',
  `mx_material_category_unit_seq` int DEFAULT NULL,
  `mx_material_category_unit_name` varchar(255) DEFAULT NULL,
  `mx_material_category_purchase_unit_seq` int DEFAULT NULL,
  `mx_material_category_purchase_unit_name` varchar(255) DEFAULT NULL,
  `return_qty` decimal(11,4) DEFAULT NULL,
  `many_receive_rate` decimal(11,4) DEFAULT NULL,
  `return_materials_number` varchar(255) DEFAULT NULL COMMENT '退料单号',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `size` varchar(100) DEFAULT NULL,
  `proc_material_warehousing_info_seq` int DEFAULT NULL COMMENT '材料入库明细',
  `subtotal_seq` int DEFAULT NULL COMMENT '汇总表seq(含原材料和外加工)',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `po` varchar(500) DEFAULT NULL COMMENT '订单标识号=行号和生产指令号一一对应',
  `sku` varchar(500) DEFAULT NULL COMMENT '款式',
  `material_info_colour_name` varchar(500) DEFAULT NULL COMMENT '颜色',
  `manual_prod_code` varchar(200) DEFAULT NULL COMMENT '指令号',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `quality_code` varchar(50) DEFAULT NULL COMMENT '品检单号',
  `sampling_quantity` decimal(11,2) DEFAULT NULL COMMENT '抽检数量',
  `sampling_rate` decimal(5,2) DEFAULT NULL COMMENT '抽检比率',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3269 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料入库单明细';


--
-- Table structure for table `proc_material_warehousing_todo`
--

DROP TABLE IF EXISTS `proc_material_warehousing_todo`;


CREATE TABLE `proc_material_warehousing_todo` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `od_product_order_order_position_seq` int DEFAULT NULL COMMENT '生产订单与部位关联表seq',
  `business_type` int NOT NULL COMMENT '40合格品入库, 41不合格品入库 ',
  `business_seq` int DEFAULT NULL COMMENT '业务seq(原材料暂收、加工材料暂收)',
  `business_info_seq` int DEFAULT NULL COMMENT '业务详情seq',
  `total` double(18,4) DEFAULT NULL COMMENT '总量',
  `actual_usage` double(18,4) DEFAULT NULL COMMENT '实际暂收量',
  `remaining_quantity` double(18,4) DEFAULT NULL COMMENT '剩余暂收量',
  `inventory_quantity` double(18,4) DEFAULT '0.0000' COMMENT '实际入库数量',
  `total_inventory_quantity` double(18,4) DEFAULT '0.0000' COMMENT '本次入库量',
  `return_materials_quantity` double(18,4) DEFAULT '0.0000' COMMENT '退料数量',
  `total_return_materials_quantity` double(18,4) DEFAULT '0.0000' COMMENT '本次退料数量',
  `total_accounting_quantity` double(18,4) DEFAULT '0.0000' COMMENT '本次入库记账数量',
  `status` char(2) DEFAULT '0' COMMENT '状态（草稿51提交10待审批20审批中21转办22委派23抄送24退回25驳回26撤回1审批通过50）',
  `material_delivery_time` datetime DEFAULT NULL COMMENT '物料行交期（采购交期）',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '收货人账号',
  `created_by_name` varchar(255) DEFAULT NULL COMMENT '收货人名',
  `created_at` datetime DEFAULT NULL COMMENT '收货时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(50) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(50) DEFAULT NULL COMMENT '储位名称',
  `version` int DEFAULT '0' COMMENT '版本号',
  `receiving_factory_id` int DEFAULT NULL,
  `receiving_factory` varchar(255) DEFAULT NULL COMMENT '收料工厂',
  `delivery_note_number` varchar(255) DEFAULT NULL COMMENT '送货单号',
  `batch_number` varchar(255) DEFAULT NULL COMMENT '送货批次号',
  `source` varchar(255) DEFAULT NULL COMMENT '来源单号（材料暂收单、委外暂收单）',
  `art_customer_article_code` text COMMENT '客户型体号',
  `od_prod_order_code` text COMMENT '生产订单号',
  `manual_prod_code` text COMMENT '手工排产单号',
  `od_order_doc_code` text COMMENT '正式订单号',
  `sku` text COMMENT 'sku',
  `mx_material_info_seq` int DEFAULT NULL COMMENT '物料seq',
  `mx_material_info_code` varchar(255) DEFAULT NULL,
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `size` varchar(255) DEFAULT NULL COMMENT '接收size',
  `receiving_date` datetime DEFAULT NULL COMMENT '收货日期',
  `receiving_department` varchar(255) DEFAULT NULL COMMENT '收货部门',
  `process_name` varchar(255) DEFAULT NULL COMMENT '部位',
  `provider_seq` int DEFAULT NULL COMMENT '供应商',
  `provider_name` varchar(255) DEFAULT NULL,
  `is_out_sourcing` int DEFAULT '0' COMMENT '1\\0\\2',
  `purchase_order_number` varchar(500) DEFAULT NULL COMMENT '采购单号',
  `mx_material_category_seq` int DEFAULT NULL COMMENT '物料seq',
  `mx_material_category_code` varchar(255) DEFAULT NULL,
  `mx_material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料颜色',
  `art_customer_seq` int DEFAULT NULL,
  `art_customer_name` varchar(255) DEFAULT NULL COMMENT '客户名',
  `test_date` datetime DEFAULT NULL COMMENT '检测日期',
  `test_department_name` varchar(255) DEFAULT NULL COMMENT '部门',
  `storage_type` varchar(255) DEFAULT NULL COMMENT '入库类型',
  `quality_spection_code` varchar(255) DEFAULT NULL COMMENT '质检单号',
  `code` varchar(50) DEFAULT NULL COMMENT '品检单号',
  `uninspection_quantity` decimal(13,4) DEFAULT NULL COMMENT '不合格数量',
  `inspection_results` varchar(50) DEFAULT NULL COMMENT '综合判断结果',
  `if_qualified` int DEFAULT NULL COMMENT '是否合格',
  `test_by_username` varchar(50) DEFAULT NULL COMMENT '测试人',
  `qualified_rate` decimal(13,4) DEFAULT NULL COMMENT '合格比例',
  `return_materials_number` varchar(50) DEFAULT NULL COMMENT '退料单号',
  `is_unispection_inv` int DEFAULT NULL COMMENT '是否不合格入库0,1',
  `mx_material_category_Name` text COMMENT '物料名称',
  `actual_unqualified_quantity` decimal(11,2) DEFAULT '0.00' COMMENT '实际不合格数量',
  `sampling_quantity` decimal(11,2) DEFAULT NULL COMMENT '抽检数量',
  `sampling_rate` decimal(5,2) DEFAULT NULL COMMENT '抽检比率',
  `po` varchar(255) DEFAULT NULL COMMENT 'po',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `od_product_order_order_position_seq` (`business_seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=901 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='材料入库待办表';


--
-- Temporary view structure for view `proc_product_order_view`
--

DROP TABLE IF EXISTS `proc_product_order_view`;
/*!50001 DROP VIEW IF EXISTS `proc_product_order_view`*/;
SET @saved_cs_client     = @@character_set_client;

/*!50001 CREATE VIEW `proc_product_order_view` AS SELECT 
 1 AS `code`,
 1 AS `dict_value`,
 1 AS `customer_article_code`,
 1 AS `material_category_name`,
 1 AS `provider_name`,
 1 AS `position_name`,
 1 AS `material_info_colour_name`,
 1 AS `position_seq`,
 1 AS `material_info_code`,
 1 AS `usages`,
 1 AS `mx_material_category_purchase_unit_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `proc_supplier_statement`
--

DROP TABLE IF EXISTS `proc_supplier_statement`;


CREATE TABLE `proc_supplier_statement` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `account_payable_order` varchar(50) DEFAULT NULL COMMENT '应付款单号',
  `code` varchar(50) DEFAULT NULL COMMENT '供应商编码',
  `name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `payment_currency` varchar(50) DEFAULT NULL COMMENT '付款币种',
  `payment_method` varchar(50) DEFAULT NULL COMMENT '付款方式',
  `payment_terms` varchar(50) DEFAULT NULL COMMENT '付款账期',
  `current_account` varchar(50) DEFAULT NULL COMMENT '往来账户',
  `payment_amount` decimal(12,2) DEFAULT NULL COMMENT '付款金额',
  `receiving_factory` varchar(50) DEFAULT NULL COMMENT '收料工厂',
  `is_available` int DEFAULT '1' COMMENT '是否可用',
  `status` int DEFAULT '0' COMMENT '对账状态(0供应商暂存，1供应商提交 2财务暂存，3财务确认）',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `settlement_amount` decimal(12,2) DEFAULT NULL COMMENT '结算金额',
  `customer_seq` int DEFAULT NULL COMMENT '客户seq',
  `custom_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `created_by_name` varchar(255) DEFAULT NULL COMMENT '创建人名称',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COMMENT='供应商对账单';


--
-- Table structure for table `proc_supplier_statement_deduction`
--

DROP TABLE IF EXISTS `proc_supplier_statement_deduction`;


CREATE TABLE `proc_supplier_statement_deduction` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `supplier_statement_seq` int DEFAULT NULL COMMENT '供应商对账表主键',
  `deduction_items` varchar(50) DEFAULT NULL COMMENT '扣款项目',
  `amount` decimal(12,2) DEFAULT NULL COMMENT '金额',
  `deduction_explanation` varchar(2000) DEFAULT NULL COMMENT '扣款说明',
  `is_deduction_first` int DEFAULT NULL COMMENT '是否先扣款再扣%',
  `attachment` varchar(2000) DEFAULT NULL COMMENT '附件',
  `attachment_name` varchar(200) DEFAULT NULL COMMENT '附件名称',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='供应商对账扣款费用';


--
-- Table structure for table `proc_supplier_statement_deduction_attachment`
--

DROP TABLE IF EXISTS `proc_supplier_statement_deduction_attachment`;


CREATE TABLE `proc_supplier_statement_deduction_attachment` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `supplier_statement_seq` int DEFAULT NULL COMMENT '供应商对账表主键',
  `supplier_statement_deduction_seq` int DEFAULT NULL COMMENT '供应商对账扣款主键',
  `attachment` varchar(2000) DEFAULT NULL COMMENT '附件',
  `attachment_name` varchar(200) DEFAULT NULL COMMENT '附件名称',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='供应商对账扣款费用附件';


--
-- Table structure for table `proc_supplier_statement_info`
--

DROP TABLE IF EXISTS `proc_supplier_statement_info`;


CREATE TABLE `proc_supplier_statement_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `supplier_statement_seq` int DEFAULT NULL COMMENT '供应商对账表主键',
  `warehousing_seq` int DEFAULT NULL COMMENT '入库单seq',
  `sku` varchar(50) DEFAULT NULL COMMENT 'sku',
  `customer_seq` int DEFAULT NULL COMMENT '客户seq',
  `custom_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `material_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `material_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码主键',
  `material_info_code` varchar(255) DEFAULT NULL COMMENT '物料信息编码',
  `unit` varchar(50) DEFAULT NULL COMMENT '单位',
  `purchase_order_number` varchar(50) DEFAULT NULL COMMENT '采购单号',
  `warehouse_entry_number` varchar(50) DEFAULT NULL COMMENT '入库单号',
  `warehouse_entry_date` datetime DEFAULT NULL COMMENT '入库时间',
  `delivery_note_number` varchar(50) DEFAULT NULL COMMENT '送货单号',
  `purchase_convert_rate` decimal(13,4) DEFAULT NULL COMMENT '采购转换比率',
  `purchase_unit` varchar(50) DEFAULT NULL COMMENT '采购单位',
  `warehouse_accounting_quantity` decimal(13,4) DEFAULT NULL COMMENT '入库记账数量',
  `warehouse_unit_price` decimal(13,4) DEFAULT NULL COMMENT '入库单价',
  `warehouse_amount` decimal(13,4) DEFAULT NULL COMMENT '入库金额',
  `supplier_statement_number` decimal(13,4) DEFAULT NULL COMMENT '供应商对账数量',
  `supplier_statement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '供应商对账单价',
  `settlement_quantity` decimal(13,4) DEFAULT NULL COMMENT '结算数量',
  `settlement_unit_price` decimal(13,4) DEFAULT NULL COMMENT '结算单价',
  `settlement_amount` decimal(13,4) DEFAULT NULL COMMENT '结算金额',
  `quarter_code` int DEFAULT NULL COMMENT '季节号',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除(0-否,1-是)',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_check` int DEFAULT '1' COMMENT '是否确认1是0否',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb3 COMMENT='供应商对账明细';


--
-- Table structure for table `procurement_sample`
--

DROP TABLE IF EXISTS `procurement_sample`;


CREATE TABLE `procurement_sample` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `procurement_seq` int NOT NULL COMMENT '外键',
  `article_seq` int DEFAULT NULL COMMENT '型体表序号',
  `sample_seq` int DEFAULT NULL COMMENT '样品表序号',
  `is_delete` int DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `procurement_sample_foregin_key` (`procurement_seq`) USING BTREE,
  CONSTRAINT `procurement_sample_foregin_key` FOREIGN KEY (`procurement_seq`) REFERENCES `proc_material_procurement_info` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料型体样品关联表';


--
-- Table structure for table `procurement_terms`
--

DROP TABLE IF EXISTS `procurement_terms`;


CREATE TABLE `procurement_terms` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `item` varchar(255) DEFAULT NULL COMMENT '内容',
  `create_by` varchar(22) DEFAULT NULL COMMENT '创建人',
  `create_date` date DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='采购条款';


--
-- Table structure for table `prompt_information`
--

DROP TABLE IF EXISTS `prompt_information`;


CREATE TABLE `prompt_information` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `id` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT '状态码',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='提示信息';


--
-- Table structure for table `prompt_information_info`
--

DROP TABLE IF EXISTS `prompt_information_info`;


CREATE TABLE `prompt_information_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `prompt_information_seq` int DEFAULT NULL COMMENT '提示信息序号',
  `type` varchar(3) DEFAULT NULL COMMENT '语言类型\r\n1：中文\r\n2：英语\r\n3：越南语',
  `content` varchar(255) DEFAULT NULL COMMENT '提示信息',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='提示信息详情';


--
-- Table structure for table `purchases`
--

DROP TABLE IF EXISTS `purchases`;


CREATE TABLE `purchases` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `no` varchar(20) DEFAULT NULL COMMENT '单号',
  `procurement_seq` int NOT NULL COMMENT '样品采购计划表主键',
  `supplier_seq` int NOT NULL COMMENT '供应商表主键',
  `status` int DEFAULT '0' COMMENT '状态（0：未审核 1：已审核）',
  `verify_date` date DEFAULT NULL COMMENT '审核时间',
  `insert_all` int DEFAULT '1' COMMENT '是否全部入库(0:否 1:是)',
  `create_date` date DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(24) DEFAULT NULL COMMENT '创建人',
  `is_delete` int DEFAULT '0' COMMENT '是否删除（0：未删除 1：删除）',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `material_procurement_foregin_key1` (`procurement_seq`) USING BTREE,
  KEY `material_procurement_foregin_key2` (`supplier_seq`) USING BTREE,
  CONSTRAINT `material_procurement_foregin_key1` FOREIGN KEY (`procurement_seq`) REFERENCES `proc_material_procurement` (`seq`),
  CONSTRAINT `material_procurement_foregin_key2` FOREIGN KEY (`supplier_seq`) REFERENCES `bas_supplier_bak1` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='采购清单(暂时没用)';


--
-- Table structure for table `rabbitmq_msg_record`
--

DROP TABLE IF EXISTS `rabbitmq_msg_record`;


CREATE TABLE `rabbitmq_msg_record` (
  `snow_id` bigint NOT NULL COMMENT '唯一ID（雪花算法生成）',
  `module` varchar(50) NOT NULL COMMENT '模块标识（如 pdm、oms）',
  `target_exchange` varchar(255) DEFAULT NULL COMMENT '目标交换机名称',
  `target_queue` varchar(255) DEFAULT NULL COMMENT '目标队列名称',
  `message_data` longtext NOT NULL COMMENT '消息数据',
  `business_name` varchar(30) NOT NULL COMMENT '业务名称',
  `business_status_name` varchar(40) DEFAULT NULL COMMENT '业务状态昵称',
  `status` int NOT NULL DEFAULT '0' COMMENT '消息状态（0:异常 1:待处理 2:处理中 3:已完成',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user_id` bigint DEFAULT NULL COMMENT '创建人用户ID',
  `create_user_name` varchar(255) DEFAULT NULL COMMENT '创建人名称',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`snow_id`),
  KEY `idx_module_create_time` (`module`,`create_time`),
  KEY `idx_status` (`status`),
  KEY `exchange_index` (`target_exchange`),
  KEY `idx_user_id` (`create_user_id`),
  KEY `queue_index` (`target_queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='RabbitMQ消息记录表';


--
-- Table structure for table `replenishment_out_bound`
--

DROP TABLE IF EXISTS `replenishment_out_bound`;


CREATE TABLE `replenishment_out_bound` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `replenishment_out_bound_code` varchar(50) DEFAULT NULL COMMENT '补料出库单号',
  `out_bound_type` varchar(50) DEFAULT NULL COMMENT '出库类型',
  `issuing_materials_company` varchar(50) DEFAULT NULL COMMENT '发料公司',
  `issuing_materials_company_seq` int DEFAULT NULL COMMENT '发料公司seq',
  `issuing_materials_warehouse_code` varchar(50) DEFAULT NULL COMMENT '发料仓库Code',
  `issuing_materials_warehouse_name` varchar(50) DEFAULT NULL COMMENT '发料仓库',
  `out_bound_date` datetime DEFAULT NULL COMMENT '出库日期',
  `operator` varchar(50) DEFAULT NULL COMMENT '经办人',
  `requisition_material_company` varchar(50) DEFAULT NULL COMMENT '领料公司',
  `requisition_material_company_seq` int DEFAULT NULL COMMENT '领料公司seq',
  `requisition_material_dept` varchar(50) DEFAULT NULL COMMENT '领料部门',
  `requisition_material_dept_seq` int DEFAULT NULL COMMENT '领料部门seq',
  `requisition_material_group` varchar(50) DEFAULT NULL COMMENT '领料小组',
  `requisition_material_group_seq` int DEFAULT NULL COMMENT '领料小组seq',
  `status` int DEFAULT NULL COMMENT '状态 0暂存1提交',
  `remarks` varchar(200) DEFAULT NULL COMMENT '备注',
  `is_deleted` int DEFAULT NULL COMMENT '是否删除0否1是',
  `created_by_name` varchar(200) DEFAULT NULL COMMENT '创建人',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `check_at` timestamp NULL DEFAULT NULL COMMENT '核对时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_by_name` varchar(200) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `print_count` int DEFAULT '0',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='补料出库单';


--
-- Table structure for table `replenishment_out_bound_info`
--

DROP TABLE IF EXISTS `replenishment_out_bound_info`;


CREATE TABLE `replenishment_out_bound_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `replenishment_out_bound_seq` int DEFAULT NULL COMMENT '出库表seq',
  `info_seq` int DEFAULT NULL COMMENT '补料申请单明细seq',
  `manual_prod_code` varchar(50) DEFAULT NULL COMMENT '指令号',
  `replenishment_code` varchar(50) DEFAULT NULL COMMENT '补料单号',
  `sku` varchar(50) DEFAULT NULL COMMENT 'sku',
  `class_seq` int DEFAULT NULL COMMENT '类别seq',
  `class_name` varchar(50) DEFAULT NULL COMMENT '类别名称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `material_category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `material_info_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `material_info_seq` varchar(255) DEFAULT NULL COMMENT '物料编码seq',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `material_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `material_info_colour` varchar(255) DEFAULT NULL COMMENT '物料颜色',
  `material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '物料颜色名称',
  `key` varchar(50) DEFAULT NULL COMMENT '尺码',
  `no` varchar(50) DEFAULT NULL COMMENT '序号',
  `unit_seq` int DEFAULT NULL COMMENT '单位seq',
  `unit_name` varchar(50) DEFAULT NULL COMMENT '单位',
  `requisition_qty` decimal(14,4) DEFAULT NULL COMMENT '申请数量',
  `outbound_quantity` double(18,4) DEFAULT NULL COMMENT '出库数量',
  `remaining_quantity` double(18,4) DEFAULT NULL COMMENT '未出库数量',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `warehouse_code` varchar(80) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(80) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(80) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(80) DEFAULT NULL COMMENT '储位名称',
  `store_qty` decimal(14,4) DEFAULT NULL COMMENT '库存数量',
  `row_no` varchar(50) DEFAULT NULL COMMENT 'po',
  `product_code` varchar(50) DEFAULT NULL COMMENT '生产订单号',
  `product_seq` varchar(50) DEFAULT NULL COMMENT '生产订单号seq',
  `customer_article_code` varchar(50) DEFAULT NULL COMMENT '客户型体号',
  `customer_seq` int DEFAULT NULL COMMENT '客户seq',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `parent_seq` int DEFAULT NULL COMMENT '父级seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_name` varchar(50) DEFAULT NULL COMMENT '供应商名称',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `replenishment_out_bound_seq` (`replenishment_out_bound_seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='补料出库单明细';


--
-- Table structure for table `replenishment_requisition`
--

DROP TABLE IF EXISTS `replenishment_requisition`;


CREATE TABLE `replenishment_requisition` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `replenishment_code` varchar(50) DEFAULT NULL COMMENT '补料申请单号',
  `replenishment_type` varchar(50) DEFAULT NULL COMMENT '补料类型',
  `replenishment_qty` decimal(14,4) DEFAULT NULL COMMENT '补料数量',
  `replenishment_company` varchar(50) DEFAULT NULL COMMENT '补料公司',
  `replenishment_company_seq` int DEFAULT NULL COMMENT '补料公司seq',
  `replenishment_dept` varchar(50) DEFAULT NULL COMMENT '补料部门',
  `replenishment_dept_seq` int DEFAULT NULL COMMENT '补料部门seq',
  `replenishment_group_seq` int DEFAULT NULL COMMENT '补料小组seq',
  `replenishment_group` varchar(50) DEFAULT NULL COMMENT '补料小组',
  `material_requisition_company` varchar(50) DEFAULT NULL COMMENT '领料公司',
  `material_requisition_company_seq` int DEFAULT NULL COMMENT '领料公司seq',
  `material_requisition_dept` varchar(50) DEFAULT NULL COMMENT '领料部门',
  `material_requisition_dept_seq` int DEFAULT NULL COMMENT '领料部门seq',
  `material_requisition_group_seq` int DEFAULT NULL COMMENT '领料小组seq',
  `material_requisition_group` varchar(50) DEFAULT NULL COMMENT '领料小组',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `supplier_name` varchar(50) DEFAULT NULL COMMENT '供应商名称',
  `replenishment_date` datetime DEFAULT NULL COMMENT '补料时间',
  `order_filler` varchar(50) DEFAULT NULL COMMENT '开补人',
  `customer_seq` int DEFAULT NULL COMMENT '客户seq',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户名称',
  `row_no` varchar(50) DEFAULT NULL COMMENT 'po',
  `manual_prod_code` varchar(50) DEFAULT NULL COMMENT '指令号',
  `sku` varchar(50) DEFAULT NULL COMMENT 'sku',
  `liability_allocation` varchar(50) DEFAULT NULL COMMENT '责任归属',
  `replenishment_reason` varchar(500) DEFAULT NULL COMMENT '补料原因',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `status` int DEFAULT '0' COMMENT '状态(0暂存 1提交)',
  `is_check` int DEFAULT '0' COMMENT '是否核料',
  `product_code` varchar(500) DEFAULT NULL COMMENT '生产订单号',
  `product_seq` int DEFAULT NULL COMMENT '生产订单号seq',
  `is_deleted` int DEFAULT NULL COMMENT '是否删除0否1是',
  `created_by_name` varchar(200) DEFAULT NULL COMMENT '创建人',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `check_at` timestamp NULL DEFAULT NULL COMMENT '核对时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_by_name` varchar(200) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `print_count` int DEFAULT '0',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COMMENT='补料申请单';


--
-- Table structure for table `replenishment_requisition_info`
--

DROP TABLE IF EXISTS `replenishment_requisition_info`;


CREATE TABLE `replenishment_requisition_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `replenishment_requisition_seq` int DEFAULT NULL,
  `row_no` varchar(50) DEFAULT NULL COMMENT 'po',
  `sku` varchar(50) DEFAULT NULL COMMENT 'sku',
  `manual_prod_code` varchar(50) DEFAULT NULL COMMENT '指令号',
  `product_code` varchar(50) DEFAULT NULL COMMENT '生产订单号',
  `product_seq` varchar(50) DEFAULT NULL COMMENT '生产订单号seq',
  `customer_article_code` varchar(50) DEFAULT NULL COMMENT '客户型体号',
  `customer_seq` int DEFAULT NULL COMMENT '客户seq',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `class_seq` int DEFAULT NULL COMMENT '类别seq',
  `class_name` varchar(50) DEFAULT NULL COMMENT '类别名称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(50) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(50) DEFAULT NULL COMMENT '部位名称',
  `material_category_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `material_info_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `material_info_seq` varchar(255) DEFAULT NULL COMMENT '物料编码seq',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码seq',
  `parent_seq` int DEFAULT NULL COMMENT '父级seq',
  `material_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `material_info_colour` varchar(255) DEFAULT NULL COMMENT '物料颜色',
  `material_info_colour_name` varchar(255) DEFAULT NULL COMMENT '物料颜色名称',
  `key` varchar(50) DEFAULT NULL COMMENT '尺码',
  `no` varchar(50) DEFAULT NULL COMMENT '序号',
  `unit_seq` int DEFAULT NULL COMMENT '单位seq',
  `each_expend` decimal(14,4) DEFAULT NULL COMMENT '单耗',
  `unit_name` varchar(50) DEFAULT NULL COMMENT '单位',
  `requisition_qty` decimal(14,4) DEFAULT NULL COMMENT '申请数量',
  `remaining_quantity` decimal(14,4) DEFAULT NULL COMMENT '剩余申请数量',
  `procurement_demand_qty` decimal(14,4) DEFAULT NULL COMMENT '采购需求量',
  `store_qty` decimal(14,4) DEFAULT NULL COMMENT '库存数量',
  `general_store_qty` decimal(14,4) DEFAULT NULL COMMENT '通用库存数量',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(50) DEFAULT NULL COMMENT '供应商名称',
  `process_name` varchar(50) DEFAULT NULL COMMENT '制程',
  `provider_type_seq` int DEFAULT NULL COMMENT '供方类型',
  `provider_type_name` varchar(50) DEFAULT NULL COMMENT '供方类型',
  `is_match_size` int DEFAULT NULL COMMENT '是否配码',
  `is_each_expend` int DEFAULT NULL COMMENT '是否码段用量',
  `is_out_sourcing` int DEFAULT NULL COMMENT '是否外加工',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `warehouse_code` varchar(80) DEFAULT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(80) DEFAULT NULL COMMENT '仓库名称',
  `location_code` varchar(80) DEFAULT NULL COMMENT '储位编号',
  `location_name` varchar(80) DEFAULT NULL COMMENT '储位名称',
  `material_dosage` decimal(14,4) DEFAULT NULL COMMENT '物料用量',
  `type` int DEFAULT '0' COMMENT '0物料创建 1部位创建',
  `art_post_seq` int DEFAULT NULL COMMENT '型体部位seq',
  `version` int DEFAULT '0' COMMENT '版本号',
  `left_foot_qty` decimal(14,4) DEFAULT NULL COMMENT '左脚数量',
  `right_foot_qty` decimal(14,4) DEFAULT NULL COMMENT '右脚数量',
  `material_type_seq` int DEFAULT NULL COMMENT '部位物料分类序号',
  `material_type_name` varchar(255) DEFAULT NULL COMMENT '部位物料类型',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  PRIMARY KEY (`seq`),
  KEY `replenishment_requisition_seq` (`replenishment_requisition_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb3 COMMENT='补料申请单明细';


--
-- Table structure for table `replenishment_requisition_position`
--

DROP TABLE IF EXISTS `replenishment_requisition_position`;


CREATE TABLE `replenishment_requisition_position` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `replenishment_requisition_seq` int DEFAULT NULL COMMENT '主表seq',
  `art_seq` int DEFAULT NULL COMMENT '产品资料seq',
  `no` varchar(50) DEFAULT NULL COMMENT '序号',
  `is_craft` int DEFAULT NULL COMMENT '是否工艺',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `art_post_seq` int DEFAULT NULL COMMENT '型体部位表seq',
  `position_code` text COMMENT '部位编码',
  `position_name` text COMMENT '部位名称',
  `ie_name` varchar(300) DEFAULT NULL COMMENT '工艺名称',
  `process_seq` int DEFAULT NULL COMMENT '制程seq',
  `process_name` varchar(50) DEFAULT NULL COMMENT '制程名称',
  `material_info_is_match_size` int DEFAULT NULL COMMENT '是否配码',
  `type` varchar(50) DEFAULT NULL COMMENT '类型',
  `art_position_seq_str` varchar(300) DEFAULT NULL COMMENT '合并的部位seq',
  `key` varchar(50) DEFAULT NULL COMMENT '尺码',
  `quantity` decimal(14,4) DEFAULT NULL COMMENT '数量',
  `left_foot_qty` decimal(14,4) DEFAULT NULL COMMENT '左脚数量',
  `right_foot_qty` decimal(14,4) DEFAULT NULL COMMENT '右脚数量',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=317 DEFAULT CHARSET=utf8mb3 COMMENT='补料申请单部位信息';


--
-- Temporary view structure for view `rukuview`
--

DROP TABLE IF EXISTS `rukuview`;
/*!50001 DROP VIEW IF EXISTS `rukuview`*/;
SET @saved_cs_client     = @@character_set_client;

/*!50001 CREATE VIEW `rukuview` AS SELECT 
 1 AS `所入公司`,
 1 AS `物料大类`,
 1 AS `物料分组`,
 1 AS `物料中类`,
 1 AS `供应商`,
 1 AS `SKU`,
 1 AS `指令号`,
 1 AS `入库日期`,
 1 AS `入库单号`,
 1 AS `物料编码`,
 1 AS `物料名称`,
 1 AS `颜色`,
 1 AS `尺码`,
 1 AS `数量`,
 1 AS `单位`,
 1 AS `单价`,
 1 AS `金额`,
 1 AS `所入仓库`,
 1 AS `入库类型`,
 1 AS `客户`,
 1 AS `经办人`,
 1 AS `鞋型季度`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `sample_order`
--

DROP TABLE IF EXISTS `sample_order`;


CREATE TABLE `sample_order` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `code` varchar(255) DEFAULT NULL COMMENT '单号',
  `type` int DEFAULT NULL COMMENT '样品类型',
  `article_seq` int DEFAULT NULL COMMENT '型体序号',
  `article_size_seq` int DEFAULT NULL COMMENT '型体size序号',
  `department_seq` int DEFAULT NULL COMMENT '部门序号',
  `quantity` double(11,2) DEFAULT NULL COMMENT '数量',
  `unit` int DEFAULT NULL COMMENT '单位',
  `version` varchar(255) DEFAULT NULL COMMENT '开发版本',
  `development` varchar(255) DEFAULT NULL COMMENT '开发版师',
  `date` timestamp NULL DEFAULT NULL COMMENT '样品日期',
  `business` varchar(255) DEFAULT NULL COMMENT '开发业务',
  `customer_delivery` timestamp NULL DEFAULT NULL COMMENT '客户交期',
  `status` varchar(2) DEFAULT NULL COMMENT '状态\r\n0:草稿\r\n10：待审核\r\n11：撤回\r\n12：审核中\r\n13：驳回\r\n20：审核通过',
  `is_audit` char(1) DEFAULT NULL COMMENT '是否审核',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除',
  `filing_time` timestamp NULL DEFAULT NULL COMMENT '建档时间',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改日期',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `article_seq` (`article_seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品单（暂时作废）';


--
-- Table structure for table `sample_order_history_version`
--

DROP TABLE IF EXISTS `sample_order_history_version`;


CREATE TABLE `sample_order_history_version` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sample_order_seq` int DEFAULT NULL COMMENT '样品单序号',
  `revision` text COMMENT '修改内容',
  `code` varchar(255) DEFAULT NULL COMMENT '单号',
  `type` int DEFAULT NULL COMMENT '样品类型',
  `article_seq` int DEFAULT NULL COMMENT '型体序号',
  `article_size_seq` int DEFAULT NULL COMMENT '型体size序号',
  `department_seq` int DEFAULT NULL COMMENT '部门序号',
  `quantity` double(11,2) DEFAULT NULL COMMENT '数量',
  `unit` int DEFAULT NULL COMMENT '单位',
  `version` varchar(255) DEFAULT NULL COMMENT '开发版本',
  `development` varchar(255) DEFAULT NULL COMMENT '开发版师',
  `date` timestamp NULL DEFAULT NULL COMMENT '样品日期',
  `business` varchar(255) DEFAULT NULL COMMENT '开发业务',
  `customer_delivery` timestamp NULL DEFAULT NULL COMMENT '客户交期',
  `is_audit` char(1) DEFAULT NULL COMMENT '是否审核',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除',
  `filing_time` timestamp NULL DEFAULT NULL COMMENT '建档时间',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改日期',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `article_seq` (`article_seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品单历史版本（暂时作废）';


--
-- Table structure for table `sample_receipt`
--

DROP TABLE IF EXISTS `sample_receipt`;


CREATE TABLE `sample_receipt` (
  `id` int(11) unsigned zerofill NOT NULL COMMENT 'id',
  `vender_num` varchar(64) DEFAULT NULL COMMENT '厂别代号',
  `supplier_num` int DEFAULT NULL COMMENT '供应商编号',
  `receipts_type` int DEFAULT NULL COMMENT '单据分类',
  `take_goods_date` datetime DEFAULT NULL COMMENT '收货日期',
  `take_goods_odd` varchar(125) DEFAULT NULL COMMENT '收货单号',
  `filing_by` varchar(64) DEFAULT NULL COMMENT '建档人',
  `filing_date` datetime DEFAULT NULL COMMENT '建档日期',
  `deliver_goods_odd` varchar(125) DEFAULT NULL COMMENT '发料单号',
  `deliver_goods_date` datetime DEFAULT NULL COMMENT '发料日期',
  `backset_by` varchar(64) DEFAULT NULL COMMENT '锁档人',
  `backset_date` datetime DEFAULT NULL COMMENT '锁档日期',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_delete` char(1) DEFAULT NULL COMMENT '是否删除：0-否,1-是',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='样品采购收料（入库）';


--
-- Table structure for table `sample_receipt_info`
--

DROP TABLE IF EXISTS `sample_receipt_info`;


CREATE TABLE `sample_receipt_info` (
  `id` int NOT NULL,
  `po_no` varchar(64) DEFAULT NULL COMMENT '采购单号',
  `plant` varchar(64) DEFAULT NULL COMMENT '工厂型体',
  `materiel_type` varchar(64) DEFAULT NULL COMMENT '物料分类',
  `materiel_name` varchar(64) DEFAULT NULL COMMENT '物料名称',
  `

inventory` char(1) DEFAULT NULL COMMENT '库存材料',
  `unit` varchar(64) DEFAULT NULL COMMENT '单位',
  `unit_price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  `warehouse` varchar(255) DEFAULT NULL COMMENT '仓库',
  `storage` varchar(255) DEFAULT NULL COMMENT '储位',
  `volume` varchar(255) DEFAULT NULL COMMENT '收货量',
  `price` decimal(10,2) DEFAULT NULL COMMENT '金额',
  `sample

_no` int DEFAULT NULL COMMENT '样品单号',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改日期',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='样品采购收料（入库）详情';


--
-- Table structure for table `sample_return_material`
--

DROP TABLE IF EXISTS `sample_return_material`;


CREATE TABLE `sample_return_material` (
  `id` int(11) unsigned zerofill NOT NULL COMMENT 'id',
  `vender_num` varchar(64) DEFAULT NULL COMMENT '厂别代号',
  `unit_num` int DEFAULT NULL COMMENT '申领单位',
  `receipts_type` int DEFAULT NULL COMMENT '单据分类',
  `draw_date` datetime DEFAULT NULL COMMENT '申领日期',
  `draw_odd` varchar(125) DEFAULT NULL COMMENT '申领单号',
  `filing_by` varchar(64) DEFAULT NULL COMMENT '建档人',
  `filing_date` datetime DEFAULT NULL COMMENT '建档日期',
  `backset_by` varchar(64) DEFAULT NULL COMMENT '锁档人',
  `backset_date` datetime DEFAULT NULL COMMENT '锁档日期',
  `is_backset` char(1) DEFAULT 'N' COMMENT '是否锁档：N-否，Y-是',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_delete` char(1) DEFAULT '0' COMMENT '是否删除：0-否,1-是',
  `created_by` varchar(64) CHARACTER SET utf16 COLLATE utf16_general_ci DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='样品采购退料（出库）';


--
-- Table structure for table `sample_return_material_info`
--

DROP TABLE IF EXISTS `sample_return_material_info`;


CREATE TABLE `sample_return_material_info` (
  `id` int NOT NULL,
  `po_no` varchar(64) DEFAULT NULL COMMENT '采购单号',
  `plant` varchar(64) DEFAULT NULL COMMENT '工厂型体',
  `materiel_type` varchar(64) DEFAULT NULL COMMENT '物料分类',
  `materiel_name` varchar(64) DEFAULT NULL COMMENT '物料名称',
  `

inventory` char(1) DEFAULT NULL COMMENT '库存材料',
  `unit` varchar(64) DEFAULT NULL COMMENT '单位',
  `unit_price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  `warehouse` varchar(255) DEFAULT NULL COMMENT '仓库',
  `storage` varchar(255) DEFAULT NULL COMMENT '储位',
  `volume` varchar(255) DEFAULT NULL COMMENT '收货量',
  `price` decimal(10,2) DEFAULT NULL COMMENT '金额',
  `sample

_no` int DEFAULT NULL COMMENT '样品单号',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改日期',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='样品采购退料（出库）详情';


--
-- Table structure for table `sample_shoes`
--

DROP TABLE IF EXISTS `sample_shoes`;


CREATE TABLE `sample_shoes` (
  `id` int(11) unsigned zerofill NOT NULL COMMENT 'id',
  `vender_num` varchar(64) DEFAULT NULL COMMENT '厂别代号',
  `trader_id` int DEFAULT NULL COMMENT '交易对象',
  `is_access` char(1) DEFAULT NULL COMMENT '进出标识：0-否，1-是',
  `put_date` datetime DEFAULT NULL COMMENT '入库日期',
  `put_odd` varchar(64) DEFAULT NULL COMMENT '入库单号',
  `receipts_type` int DEFAULT NULL COMMENT '单据分类',
  `currency

_type` varchar(125) DEFAULT NULL COMMENT '交易币别',
  `unit` varchar(125) DEFAULT NULL COMMENT '单位',
  `filing_by` varchar(64) DEFAULT NULL COMMENT '建档人',
  `filing_date` datetime DEFAULT NULL COMMENT '建档日期',
  `backset_by` varchar(64) DEFAULT NULL COMMENT '锁档人',
  `backset_date` datetime DEFAULT NULL COMMENT '锁档日期',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_backset` char(1) DEFAULT NULL COMMENT '是否锁档：N-否，Y-是',
  `is_delete` char(1) DEFAULT NULL COMMENT '是否删除：0-否,1-是',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='样品鞋出入库';


--
-- Table structure for table `sample_shoes_info`
--

DROP TABLE IF EXISTS `sample_shoes_info`;


CREATE TABLE `sample_shoes_info` (
  `id` int(11) unsigned zerofill NOT NULL COMMENT 'id',
  `sample_shoes_id` int DEFAULT NULL COMMENT '样品入库id',
  `sample_type` int DEFAULT NULL COMMENT '样品类型',
  `put_odd` varchar(125) DEFAULT NULL COMMENT '入库单号',
  `plant_molded` int DEFAULT NULL COMMENT '工厂型体',
  `molded

_color` int DEFAULT NULL COMMENT '型体配色',
  `shoe_last_id` int DEFAULT NULL COMMENT '楦头代号',
  `outsole

_id` int DEFAULT NULL COMMENT '大底代号',
  `yardage` varchar(125) DEFAULT NULL COMMENT '码数',
  `unit` varchar(125) DEFAULT NULL COMMENT '单位',
  `num` double(10,2) DEFAULT NULL COMMENT '数量',
  `owe_num` double(10,2) DEFAULT NULL COMMENT '欠数',
  `actual

_num` double(10,2) DEFAULT NULL COMMENT '实际数量',
  `put_num` double(10,2) DEFAULT NULL COMMENT '入库数量',
  `client

_molded` int DEFAULT NULL COMMENT '客户型体',
  `is_delete` char(1) DEFAULT NULL COMMENT '是否删除：0-否,1-是',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='样品鞋出入库子表';


--
-- Table structure for table `sample_structure`
--

DROP TABLE IF EXISTS `sample_structure`;


CREATE TABLE `sample_structure` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `sample_order_seq` int DEFAULT NULL COMMENT '样品单seq',
  `no` int DEFAULT NULL COMMENT '序号',
  `parts_seq` int DEFAULT NULL COMMENT '部件序号',
  `material_seq` int DEFAULT NULL COMMENT '物料序号',
  `quantity` varchar(11) DEFAULT NULL COMMENT '数量',
  `process_seq` int DEFAULT NULL COMMENT '加工动作序号',
  `unit_quantity` varchar(255) DEFAULT NULL COMMENT '单位用量',
  `source` varchar(255) DEFAULT NULL COMMENT '来源',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `sample_order_seq` (`sample_order_seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品结构（暂时作废）';


--
-- Table structure for table `sample_structure_history_version`
--

DROP TABLE IF EXISTS `sample_structure_history_version`;


CREATE TABLE `sample_structure_history_version` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sample_order_history_version_seq` int DEFAULT NULL COMMENT '样品单历史版本seq',
  `no` int DEFAULT NULL COMMENT '序号',
  `parts_seq` int DEFAULT NULL COMMENT '部件序号',
  `material_seq` int DEFAULT NULL COMMENT '物料序号',
  `quantity` varchar(11) DEFAULT NULL COMMENT '数量',
  `process_seq` int DEFAULT NULL COMMENT '加工动作序号',
  `unit_quantity` varchar(255) DEFAULT NULL COMMENT '单位用量',
  `source` varchar(255) DEFAULT NULL COMMENT '来源',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `sample_order_seq` (`sample_order_history_version_seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品结构历史版本（暂时作废）';


--
-- Table structure for table `sample_technology`
--

DROP TABLE IF EXISTS `sample_technology`;


CREATE TABLE `sample_technology` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sample_order_seq` int DEFAULT NULL COMMENT '样品单序号',
  `type` varchar(255) DEFAULT NULL COMMENT '类别\r\n10、印刷\r\n20、高频\r\n30、电绣\r\n40、生产注意事项\r\n50、其他',
  `no` varchar(255) DEFAULT NULL COMMENT '序号',
  `content` text COMMENT '内容',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品单工艺要求（暂时作废）';


--
-- Table structure for table `sample_technology_history_version`
--

DROP TABLE IF EXISTS `sample_technology_history_version`;


CREATE TABLE `sample_technology_history_version` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sample_order_history_version_seq` int DEFAULT NULL COMMENT '样品单历史版本序号',
  `type` varchar(255) DEFAULT NULL COMMENT '类别',
  `content` text COMMENT '内容',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品单工艺要求历史版本（暂时作废）';


--
-- Table structure for table `sop_cover`
--

DROP TABLE IF EXISTS `sop_cover`;


CREATE TABLE `sop_cover` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `document_num` varchar(50) DEFAULT NULL COMMENT '文件编号',
  `version` double DEFAULT NULL COMMENT '版本号',
  `page_num` varchar(50) DEFAULT NULL COMMENT '页数',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT NULL COMMENT '是否删除0-否，1-是',
  `template` varchar(255) DEFAULT NULL COMMENT '模板',
  `pdf` varchar(255) DEFAULT NULL COMMENT 'pdf路径',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP封面表';


--
-- Table structure for table `sop_directory`
--

DROP TABLE IF EXISTS `sop_directory`;


CREATE TABLE `sop_directory` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `document_num` varchar(50) DEFAULT NULL COMMENT '文件编号',
  `iso_document_num` varchar(50) DEFAULT NULL COMMENT 'ISO 文件编号',
  `version` double NOT NULL COMMENT '版本号',
  `sort` int DEFAULT NULL COMMENT '排序',
  `item` varchar(100) DEFAULT NULL COMMENT '项目',
  `instruction` varchar(255) DEFAULT NULL COMMENT '内容说明',
  `page_num` varchar(50) DEFAULT NULL COMMENT '页码',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT NULL COMMENT '是否删除0-否，1-是',
  `template` varchar(255) DEFAULT NULL COMMENT '模板',
  `pdf` varchar(255) DEFAULT NULL COMMENT 'pdf路径',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP目录';


--
-- Table structure for table `sop_expand`
--

DROP TABLE IF EXISTS `sop_expand`;


CREATE TABLE `sop_expand` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `parent_seq` int DEFAULT NULL COMMENT '父类seq',
  `manufacturing_process_code` varchar(50) DEFAULT NULL COMMENT '制程code',
  `workshop_section_code` varchar(50) DEFAULT NULL COMMENT '工段code',
  `working_procedure_code` varchar(50) DEFAULT NULL COMMENT '工序code',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `sop_key` varchar(255) DEFAULT NULL,
  `sop_name` varchar(255) DEFAULT NULL,
  `sop_value` varchar(255) DEFAULT NULL,
  `sop_type` varchar(255) DEFAULT NULL,
  `sop_images` varchar(255) DEFAULT NULL COMMENT '图片',
  `num` int DEFAULT NULL COMMENT '支数/块数',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP拓展表';


--
-- Table structure for table `sop_expand_child`
--

DROP TABLE IF EXISTS `sop_expand_child`;


CREATE TABLE `sop_expand_child` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `parent_seq` int DEFAULT NULL COMMENT '父类seq',
  `manufacturing_process_code` varchar(50) DEFAULT NULL COMMENT '制程code',
  `workshop_section_code` varchar(50) DEFAULT NULL COMMENT '工段code',
  `working_procedure_code` varchar(50) DEFAULT NULL COMMENT '工序code',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `sop_key` varchar(255) DEFAULT NULL,
  `sop_name` varchar(255) DEFAULT NULL,
  `sop_value` varchar(255) DEFAULT NULL,
  `sop_type` varchar(255) DEFAULT NULL,
  `sop_images` varchar(255) DEFAULT NULL COMMENT '图片',
  `num` int DEFAULT NULL COMMENT '支数/块数',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP操作明细拓展子表';


--
-- Table structure for table `sop_expand_easy`
--

DROP TABLE IF EXISTS `sop_expand_easy`;


CREATE TABLE `sop_expand_easy` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `parent_seq` int DEFAULT NULL COMMENT '父类seq',
  `manufacturing_process_code` varchar(50) DEFAULT NULL COMMENT '制程code',
  `workshop_section_code` varchar(50) DEFAULT NULL COMMENT '工段code',
  `working_procedure_code` varchar(50) DEFAULT NULL COMMENT '工序code',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `sop_key` varchar(255) DEFAULT NULL,
  `sop_name` varchar(255) DEFAULT NULL,
  `sop_value` varchar(255) DEFAULT NULL,
  `sop_type` varchar(255) DEFAULT NULL,
  `sop_images` varchar(255) DEFAULT NULL COMMENT '图片',
  `num` int DEFAULT NULL COMMENT '支数/块数',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP简易流程图拓展子表';


--
-- Table structure for table `sop_expand_process`
--

DROP TABLE IF EXISTS `sop_expand_process`;


CREATE TABLE `sop_expand_process` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `parent_seq` int DEFAULT NULL COMMENT '父类seq',
  `manufacturing_process_code` varchar(50) DEFAULT NULL COMMENT '制程code',
  `workshop_section_code` varchar(50) DEFAULT NULL COMMENT '工段code',
  `working_procedure_code` varchar(50) DEFAULT NULL COMMENT '工序code',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `sop_key` varchar(255) DEFAULT NULL,
  `sop_name` varchar(255) DEFAULT NULL,
  `sop_value` varchar(255) DEFAULT NULL,
  `sop_type` varchar(255) DEFAULT NULL,
  `sop_images` varchar(255) DEFAULT NULL COMMENT '图片',
  `num` int DEFAULT NULL COMMENT '支数/块数',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP操作明细拓展表';


--
-- Table structure for table `sop_form_business`
--

DROP TABLE IF EXISTS `sop_form_business`;


CREATE TABLE `sop_form_business` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `form_seq` int DEFAULT NULL COMMENT 'sop表单seq',
  `business_seq` int DEFAULT NULL COMMENT '业务seq',
  `processing` int DEFAULT NULL COMMENT '制程',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='sop表单业务关联';


--
-- Table structure for table `sop_form_data`
--

DROP TABLE IF EXISTS `sop_form_data`;


CREATE TABLE `sop_form_data` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `form_seq` int DEFAULT NULL COMMENT 'sop表单',
  `form_node_id` varchar(255) DEFAULT NULL COMMENT '表单节点',
  `form_node_name` varchar(255) DEFAULT NULL COMMENT '表单节点名称',
  `sop_form_key` varchar(255) DEFAULT NULL COMMENT '表单key',
  `sop_form_value` varchar(255) DEFAULT NULL COMMENT '表单value',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sop_manufacturing_pro_work_section`
--

DROP TABLE IF EXISTS `sop_manufacturing_pro_work_section`;


CREATE TABLE `sop_manufacturing_pro_work_section` (
  `manufacturing_process_seq` int DEFAULT NULL COMMENT '制程主键ID',
  `workshop_section_seq` int DEFAULT NULL COMMENT '工段主键ID'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='制程工段关联关系表';


--
-- Table structure for table `sop_manufacturing_process`
--

DROP TABLE IF EXISTS `sop_manufacturing_process`;


CREATE TABLE `sop_manufacturing_process` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `make_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `make_code` varchar(50) DEFAULT NULL COMMENT '制程编码',
  `make_desc` varchar(255) DEFAULT NULL COMMENT '制程描述',
  `sort` int DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  `delete_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '删除人',
  `delete_date` datetime DEFAULT NULL COMMENT '删除时间',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `page_address` varchar(255) DEFAULT NULL COMMENT '页面位置',
  `is_available` char(1) DEFAULT NULL COMMENT '是否可用（0：不可用 1：可用）',
  `version` double DEFAULT NULL COMMENT '版本号',
  `time1` varchar(10) DEFAULT NULL COMMENT '任务分配时SOP指导书制作时间总占比',
  `time2` varchar(10) DEFAULT NULL COMMENT '任务分配时SOP指导书制作催办时间占比',
  `time3` varchar(10) DEFAULT NULL COMMENT '任务分配时SOP审批催办时间占比',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='SOP制程表';


--
-- Table structure for table `sop_operation_easy_process`
--

DROP TABLE IF EXISTS `sop_operation_easy_process`;


CREATE TABLE `sop_operation_easy_process` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `manufacturing_process_code` varchar(50) DEFAULT NULL COMMENT '制程code',
  `manufacturing_process_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `workshop_section_code` varchar(50) DEFAULT NULL COMMENT '工段code',
  `workshop_section_name` varchar(255) DEFAULT NULL COMMENT '工段名称',
  `working_procedure_code` varchar(50) DEFAULT NULL COMMENT '工序code',
  `working_procedure_name` varchar(255) DEFAULT NULL COMMENT '工序名称',
  `document_num` varchar(50) DEFAULT NULL COMMENT '文件编号',
  `iso_document_num` varchar(50) DEFAULT NULL COMMENT 'ISO 文件编号',
  `sort` int DEFAULT NULL COMMENT '排序',
  `page_num` varchar(50) DEFAULT NULL COMMENT '页码',
  `version` double DEFAULT '1' COMMENT '版本号',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  `step` varchar(255) DEFAULT NULL COMMENT '步骤',
  `quality_inspection` varchar(255) DEFAULT NULL COMMENT '质量检查',
  `process_components` varchar(255) DEFAULT NULL COMMENT '工艺部件',
  `all_num` int DEFAULT NULL COMMENT '合计',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `operating_instructions` varchar(255) DEFAULT NULL COMMENT '操作示意图',
  `template` varchar(255) DEFAULT NULL COMMENT '模板',
  `status` varchar(10) DEFAULT NULL COMMENT '状态(0暂存 1保存)',
  `pdf` varchar(255) DEFAULT NULL COMMENT 'pdf路径',
  `page_size` varchar(30) DEFAULT NULL COMMENT '页标',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='sku制程工段工序简易流程表';


--
-- Table structure for table `sop_operation_easy_process_child`
--

DROP TABLE IF EXISTS `sop_operation_easy_process_child`;


CREATE TABLE `sop_operation_easy_process_child` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `parent_seq` int DEFAULT NULL COMMENT '父级seq',
  `sort` int DEFAULT NULL COMMENT '排序',
  `manufacturing_process_seq` int DEFAULT NULL COMMENT '制程seq',
  `workshop_section_seq` int DEFAULT NULL COMMENT '工段seq',
  `working_procedure_seq` int DEFAULT NULL COMMENT '工序seq',
  `process_name` varchar(255) DEFAULT NULL COMMENT '流程名称',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `version` varchar(50) DEFAULT NULL COMMENT '版本号',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT NULL COMMENT '是否删除0-否，1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='sku制程工段工序简易流程明细表';


--
-- Table structure for table `sop_operation_easy_process_parent`
--

DROP TABLE IF EXISTS `sop_operation_easy_process_parent`;


CREATE TABLE `sop_operation_easy_process_parent` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `manufacturing_process_seq` int DEFAULT NULL COMMENT '制程seq',
  `workshop_section_seq` int DEFAULT NULL COMMENT '工段seq',
  `working_procedure_seq` int DEFAULT NULL COMMENT '工序seq',
  `document_num` varbinary(50) DEFAULT NULL COMMENT '文件编号',
  `iso_document_num` varbinary(50) DEFAULT NULL COMMENT 'ISO 文件编号',
  `page_num` varchar(50) DEFAULT NULL COMMENT '页数',
  `step` varchar(255) DEFAULT NULL COMMENT '步骤',
  `quality_inspection` text COMMENT '质量检查',
  `version` varchar(50) DEFAULT NULL COMMENT '版本号',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT NULL COMMENT '是否删除0-否，1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='sku制程工段工序简易流程父表';


--
-- Table structure for table `sop_operation_focus`
--

DROP TABLE IF EXISTS `sop_operation_focus`;


CREATE TABLE `sop_operation_focus` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `manufacturing_process_code` varchar(50) DEFAULT NULL COMMENT '制程code',
  `manufacturing_process_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `workshop_section_code` varchar(50) DEFAULT NULL COMMENT '工段code',
  `workshop_section_name` varchar(255) NOT NULL COMMENT '工段名称',
  `working_procedure_code` varchar(50) DEFAULT NULL COMMENT '工序code',
  `working_procedure_name` varchar(255) DEFAULT NULL COMMENT '工序名称',
  `document_num` varchar(50) DEFAULT NULL COMMENT '文件编号',
  `iso_document_num` varchar(50) DEFAULT NULL COMMENT 'ISO 文件编号',
  `operating_instructions` varchar(255) DEFAULT NULL COMMENT '操作示意图说明',
  `sort` int DEFAULT NULL COMMENT '排序',
  `page_num` varchar(50) DEFAULT NULL COMMENT '页数',
  `version` double DEFAULT '1' COMMENT '版本号',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  `template` varchar(255) DEFAULT NULL COMMENT '模板',
  `pdf` varchar(255) DEFAULT NULL COMMENT 'pdf路径',
  `status` varchar(10) DEFAULT NULL COMMENT '状态(0暂存 1保存)',
  `page_size` varchar(30) DEFAULT NULL COMMENT '页标',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP操作重点表';


--
-- Table structure for table `sop_operation_process_child`
--

DROP TABLE IF EXISTS `sop_operation_process_child`;


CREATE TABLE `sop_operation_process_child` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `parent_seq` int DEFAULT NULL COMMENT '父级seq',
  `sort` int DEFAULT NULL COMMENT '排序',
  `page_num` varchar(50) DEFAULT NULL COMMENT '页数',
  `version` double DEFAULT NULL COMMENT '版本号',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部件',
  `material_name` varchar(255) DEFAULT NULL COMMENT '材料名称',
  `operating_instructions` varchar(255) DEFAULT NULL COMMENT '操作示意图说明',
  `cutting_layer_direction` varchar(255) DEFAULT NULL COMMENT '裁层方向',
  `cutting_layer1` varchar(255) DEFAULT NULL COMMENT '裁层说明1',
  `cutting_layer2` varchar(255) DEFAULT NULL COMMENT '裁层说明2',
  `step` varchar(255) DEFAULT NULL COMMENT '步骤',
  `effective_date` datetime DEFAULT NULL COMMENT '生效日期',
  `material` varchar(255) DEFAULT NULL COMMENT '材料',
  `glue` varchar(255) DEFAULT NULL COMMENT '胶水',
  `fitting_method` varchar(255) DEFAULT NULL COMMENT '贴合方法',
  `pressure` varchar(255) DEFAULT NULL COMMENT '压力',
  `time` datetime DEFAULT NULL COMMENT '时间',
  `surface_temperature` varchar(255) DEFAULT NULL COMMENT '表温度',
  `actual_temperature` varchar(255) DEFAULT NULL COMMENT '实际温度',
  `interlayer_temperature` varchar(255) DEFAULT NULL COMMENT '夹层温度',
  `specifications_content` varchar(255) DEFAULT NULL COMMENT '规格说明',
  `line_spacing` varchar(255) DEFAULT NULL COMMENT '行距',
  `margins` varchar(255) DEFAULT NULL COMMENT '边距',
  `stitch_length` varchar(255) DEFAULT NULL COMMENT '针距',
  `supplies` varchar(255) DEFAULT NULL COMMENT '用品',
  `operation_point` varchar(255) DEFAULT NULL COMMENT '操作要点',
  `inspection_points` varchar(255) DEFAULT NULL COMMENT '检查要点',
  `operate_name` varchar(255) DEFAULT NULL COMMENT '操作名称',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='sku制程工段工序流程操作明细表';


--
-- Table structure for table `sop_operation_process_parent`
--

DROP TABLE IF EXISTS `sop_operation_process_parent`;


CREATE TABLE `sop_operation_process_parent` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `manufacturing_process_code` varchar(50) DEFAULT NULL COMMENT '制程code',
  `manufacturing_process_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `workshop_section_code` varchar(50) DEFAULT NULL COMMENT '工段code',
  `workshop_section_name` varchar(255) DEFAULT NULL COMMENT '工段名称',
  `working_procedure_code` varchar(50) DEFAULT NULL COMMENT '工序code',
  `working_procedure_name` varchar(255) DEFAULT NULL COMMENT '工序名称',
  `document_num` varchar(50) DEFAULT NULL COMMENT '文件编号',
  `iso_document_num` varchar(50) DEFAULT NULL COMMENT 'ISO 文件编号',
  `sort` int DEFAULT NULL COMMENT '排序',
  `page_num` varchar(50) DEFAULT NULL COMMENT '页数',
  `version` double DEFAULT '1' COMMENT '版本号',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  `segmentation` varchar(255) DEFAULT NULL COMMENT '分段明细',
  `operation_point` text COMMENT '操作要点',
  `inspection_points` text COMMENT '检查要点',
  `step` text COMMENT '步骤',
  `operating_instructions` varchar(255) DEFAULT NULL COMMENT '操作示意图说明',
  `template` varchar(255) DEFAULT NULL COMMENT '模板',
  `effective_at` datetime DEFAULT NULL COMMENT '生效日期',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部件',
  `pdf` varchar(255) DEFAULT NULL COMMENT 'pdf路径',
  `operate_name` varchar(255) DEFAULT NULL COMMENT '操作名称',
  `all_num` varchar(11) DEFAULT NULL COMMENT '合计',
  `status` varchar(10) DEFAULT NULL COMMENT '状态(0暂存 1保存)',
  `page_size` varchar(30) DEFAULT NULL COMMENT '页标',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='sku制程工段工序流程操作父表';


--
-- Table structure for table `sop_page_param_setting`
--

DROP TABLE IF EXISTS `sop_page_param_setting`;


CREATE TABLE `sop_page_param_setting` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `param_seq` int DEFAULT NULL COMMENT 'sop参数序号',
  `page_seq` int DEFAULT NULL COMMENT 'sop页面序号',
  `maintain_seq` int DEFAULT NULL COMMENT '工段seq',
  `no` varchar(50) DEFAULT NULL COMMENT '参数排序',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP页面参数设置关系表';


--
-- Table structure for table `sop_page_setting`
--

DROP TABLE IF EXISTS `sop_page_setting`;


CREATE TABLE `sop_page_setting` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `name` varchar(255) DEFAULT NULL COMMENT '页面名称',
  `process_maintain` int DEFAULT NULL COMMENT '工序动作',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP页面设置';


--
-- Table structure for table `sop_param_propertist`
--

DROP TABLE IF EXISTS `sop_param_propertist`;


CREATE TABLE `sop_param_propertist` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `param_seq` int DEFAULT NULL COMMENT 'SOP参数序号',
  `key` varchar(100) DEFAULT NULL COMMENT '字段key',
  `name` varchar(100) DEFAULT NULL COMMENT '字段名称',
  `value` longtext COMMENT '字段value',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='sop参数拓展信息';


--
-- Table structure for table `sop_param_setting`
--

DROP TABLE IF EXISTS `sop_param_setting`;


CREATE TABLE `sop_param_setting` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `name` varchar(100) DEFAULT NULL COMMENT '字段名称',
  `key` varchar(100) DEFAULT NULL COMMENT '字段key',
  `type` varchar(255) DEFAULT NULL COMMENT '字段类别-1：系统默认；2：自定义',
  `no` varchar(11) DEFAULT NULL COMMENT '表头顺序',
  `value_type` char(2) DEFAULT NULL COMMENT '值类型-1：字符串；2：数字；3：图片；',
  `is_deleted` char(1) DEFAULT NULL COMMENT '是否删除0-否，1-是',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP参数设置';


--
-- Table structure for table `sop_process_maintain`
--

DROP TABLE IF EXISTS `sop_process_maintain`;


CREATE TABLE `sop_process_maintain` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `action` varchar(255) DEFAULT NULL COMMENT '工序动作',
  `section_name` int DEFAULT NULL COMMENT '工段名称',
  `process_type` int DEFAULT NULL COMMENT '工序类别',
  `put_way` int DEFAULT NULL COMMENT '报产方式',
  `storage_mode` int DEFAULT NULL COMMENT '入库方式',
  `status` char(2) DEFAULT NULL COMMENT '状态',
  `processing` int DEFAULT NULL COMMENT '制程',
  `is_deleted` char(1) DEFAULT NULL COMMENT '是否删除0-否,1-是',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='工段维护';


--
-- Table structure for table `sop_resource`
--

DROP TABLE IF EXISTS `sop_resource`;


CREATE TABLE `sop_resource` (
  `seq` bigint NOT NULL AUTO_INCREMENT COMMENT 'seq',
  `sku` varchar(255) DEFAULT NULL COMMENT 'sku',
  `url` varchar(255) DEFAULT NULL COMMENT 'url',
  `type` char(1) DEFAULT NULL COMMENT '0: sku操作书附件 1：sku操作书',
  `old_name` varchar(255) DEFAULT NULL COMMENT '附件名称',
  `demo` varchar(255) DEFAULT NULL COMMENT '项目',
  `content` varchar(255) DEFAULT NULL COMMENT '内容',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP附件表';


--
-- Table structure for table `sop_size_comparison`
--

DROP TABLE IF EXISTS `sop_size_comparison`;


CREATE TABLE `sop_size_comparison` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `document_num` varchar(50) DEFAULT NULL COMMENT '文件编号',
  `iso_document_num` varchar(50) DEFAULT NULL COMMENT 'ISO 文件编号',
  `sort` int DEFAULT NULL COMMENT '排序',
  `page_num` varchar(50) DEFAULT NULL COMMENT '页数',
  `version` double DEFAULT NULL COMMENT '版本号',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  `name` varchar(100) DEFAULT NULL COMMENT '类别/名称',
  `num` int DEFAULT NULL COMMENT '支数/块数',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `size_value` blob COMMENT '码段值（使用 | 拼接）',
  `size_type` char(1) DEFAULT NULL COMMENT '码段值类型（0：值  1：*）',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='SOP尺码对照表';


--
-- Table structure for table `sop_sku_manufacturing_process`
--

DROP TABLE IF EXISTS `sop_sku_manufacturing_process`;


CREATE TABLE `sop_sku_manufacturing_process` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `sku` varchar(255) DEFAULT NULL COMMENT '型体sku',
  `manufacturing_process_code` varchar(50) DEFAULT NULL COMMENT '制程code',
  `manufacturing_process_name` varchar(255) DEFAULT NULL COMMENT '制程名称',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `user_name` varchar(30) NOT NULL COMMENT '用户昵称',
  `status` varchar(10) DEFAULT NULL COMMENT '状态（已分配：32，制程设置中：33，已完成：34）',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除0-否，1-是',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='sku制程关联关系表';


--
-- Table structure for table `sop_sys_form`
--

DROP TABLE IF EXISTS `sop_sys_form`;


CREATE TABLE `sop_sys_form` (
  `form_seq` bigint NOT NULL AUTO_INCREMENT COMMENT '表单主键',
  `form_name` varchar(50) DEFAULT NULL COMMENT '表单名称',
  `form_content` longtext COMMENT '表单内容',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `create_by` varchar(50) DEFAULT NULL COMMENT '创建人员',
  `update_by` varchar(50) DEFAULT NULL COMMENT '更新人员',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`form_seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='sop流程表单';


--
-- Table structure for table `sop_working_page_param`
--

DROP TABLE IF EXISTS `sop_working_page_param`;


CREATE TABLE `sop_working_page_param` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `procedure_seq` int DEFAULT NULL COMMENT '工序流seq',
  `page_seqpage_seq` int DEFAULT NULL COMMENT 'SOP页面seq',
  `sop_page_param_setting_seq` int DEFAULT NULL COMMENT '页面参数seq',
  `value` varchar(255) DEFAULT NULL COMMENT '页面参数值',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='工序流sop页面参数关联表';


--
-- Table structure for table `sop_working_procedure`
--

DROP TABLE IF EXISTS `sop_working_procedure`;


CREATE TABLE `sop_working_procedure` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `process_name` varchar(255) DEFAULT NULL COMMENT '工序名称',
  `process_code` varchar(50) DEFAULT NULL COMMENT '工序编码',
  `process_desc` varchar(255) DEFAULT NULL COMMENT '工序描述',
  `sort` int DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  `delete_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '删除人',
  `delete_date` datetime DEFAULT NULL COMMENT '删除时间',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `page_address` varchar(255) DEFAULT NULL COMMENT '页面位置',
  `is_available` char(1) DEFAULT NULL COMMENT '是否可用（0：不可用 1：可用）',
  `version` double DEFAULT NULL COMMENT '版本号',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='SOP工序表';


--
-- Table structure for table `sop_workshop_section`
--

DROP TABLE IF EXISTS `sop_workshop_section`;


CREATE TABLE `sop_workshop_section` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `section_name` varchar(255) DEFAULT NULL COMMENT '工段名称',
  `section_code` varchar(50) DEFAULT NULL COMMENT '工段编码',
  `section_desc` varchar(255) DEFAULT NULL COMMENT '工段描述',
  `sort` int DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  `delete_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '删除人',
  `delete_date` datetime DEFAULT NULL COMMENT '删除时间',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `page_address` varchar(255) DEFAULT NULL COMMENT '页面位置',
  `is_available` char(1) DEFAULT NULL COMMENT '是否可用（0：不可用 1：可用）',
  `version` double DEFAULT NULL COMMENT '版本号',
  `created_name` varchar(255) DEFAULT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='SOP工段表';


--
-- Table structure for table `stock`
--

DROP TABLE IF EXISTS `stock`;


CREATE TABLE `stock` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `clazz` char(2) DEFAULT NULL COMMENT '单据分类\r\n10 入库\r\n20 出库',
  `type` char(2) DEFAULT NULL COMMENT '物品类型\r\n10 物料\r\n20 样鞋\r\n30 成品鞋',
  `aritlec_seq` int DEFAULT NULL COMMENT '型体表序号',
  `size` double DEFAULT NULL COMMENT '码号',
  `material_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `quantity` varchar(255) DEFAULT NULL COMMENT '汇总',
  `residue_amount` varchar(255) DEFAULT NULL COMMENT '剩余',
  `unit` varchar(255) DEFAULT NULL COMMENT '单位',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_delete` int DEFAULT '0' COMMENT '未删除：0 删除：1 ',
  `out_stock` varchar(255) DEFAULT NULL,
  `create_date` datetime DEFAULT NULL,
  `no` int DEFAULT NULL,
  `warehouse_no` int DEFAULT NULL,
  `place` varchar(255) DEFAULT NULL,
  `stock_type` varchar(255) DEFAULT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `amount` int DEFAULT NULL,
  `issue` varchar(255) DEFAULT NULL,
  `org` varchar(255) DEFAULT NULL,
  `tenant` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='库存';


--
-- Table structure for table `stock_info`
--

DROP TABLE IF EXISTS `stock_info`;


CREATE TABLE `stock_info` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT 'seq',
  `store_seq` int DEFAULT NULL COMMENT '库存表序号',
  `no` varchar(255) DEFAULT NULL COMMENT '批次号',
  `stock_no` varchar(255) DEFAULT NULL COMMENT '当库存类型为出库时，该字段值为出库单包含的入库批次号',
  `storage` varchar(255) DEFAULT NULL COMMENT '数量',
  `residue_amount` varchar(255) DEFAULT NULL COMMENT '剩余',
  `unit` varchar(255) DEFAULT NULL COMMENT '单位',
  `warehouse_no` int DEFAULT NULL COMMENT '仓库',
  `place` varchar(255) NOT NULL COMMENT '存储位置',
  `trading_object` varchar(255) DEFAULT NULL COMMENT '交易对象',
  `trading_currency` varchar(255) DEFAULT NULL COMMENT '交易货币',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  `amount` double(255,0) DEFAULT NULL COMMENT '金额',
  `date` timestamp NULL DEFAULT NULL COMMENT '入/出库时间',
  `create_date` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_delete` int(1) unsigned zerofill DEFAULT '0' COMMENT '0:未删除  1:删除',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='库存详情';


--
-- Table structure for table `storage`
--

DROP TABLE IF EXISTS `storage`;


CREATE TABLE `storage` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `storehouse_seq` int DEFAULT NULL COMMENT '外键',
  `code` varchar(22) DEFAULT NULL COMMENT '储位编号',
  `place` varchar(24) DEFAULT NULL COMMENT '位置',
  `amount` varchar(24) DEFAULT NULL COMMENT '容量',
  `free_space` varchar(24) DEFAULT NULL COMMENT '剩余容量',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `storehouse_foregin_key` (`storehouse_seq`) USING BTREE,
  CONSTRAINT `storehouse_foregin_key` FOREIGN KEY (`storehouse_seq`) REFERENCES `storehouse` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='储位表';


--
-- Table structure for table `store`
--

DROP TABLE IF EXISTS `store`;


CREATE TABLE `store` (
  `id` varchar(36) NOT NULL,
  `material_seq` int NOT NULL COMMENT '物料编码ID',
  `material_code` varchar(255) NOT NULL COMMENT '物料编码',
  `material_category_code` varchar(255) NOT NULL COMMENT '物料简码',
  `material_name` varchar(255) NOT NULL COMMENT '物料名称',
  `product_code` varchar(80) NOT NULL DEFAULT '0000000000' COMMENT '生产订单号''0000000000''虚拟号',
  `customer_seq` int NOT NULL COMMENT '客户编码',
  `customer_name` varchar(80) NOT NULL DEFAULT 'KH000000000000' COMMENT '客户名称''KH000000000000''虚拟客户',
  `supply_seq` int NOT NULL COMMENT '供应商Id',
  `supply_name` varchar(255) NOT NULL COMMENT '供应商名称',
  `warehouse_code` varchar(80) NOT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(80) NOT NULL COMMENT '仓库名称',
  `location_code` varchar(80) NOT NULL COMMENT '储位编号',
  `location_name` varchar(80) NOT NULL COMMENT '储位名称',
  `on_hand_qty` decimal(30,2) unsigned DEFAULT NULL COMMENT '仓库库数量(在库)',
  `on_order_qty` decimal(30,2) DEFAULT NULL COMMENT '在途数量',
  `total_qty` decimal(30,2) DEFAULT NULL COMMENT '总库存数量',
  `enable` char(1) DEFAULT '1',
  `is_deleted` char(1) DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_by` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `remark1` varchar(255) DEFAULT NULL COMMENT '备用字段',
  `remark2` varchar(255) DEFAULT NULL COMMENT '备用字段',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `transfer_inventory_qty` decimal(13,4) DEFAULT NULL COMMENT '调拨入库数量',
  `transfer_outbound_qty` decimal(13,4) DEFAULT NULL COMMENT '调拨出库数量',
  `row_no` varchar(100) DEFAULT NULL COMMENT '订单标识号=行号和生产指令号一一对应',
  `sku` varchar(500) DEFAULT NULL COMMENT '款式',
  `manual_prod_code` text COMMENT '手工排产单号',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `size` varchar(500) DEFAULT NULL COMMENT 'size',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色名称',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `storeIdx` (`material_seq`,`material_code`,`material_category_code`,`product_code`,`customer_seq`,`supply_seq`,`warehouse_code`,`location_code`,`position_seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='库存表';


--
-- Table structure for table `store_detail_list`
--

DROP TABLE IF EXISTS `store_detail_list`;


CREATE TABLE `store_detail_list` (
  `id` varchar(36) NOT NULL,
  `bill_no` varchar(50) NOT NULL COMMENT '单据编号',
  `bill_seq` int DEFAULT NULL COMMENT '单据seq',
  `bill_info_seq` int DEFAULT NULL COMMENT '单据明细seq',
  `material_seq` int NOT NULL COMMENT '物料编码ID',
  `material_code` varchar(255) NOT NULL COMMENT '物料编码',
  `material_category_code` varchar(255) NOT NULL COMMENT '物料简码',
  `material_name` varchar(255) NOT NULL COMMENT '物料名称',
  `product_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `product_code` varchar(80) NOT NULL DEFAULT '0000000000' COMMENT '生产订单号''0000000000''虚拟号',
  `customer_seq` int DEFAULT NULL COMMENT '客户编码',
  `customer_name` varchar(80) DEFAULT 'KH000000000000' COMMENT '客户名称''KH000000000000''虚拟客户',
  `supply_seq` int NOT NULL COMMENT '供应商Id',
  `supply_name` varchar(255) NOT NULL COMMENT '供应商名称',
  `batch_no` int DEFAULT NULL COMMENT '批次',
  `in_warehouse_code` varchar(80) DEFAULT NULL COMMENT '仓库编号',
  `in_warehouse_name` varchar(80) DEFAULT NULL COMMENT '仓库名称',
  `in_location_code` varchar(80) DEFAULT NULL COMMENT '储位编号',
  `in_location_name` varchar(80) DEFAULT NULL COMMENT '储位名称',
  `in_rate` decimal(18,3) DEFAULT NULL COMMENT '税率',
  `in_rate_price` decimal(10,2) DEFAULT NULL COMMENT '入库含税单价',
  `in_qty` decimal(18,2) DEFAULT '0.00' COMMENT '入库数量',
  `acc_qty` decimal(18,2) DEFAULT '0.00' COMMENT '记账数量',
  `out_warehouse_code` varchar(80) DEFAULT NULL COMMENT '出库仓库编号',
  `out_warehouse_name` varchar(80) DEFAULT NULL COMMENT '出库仓库名称',
  `out_location_code` varchar(80) DEFAULT NULL COMMENT '出库储位编号',
  `out_location_name` varchar(80) DEFAULT NULL COMMENT '出库储位名称',
  `out_rate` decimal(18,3) DEFAULT NULL COMMENT '出库',
  `out_rate_price` decimal(10,2) DEFAULT NULL COMMENT '出库',
  `out_qty` decimal(18,2) DEFAULT '0.00' COMMENT '出库数量',
  `enable` char(1) DEFAULT '1',
  `is_deleted` char(1) DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_by` varchar(255) DEFAULT NULL,
  `remark1` varchar(255) DEFAULT NULL COMMENT '备用字段',
  `remark2` varchar(255) DEFAULT NULL COMMENT '备用字段',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `transfer_inventory_qty` decimal(13,4) DEFAULT NULL COMMENT '调拨入库数量',
  `transfer_outbound_qty` decimal(13,4) DEFAULT NULL COMMENT '调拨出库数量',
  `size` varchar(500) DEFAULT NULL COMMENT 'size',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色名称',
  `manual_prod_code` varchar(200) DEFAULT NULL COMMENT '手工排产单号',
  `po` varchar(500) DEFAULT NULL COMMENT '订单标识号=行号和生产指令号一一对应',
  `sku` varchar(500) DEFAULT NULL COMMENT '款式',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `row_no` varchar(200) DEFAULT NULL COMMENT '行标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='库存变动明细表(有成本)';


--
-- Table structure for table `store_in_list`
--

DROP TABLE IF EXISTS `store_in_list`;


CREATE TABLE `store_in_list` (
  `id` varchar(36) NOT NULL,
  `bill_no` varchar(50) NOT NULL COMMENT '单据编号',
  `bill_info_seq` int DEFAULT NULL COMMENT '单据明细seq',
  `bill_seq` int DEFAULT NULL COMMENT '单据seq',
  `material_seq` int NOT NULL COMMENT '物料编码ID',
  `material_code` varchar(255) NOT NULL COMMENT '物料编码',
  `material_category_code` varchar(255) NOT NULL COMMENT '物料简码',
  `material_name` varchar(255) NOT NULL COMMENT '物料名称',
  `product_seq` int DEFAULT '1' COMMENT '生产订单seq',
  `product_code` varchar(80) NOT NULL DEFAULT '0000000000' COMMENT '生产订单号''0000000000''虚拟号',
  `customer_seq` int NOT NULL COMMENT '客户编码',
  `customer_name` varchar(80) NOT NULL DEFAULT 'KH000000000000' COMMENT '客户名称''KH000000000000''虚拟客户',
  `supply_seq` int NOT NULL COMMENT '供应商Id',
  `supply_name` varchar(255) NOT NULL COMMENT '供应商名称',
  `batch_no` int NOT NULL COMMENT '入库批次',
  `warehouse_code` varchar(80) NOT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(80) NOT NULL COMMENT '仓库名称',
  `location_code` varchar(80) NOT NULL COMMENT '储位编号',
  `location_name` varchar(80) NOT NULL COMMENT '储位名称',
  `rate` decimal(18,3) DEFAULT NULL COMMENT '税率',
  `rate_price` decimal(10,2) DEFAULT NULL COMMENT '含税单价',
  `in_qty` decimal(18,2) DEFAULT '0.00' COMMENT '入库数量',
  `out_qty` decimal(18,2) DEFAULT '0.00' COMMENT '出库数量',
  `remain_qty` decimal(18,2) DEFAULT NULL COMMENT '剩余量',
  `acc_qty` decimal(18,2) DEFAULT NULL COMMENT '记账数量',
  `enable` char(1) DEFAULT '1',
  `is_deleted` char(1) DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_by` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `remark1` varchar(255) DEFAULT NULL COMMENT '备用字段',
  `remark2` varchar(255) DEFAULT NULL COMMENT '备用字段',
  `delivery_note_number` varchar(100) DEFAULT NULL COMMENT '送货单号',
  `batch_number` varchar(100) DEFAULT NULL COMMENT '送货批次',
  `material_manager` varchar(255) DEFAULT NULL COMMENT '材料负责人',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `transfer_inventory_qty` decimal(13,4) DEFAULT NULL COMMENT '调拨入库数量',
  `transfer_outbound_qty` decimal(13,4) DEFAULT NULL COMMENT '调拨出库数量',
  `size` varchar(500) DEFAULT NULL COMMENT 'size',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色名称',
  `manual_prod_code` varchar(200) DEFAULT NULL COMMENT '手工排产单号',
  `po` varchar(500) DEFAULT NULL COMMENT '订单标识号=行号和生产指令号一一对应',
  `sku` varchar(500) DEFAULT NULL COMMENT '款式',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `row_no` varchar(200) DEFAULT NULL COMMENT '行标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='库存表-入库';


--
-- Table structure for table `store_out_list`
--

DROP TABLE IF EXISTS `store_out_list`;


CREATE TABLE `store_out_list` (
  `id` varchar(36) NOT NULL,
  `bill_no` varchar(50) NOT NULL COMMENT '单据编号',
  `bill_seq` int DEFAULT NULL COMMENT '单据编号seq',
  `bill_info_seq` int DEFAULT NULL COMMENT '单据编号明细seq',
  `material_seq` int NOT NULL COMMENT '物料编码ID',
  `material_code` varchar(255) NOT NULL COMMENT '物料编码',
  `material_category_code` varchar(255) NOT NULL COMMENT '物料简码',
  `material_name` varchar(255) NOT NULL COMMENT '物料名称',
  `product_seq` int DEFAULT NULL COMMENT '生产订单seq',
  `product_code` varchar(80) NOT NULL COMMENT '生产订单号',
  `customer_seq` int DEFAULT NULL COMMENT '客户编码',
  `customer_name` varchar(80) DEFAULT NULL COMMENT '客户名称',
  `supply_seq` int NOT NULL COMMENT '供应商Id',
  `supply_name` varchar(255) NOT NULL COMMENT '供应商名称',
  `batch_no` int NOT NULL COMMENT '入库批次',
  `warehouse_code` varchar(80) NOT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(80) NOT NULL COMMENT '仓库名称',
  `location_code` varchar(80) NOT NULL COMMENT '储位编号',
  `location_name` varchar(80) NOT NULL COMMENT '储位名称',
  `rate` decimal(18,3) DEFAULT NULL COMMENT '税率',
  `rate_price` decimal(10,2) DEFAULT NULL COMMENT '含税单价',
  `out_qty` decimal(18,2) DEFAULT '0.00' COMMENT '出库数量',
  `enable` char(1) DEFAULT '1',
  `is_deleted` char(1) DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_by` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `remark1` varchar(255) DEFAULT NULL COMMENT '备用字段',
  `remark2` varchar(255) DEFAULT NULL COMMENT '备用字段',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '昵称',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `transfer_inventory_qty` decimal(13,4) DEFAULT NULL COMMENT '调拨入库数量',
  `transfer_outbound_qty` decimal(13,4) DEFAULT NULL COMMENT '调拨出库数量',
  `size` varchar(500) DEFAULT NULL COMMENT 'size',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色名称',
  `manual_prod_code` varchar(200) DEFAULT NULL COMMENT '手工排产单号',
  `po` varchar(500) DEFAULT NULL COMMENT '订单标识号=行号和生产指令号一一对应',
  `sku` varchar(500) DEFAULT NULL COMMENT '款式',
  `factory_id` int DEFAULT NULL COMMENT '工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '工厂名称',
  `row_no` varchar(200) DEFAULT NULL COMMENT '行标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='库存表-出库';


--
-- Table structure for table `store_substitute_info`
--

DROP TABLE IF EXISTS `store_substitute_info`;


CREATE TABLE `store_substitute_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `transfer_seq` int DEFAULT NULL COMMENT '调拨主表seq',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码ID',
  `material_info_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `color_code` varchar(255) DEFAULT NULL COMMENT '颜色编码',
  `size_name` varchar(255) DEFAULT NULL COMMENT '尺码名称',
  `size_code` varchar(255) DEFAULT NULL COMMENT '尺码编码',
  `supply_seq` int DEFAULT NULL COMMENT '供应商Id',
  `supply_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `transfer_seq` (`transfer_seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='材料代用物料表';


--
-- Table structure for table `store_transfer`
--

DROP TABLE IF EXISTS `store_transfer`;


CREATE TABLE `store_transfer` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `transfer_code` varchar(50) DEFAULT NULL COMMENT '调拨单号',
  `transfer_type` varchar(50) DEFAULT NULL COMMENT '调拨类型（材料调拨，调拨归还，材料代用）',
  `out_factory_id` int DEFAULT NULL COMMENT '调出工厂id',
  `out_factory_name` varchar(500) DEFAULT NULL COMMENT '调出工厂名称',
  `out_warehouse_code` varchar(80) DEFAULT NULL COMMENT '调出仓库编号',
  `out_warehouse_name` varchar(80) NOT NULL COMMENT '调出仓库名称',
  `out_location_code` varchar(80) NOT NULL COMMENT '调出储位编号',
  `out_location_name` varchar(80) NOT NULL COMMENT '调出储位名称',
  `out_customer_seq` int DEFAULT NULL COMMENT '调出客户编码',
  `out_customer_name` varchar(80) DEFAULT NULL COMMENT '调出客户名称',
  `out_row_no` varchar(100) DEFAULT NULL COMMENT '调出po',
  `out_product_code` varchar(500) DEFAULT NULL COMMENT '调出的生产订单号',
  `out_manual_prod_code` text COMMENT '调出指令号',
  `out_sku` varchar(200) DEFAULT NULL COMMENT '调出sku',
  `in_factory_id` int DEFAULT NULL COMMENT '调入工厂id',
  `in_factory_name` varchar(500) DEFAULT NULL COMMENT '调入工厂名称',
  `in_warehouse_code` varchar(80) NOT NULL COMMENT '调入仓库编号',
  `in_warehouse_name` varchar(80) NOT NULL COMMENT '调入仓库名称',
  `in_location_code` varchar(80) NOT NULL COMMENT '调入储位编号',
  `in_location_name` varchar(80) NOT NULL COMMENT '调入储位名称',
  `in_customer_seq` int DEFAULT NULL COMMENT '调入客户编码',
  `in_customer_name` varchar(80) DEFAULT NULL COMMENT '调入客户名称',
  `in_row_no` varchar(100) DEFAULT NULL COMMENT '调入po',
  `in_product_code` varchar(500) DEFAULT NULL COMMENT '调入的生产订单号',
  `in_manual_prod_code` text COMMENT '调入指令号',
  `in_sku` varchar(200) DEFAULT NULL COMMENT '调入sku',
  `in_location` varchar(200) DEFAULT NULL COMMENT '调入地点',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `status` int DEFAULT '0' COMMENT '状态(0暂存 1提交)',
  `transfer_at` timestamp NULL DEFAULT NULL COMMENT '调拨日期',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除:0-否,1-是',
  `created_by_name` varchar(200) DEFAULT NULL COMMENT '创建人',
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `submit_at` timestamp NULL DEFAULT NULL COMMENT '提交时间',
  `is_return` int DEFAULT '0' COMMENT '是否归还',
  `updated_by` varchar(50) DEFAULT NULL COMMENT '修改人',
  `updated_by_name` varchar(200) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(50) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `print_count` int DEFAULT '0' COMMENT '打印次数',
  `substitute_material_info_code` varchar(255) DEFAULT NULL COMMENT '代用物料编码',
  `substitute_material_info_seq` int DEFAULT NULL COMMENT '代用物料编码seq',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `transfer_type` (`transfer_type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='库存调拨表';


--
-- Table structure for table `store_transfer_info`
--

DROP TABLE IF EXISTS `store_transfer_info`;


CREATE TABLE `store_transfer_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `transfer_seq` int DEFAULT NULL COMMENT '调拨主表seq',
  `out_store_id` varchar(50) DEFAULT NULL COMMENT '调出的库存ID',
  `in_store_id` varchar(50) DEFAULT NULL COMMENT '调入的库存ID',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码ID',
  `material_info_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_name` varchar(255) DEFAULT NULL COMMENT '物料名称',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `color_code` varchar(255) DEFAULT NULL COMMENT '颜色编码',
  `unit_seq` int DEFAULT NULL COMMENT '单位seq',
  `unit_name` varchar(255) DEFAULT NULL COMMENT '单位名称',
  `size_name` varchar(255) DEFAULT NULL COMMENT '尺码名称',
  `size_code` varchar(255) DEFAULT NULL COMMENT '尺码编码',
  `supply_seq` int NOT NULL COMMENT '供应商Id',
  `supply_name` varchar(255) NOT NULL COMMENT '供应商名称',
  `transfer_total_qty` decimal(18,2) DEFAULT NULL COMMENT '调拨库存数量',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `out_store_qty` decimal(18,2) DEFAULT NULL COMMENT '来源指令库存数量',
  `in_store_plan_qty` decimal(18,2) DEFAULT NULL COMMENT '目标指令计划数',
  `in_store_qty` decimal(18,2) DEFAULT NULL COMMENT '目标指令库存数量',
  `in_net_demand_qty` decimal(18,2) DEFAULT NULL COMMENT '目标指令净需求数',
  `type_seq` int DEFAULT NULL COMMENT '物料类型',
  `type_name` varchar(255) DEFAULT NULL COMMENT '物料类型',
  `class_seq` int DEFAULT NULL COMMENT '物料类别',
  `class_name` varchar(255) DEFAULT NULL COMMENT '物料类别',
  `group_seq` int DEFAULT NULL COMMENT '物料分组',
  `group_name` varchar(255) DEFAULT NULL COMMENT '物料分组',
  `is_return` int DEFAULT '0' COMMENT '是否归还',
  `return_info_seq` int DEFAULT NULL COMMENT '归还对应的明细id',
  `return_info_code` varchar(50) DEFAULT NULL COMMENT '调拨单号',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `transfer_seq` (`transfer_seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='调拨明细表';


--
-- Table structure for table `store_zhx`
--

DROP TABLE IF EXISTS `store_zhx`;


CREATE TABLE `store_zhx` (
  `id` varchar(36) NOT NULL,
  `material_seq` int NOT NULL COMMENT '物料编码ID',
  `material_code` varchar(255) NOT NULL COMMENT '物料编码',
  `material_category_code` varchar(255) NOT NULL COMMENT '物料简码',
  `material_name` varchar(255) NOT NULL COMMENT '物料名称',
  `size` varchar(500) DEFAULT NULL COMMENT 'size',
  `color_name` varchar(500) DEFAULT NULL COMMENT '颜色名称',
  `manual_prod_code` text COMMENT '手工排产单号',
  `product_code` varchar(80) NOT NULL DEFAULT '0000000000' COMMENT '生产订单号''0000000000''虚拟号',
  `customer_seq` int NOT NULL COMMENT '客户编码',
  `customer_name` varchar(80) NOT NULL DEFAULT 'KH000000000000' COMMENT '客户名称''KH000000000000''虚拟客户',
  `supply_seq` int NOT NULL COMMENT '供应商Id',
  `supply_name` varchar(255) NOT NULL COMMENT '供应商名称',
  `warehouse_code` varchar(80) NOT NULL COMMENT '仓库编号',
  `warehouse_name` varchar(80) NOT NULL COMMENT '仓库名称',
  `location_code` varchar(80) NOT NULL COMMENT '储位编号',
  `location_name` varchar(80) NOT NULL COMMENT '储位名称',
  `on_hand_qty` decimal(18,2) unsigned DEFAULT NULL COMMENT '仓库库数量(在库)',
  `on_order_qty` decimal(18,2) DEFAULT NULL COMMENT '在途数量',
  `total_qty` decimal(18,2) DEFAULT NULL COMMENT '总库存数量',
  `row_no` varchar(100) DEFAULT NULL COMMENT 'PO号，也是订单标识号=行号和生产指令号一一对应',
  `sku` varchar(500) DEFAULT NULL COMMENT 'SKU',
  `position_seq` int DEFAULT NULL COMMENT '部位seq',
  `position_code` varchar(500) DEFAULT NULL COMMENT '部位code',
  `position_name` varchar(500) DEFAULT NULL COMMENT '部位名称',
  `factory_id` int DEFAULT NULL COMMENT '所属工厂id',
  `factory_name` varchar(500) DEFAULT NULL COMMENT '所属工厂名称',
  `enable` char(1) DEFAULT '1' COMMENT '是否可用',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除（0正常，1删除）',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_by_name` varchar(100) DEFAULT NULL COMMENT '创建人姓名',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '变更人',
  `updated_at` datetime DEFAULT NULL COMMENT '变更时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `remark1` varchar(255) DEFAULT NULL COMMENT '备用字段',
  `remark2` varchar(255) DEFAULT NULL COMMENT '备用字段',
  PRIMARY KEY (`id`),
  UNIQUE KEY `storeIdx` (`material_seq`,`material_code`,`material_category_code`,`product_code`,`customer_seq`,`supply_seq`,`warehouse_code`,`location_code`,`position_seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `storehouse`
--

DROP TABLE IF EXISTS `storehouse`;


CREATE TABLE `storehouse` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL COMMENT '代号',
  `name` varchar(255) DEFAULT NULL COMMENT '简称',
  `full_name` varchar(255) DEFAULT NULL COMMENT '全称',
  `place` varchar(255) DEFAULT NULL COMMENT '储存位置',
  `create_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `create_date` date DEFAULT NULL COMMENT '创建时间',
  `space` varchar(255) DEFAULT NULL COMMENT '总容量',
  `free_space` varchar(255) DEFAULT NULL COMMENT '剩余容量',
  `update_date` date DEFAULT NULL COMMENT '修改时间',
  `update_by` varchar(22) DEFAULT NULL,
  `is_delete` int DEFAULT '0',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='仓库表';


--
-- Table structure for table `sys_dict`
--

DROP TABLE IF EXISTS `sys_dict`;


CREATE TABLE `sys_dict` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '字典seq',
  `type` char(2) DEFAULT NULL COMMENT '10：常用类别\r\n20：部件\r\n30：size类别',
  `parent_seq` int DEFAULT NULL COMMENT '父级seq\r\n(\r\n当层级=0时，值为null；\r\n当层级>1时，为所属字典seq\r\n)',
  `id` varchar(11) NOT NULL COMMENT '过滤值',
  `code` varchar(200) NOT NULL COMMENT '抬头编码',
  `no` int NOT NULL COMMENT '排序',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_audit` char(1) DEFAULT '0' COMMENT '是否审核',
  `created_by` varchar(255) NOT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `code_name` (`code`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='字典表';


--
-- Table structure for table `sys_dict_item`
--

DROP TABLE IF EXISTS `sys_dict_item`;


CREATE TABLE `sys_dict_item` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '字典seq',
  `sys_dict_seq` int DEFAULT NULL COMMENT '字典表序号\r\n',
  `id` varchar(24) NOT NULL COMMENT '过滤值',
  `code` varchar(200) NOT NULL COMMENT '抬头编码',
  `no` int NOT NULL COMMENT '排序',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_audit` char(1) DEFAULT '0' COMMENT '是否审核',
  `created_by` varchar(255) NOT NULL COMMENT '创建人',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `is_deleted` char(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `index_name` (`sys_dict_seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='字典详情表';


--
-- Table structure for table `sys_dict_item_properties`
--

DROP TABLE IF EXISTS `sys_dict_item_properties`;


CREATE TABLE `sys_dict_item_properties` (
  `seq` int(11) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `sys_dict_item_seq` int DEFAULT NULL COMMENT '字典详情表序号',
  `key` varchar(255) DEFAULT NULL COMMENT '字典详情拓展key',
  `name` varchar(255) DEFAULT NULL COMMENT '字典拓展信息名称',
  `value` varchar(255) DEFAULT NULL COMMENT '字典详情拓展value',
  `order_number` int DEFAULT NULL COMMENT '拓展信息序号',
  `is_select` char(1) DEFAULT '1' COMMENT '是否查询',
  `select_code` varchar(255) DEFAULT NULL COMMENT '查询参数',
  `select_url` varchar(255) DEFAULT NULL COMMENT '查询路径',
  `is_deleted` char(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='字典详情拓展表';


--
-- Table structure for table `sys_process`
--

DROP TABLE IF EXISTS `sys_process`;


CREATE TABLE `sys_process` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `type` varchar(255) DEFAULT NULL COMMENT '类型',
  `code` varchar(255) DEFAULT NULL COMMENT '代号',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  `action` varchar(255) DEFAULT NULL COMMENT '动作',
  `duration` varchar(255) DEFAULT NULL COMMENT '时长（天）',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `is_deleted` char(1) DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='加工信息';


--
-- Table structure for table `sys_syncnew`
--

DROP TABLE IF EXISTS `sys_syncnew`;


CREATE TABLE `sys_syncnew` (
  `RESULT` blob COMMENT 'result',
  `create` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `memo` varchar(20) DEFAULT NULL,
  `request` blob
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='HR同步金蝶记录表';


--
-- Table structure for table `sys_user_copy1`
--

DROP TABLE IF EXISTS `sys_user_copy1`;


CREATE TABLE `sys_user_copy1` (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(20) DEFAULT '' COMMENT '手机号码',
  `sex` char(1) DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) DEFAULT '' COMMENT '密码',
  `status` char(1) DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime DEFAULT NULL COMMENT '最后登录时间',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE KEY `user_name` (`user_name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=32769 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='用户信息表';


--
-- Table structure for table `sz_dwfl_tmp0966571cbf87b7cfb`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp0966571cbf87b7cfb`;


CREATE TABLE `sz_dwfl_tmp0966571cbf87b7cfb` (
  `record_date` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PO` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produce_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firm_id` bigint DEFAULT NULL,
  `firm_name` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `section_name` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEQUENCE` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NODE` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `order_year` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEASON` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `size_name` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `in_stock_num` decimal(13,2) DEFAULT NULL,
  `out_stock_num` decimal(13,2) DEFAULT NULL,
  `stock_num` decimal(13,2) DEFAULT NULL,
  `p_id` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp11a1001677bf6f307`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp11a1001677bf6f307`;


CREATE TABLE `sz_dwfl_tmp11a1001677bf6f307` (
  `MAC_ID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_NAME` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_DATE` datetime(3) DEFAULT NULL,
  `MAC_PROC` varchar(14) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_TYPE` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp13b42711ce31ff323`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp13b42711ce31ff323`;


CREATE TABLE `sz_dwfl_tmp13b42711ce31ff323` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp15416e03ed86f81ef`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp15416e03ed86f81ef`;


CREATE TABLE `sz_dwfl_tmp15416e03ed86f81ef` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp1cf14ceac92eeccf8`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp1cf14ceac92eeccf8`;


CREATE TABLE `sz_dwfl_tmp1cf14ceac92eeccf8` (
  `recordDate` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produceCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firmId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firmName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `process` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sectionName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sequence` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `node` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `orderYear` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `season` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `dispatchGroupCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `dispatchCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sizeName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `disNum` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `reportNum` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp1e7779ff710310db8`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp1e7779ff710310db8`;


CREATE TABLE `sz_dwfl_tmp1e7779ff710310db8` (
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produce_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `section_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEQUENCE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NODE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `p_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp211dd577df7418aa7`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp211dd577df7418aa7`;


CREATE TABLE `sz_dwfl_tmp211dd577df7418aa7` (
  `MAC_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `MAC_NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_DATE` datetime(3) DEFAULT NULL,
  `MAC_CUS` bigint DEFAULT NULL,
  `MAC_TYPE` bigint DEFAULT NULL,
  `MAC_PROC` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`MAC_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp21da85355c7e47b2f`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp21da85355c7e47b2f`;


CREATE TABLE `sz_dwfl_tmp21da85355c7e47b2f` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp28f2eb012c6e64229`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp28f2eb012c6e64229`;


CREATE TABLE `sz_dwfl_tmp28f2eb012c6e64229` (
  `record_date` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produce_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firm_id` decimal(38,0) DEFAULT NULL,
  `firm_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `section_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEQUENCE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NODE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `order_year` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEASON` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `dispatch_group_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `dispatch_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `size_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `dis_num` decimal(13,2) DEFAULT NULL,
  `report_num` decimal(13,2) DEFAULT NULL,
  `p_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp401a67eb7ed86efa3`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp401a67eb7ed86efa3`;


CREATE TABLE `sz_dwfl_tmp401a67eb7ed86efa3` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp4479c669be2defa86`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp4479c669be2defa86`;


CREATE TABLE `sz_dwfl_tmp4479c669be2defa86` (
  `result` varchar(8000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `request` varchar(8000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp5317953ce4038f385`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp5317953ce4038f385`;


CREATE TABLE `sz_dwfl_tmp5317953ce4038f385` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp5a76b9044549b284f`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp5a76b9044549b284f`;


CREATE TABLE `sz_dwfl_tmp5a76b9044549b284f` (
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produce_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `section_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEQUENCE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NODE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `p_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp6e14e0e80ac7957bc`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp6e14e0e80ac7957bc`;


CREATE TABLE `sz_dwfl_tmp6e14e0e80ac7957bc` (
  `result` varchar(8000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `request` varchar(8000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp6f16f32df9b1fd32b`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp6f16f32df9b1fd32b`;


CREATE TABLE `sz_dwfl_tmp6f16f32df9b1fd32b` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp70e983fdb4065f96f`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp70e983fdb4065f96f`;


CREATE TABLE `sz_dwfl_tmp70e983fdb4065f96f` (
  `errorCode` bigint DEFAULT NULL,
  `message` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `status` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp795a478ef5c5033e1`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp795a478ef5c5033e1`;


CREATE TABLE `sz_dwfl_tmp795a478ef5c5033e1` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp79e1a27a467e84e93`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp79e1a27a467e84e93`;


CREATE TABLE `sz_dwfl_tmp79e1a27a467e84e93` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp845bdaaafdaaced6a`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp845bdaaafdaaced6a`;


CREATE TABLE `sz_dwfl_tmp845bdaaafdaaced6a` (
  `recordDate` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `po` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produceCode` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firmId` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firmName` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `process` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sectionName` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sequence` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `node` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `orderYear` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `season` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sizeName` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `inStockNum` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `outStockNum` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `stockNum` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PID` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp8d07326829e0a2114`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp8d07326829e0a2114`;


CREATE TABLE `sz_dwfl_tmp8d07326829e0a2114` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp8f25492aea343b18a`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp8f25492aea343b18a`;


CREATE TABLE `sz_dwfl_tmp8f25492aea343b18a` (
  `record_date` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firm_id` decimal(30,0) DEFAULT NULL,
  `firm_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `department_id` decimal(30,0) DEFAULT NULL,
  `department_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `group_id` decimal(30,0) DEFAULT NULL,
  `group_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `check_num` decimal(13,2) DEFAULT NULL,
  `p_id` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmp91179764c9c06cc2e`
--

DROP TABLE IF EXISTS `sz_dwfl_tmp91179764c9c06cc2e`;


CREATE TABLE `sz_dwfl_tmp91179764c9c06cc2e` (
  `record_date` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PO` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produce_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firm_id` bigint DEFAULT NULL,
  `firm_name` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `section_name` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEQUENCE` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NODE` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `order_year` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEASON` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `size_name` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `in_stock_num` decimal(13,2) DEFAULT NULL,
  `out_stock_num` decimal(13,2) DEFAULT NULL,
  `stock_num` decimal(13,2) DEFAULT NULL,
  `p_id` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpa1127d4a0134b1e3c`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpa1127d4a0134b1e3c`;


CREATE TABLE `sz_dwfl_tmpa1127d4a0134b1e3c` (
  `record_date` datetime(3) DEFAULT NULL,
  `PO` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produce_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firm_id` decimal(38,0) DEFAULT NULL,
  `firm_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `section_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEQUENCE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NODE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `order_year` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEASON` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `size_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `in_stock_num` decimal(13,2) DEFAULT NULL,
  `out_stock_num` decimal(13,2) DEFAULT NULL,
  `stock_num` decimal(13,2) DEFAULT NULL,
  `p_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpa205481667b1db7d3`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpa205481667b1db7d3`;


CREATE TABLE `sz_dwfl_tmpa205481667b1db7d3` (
  `record_date` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firm_id` decimal(30,0) DEFAULT NULL,
  `firm_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `department_id` decimal(30,0) DEFAULT NULL,
  `department_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `group_id` decimal(30,0) DEFAULT NULL,
  `group_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `check_num` decimal(13,2) DEFAULT NULL,
  `p_id` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpa481d85fcd31dfc6d`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpa481d85fcd31dfc6d`;


CREATE TABLE `sz_dwfl_tmpa481d85fcd31dfc6d` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpa4ee06d15d1069f89`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpa4ee06d15d1069f89`;


CREATE TABLE `sz_dwfl_tmpa4ee06d15d1069f89` (
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produce_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `section_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEQUENCE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NODE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `p_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpb03268c1d00b26ad2`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpb03268c1d00b26ad2`;


CREATE TABLE `sz_dwfl_tmpb03268c1d00b26ad2` (
  `recordDate` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firmId` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firmName` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `departmentId` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `departmentName` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `groupId` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `groupName` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `process` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `checkNum` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PID` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpb1d4746be6d3734d2`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpb1d4746be6d3734d2`;


CREATE TABLE `sz_dwfl_tmpb1d4746be6d3734d2` (
  `firmId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firmName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sizeName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `outCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `outDate` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `outNum` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `cjName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `cjTime` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpbcd0ceed2bf4cf463`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpbcd0ceed2bf4cf463`;


CREATE TABLE `sz_dwfl_tmpbcd0ceed2bf4cf463` (
  `MAC_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_DATE` datetime(3) DEFAULT NULL,
  `MAC_PROC` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_TYPE` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpbd78267a29d6e6ef6`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpbd78267a29d6e6ef6`;


CREATE TABLE `sz_dwfl_tmpbd78267a29d6e6ef6` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpbe69d1526cfabec17`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpbe69d1526cfabec17`;


CREATE TABLE `sz_dwfl_tmpbe69d1526cfabec17` (
  `record_date` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produce_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firm_id` decimal(38,0) DEFAULT NULL,
  `firm_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `section_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEQUENCE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `NODE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `order_year` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `SEASON` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `dispatch_group_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `dispatch_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `size_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `dis_num` decimal(13,2) DEFAULT NULL,
  `report_num` decimal(13,2) DEFAULT NULL,
  `p_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpd39dc74b002549554`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpd39dc74b002549554`;


CREATE TABLE `sz_dwfl_tmpd39dc74b002549554` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpdcb060e08cf1f09ab`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpdcb060e08cf1f09ab`;


CREATE TABLE `sz_dwfl_tmpdcb060e08cf1f09ab` (
  `ID` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_ID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `MAC_NAME` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_DATE` datetime(3) DEFAULT NULL,
  `MAC_PROC` varchar(14) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`MAC_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpe65c15f40b76366f8`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpe65c15f40b76366f8`;


CREATE TABLE `sz_dwfl_tmpe65c15f40b76366f8` (
  `MAC_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `WORK_TIME` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PAUSE_TIME` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `WORK_START` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `WORK_END` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME` datetime(3) DEFAULT NULL,
  `ID` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `UPDATE_TIME` date DEFAULT NULL,
  PRIMARY KEY (`MAC_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpec3495a7caa583466`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpec3495a7caa583466`;


CREATE TABLE `sz_dwfl_tmpec3495a7caa583466` (
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `produceCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `process` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sectionName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sequence` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `node` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `PID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpf0bb52bc8d99b88f6`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpf0bb52bc8d99b88f6`;


CREATE TABLE `sz_dwfl_tmpf0bb52bc8d99b88f6` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpf0c88c265c4d75a9c`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpf0c88c265c4d75a9c`;


CREATE TABLE `sz_dwfl_tmpf0c88c265c4d75a9c` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpf51053d88c586cb75`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpf51053d88c586cb75`;


CREATE TABLE `sz_dwfl_tmpf51053d88c586cb75` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpf8f37e5e435dae998`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpf8f37e5e435dae998`;


CREATE TABLE `sz_dwfl_tmpf8f37e5e435dae998` (
  `firmId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `firmName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `sizeName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `outCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `outDate` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `outNum` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `cjName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `cjTime` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpf97d64cba8768f277`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpf97d64cba8768f277`;


CREATE TABLE `sz_dwfl_tmpf97d64cba8768f277` (
  `result` longtext,
  `request` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_dwfl_tmpfb1022b0fe84e23c7`
--

DROP TABLE IF EXISTS `sz_dwfl_tmpfb1022b0fe84e23c7`;


CREATE TABLE `sz_dwfl_tmpfb1022b0fe84e23c7` (
  `ID` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_ID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `MAC_NAME` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_DATE` datetime(3) DEFAULT NULL,
  `MAC_PROC` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`MAC_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_akxqs959`
--

DROP TABLE IF EXISTS `sz_t_akxqs959`;


CREATE TABLE `sz_t_akxqs959` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `The_name_of_the_task` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '任务名称',
  `Estimated_score` bigint DEFAULT NULL COMMENT '预估分值',
  `Responsible_person` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '责任人',
  `Planning_begins` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '计划用时',
  `The_program_ends` date DEFAULT NULL COMMENT '计划结束',
  `Actually_over` date DEFAULT NULL COMMENT '实际结束',
  `Take_home_scores` bigint DEFAULT NULL COMMENT '实得分数',
  `bug` bigint DEFAULT NULL COMMENT 'BUG数',
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '备注',
  `Creation_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `Created_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `Modify_time` datetime(3) DEFAULT NULL COMMENT '修改时间',
  `Modified_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '修改人',
  `Completion_of_the_plan` decimal(10,2) DEFAULT NULL COMMENT '计划完成度',
  `Actually_get_started` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '实际用时',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_apnxs209`
--

DROP TABLE IF EXISTS `sz_t_apnxs209`;


CREATE TABLE `sz_t_apnxs209` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `week` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `module` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `task_content` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `detailed_work` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `plan_the_start_time` date DEFAULT NULL,
  `planned_completion_time` date DEFAULT NULL,
  `actual_completion_time` date DEFAULT NULL,
  `developer` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `completion_status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_eykeq956`
--

DROP TABLE IF EXISTS `sz_t_eykeq956`;


CREATE TABLE `sz_t_eykeq956` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `week` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `module` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `task_content` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `detailed_work` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `plan_the_start_time` date DEFAULT NULL,
  `planned_completion_time` date DEFAULT NULL,
  `actual_completion_time` date DEFAULT NULL,
  `developer` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `completion_status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_gmgop437`
--

DROP TABLE IF EXISTS `sz_t_gmgop437`;


CREATE TABLE `sz_t_gmgop437` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `week` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `module` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `task_content` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `detailed_work` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `plan_the_start_time` date DEFAULT NULL,
  `planned_completion_time` date DEFAULT NULL,
  `actual_completion_time` date DEFAULT NULL,
  `developer` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `completion_status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_gtybt715`
--

DROP TABLE IF EXISTS `sz_t_gtybt715`;


CREATE TABLE `sz_t_gtybt715` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `The_name_of_the_task` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '任务名称',
  `Estimated_score` bigint DEFAULT NULL COMMENT '预估分值',
  `Responsible_person` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '责任人',
  `Planning_begins` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '计划开始',
  `The_program_ends` date DEFAULT NULL COMMENT '计划结束',
  `Completion_of_the_plan` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '计划完成度',
  `Actually_get_started` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '实际开始',
  `Actually_over` date DEFAULT NULL COMMENT '实际结束',
  `Take_home_scores` bigint DEFAULT NULL COMMENT '实得分数',
  `bug` bigint DEFAULT NULL COMMENT 'BUG数',
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '备注',
  `Creation_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `Created_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `Modify_time` datetime(3) DEFAULT NULL COMMENT '修改时间',
  `Modified_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_jhulz042`
--

DROP TABLE IF EXISTS `sz_t_jhulz042`;


CREATE TABLE `sz_t_jhulz042` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `week` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `module` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `task_content` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `detailed_work` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `plan_the_start_time` date DEFAULT NULL,
  `planned_completion_time` date DEFAULT NULL,
  `actual_completion_time` date DEFAULT NULL,
  `developer` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `completion_status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_jmdod469`
--

DROP TABLE IF EXISTS `sz_t_jmdod469`;


CREATE TABLE `sz_t_jmdod469` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `The_name_of_the_task` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '任务名称',
  `Estimated_score` bigint DEFAULT NULL COMMENT '预估分值',
  `Responsible_person` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '责任人',
  `Planning_begins` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '计划开始',
  `The_program_ends` date DEFAULT NULL COMMENT '计划结束',
  `Completion_of_the_plan` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '计划完成度',
  `Actually_get_started` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '实际开始',
  `Actually_over` date DEFAULT NULL COMMENT '实际结束',
  `Take_home_scores` bigint DEFAULT NULL COMMENT '实得分数',
  `bug` bigint DEFAULT NULL COMMENT 'BUG数',
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '备注',
  `Creation_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `Created_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `Modify_time` datetime(3) DEFAULT NULL COMMENT '修改时间',
  `Modified_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_lxgub503`
--

DROP TABLE IF EXISTS `sz_t_lxgub503`;


CREATE TABLE `sz_t_lxgub503` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `The_name_of_the_task` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '任务名称',
  `Estimated_score` bigint DEFAULT NULL COMMENT '预估分值',
  `Responsible_person` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '责任人',
  `Planning_begins` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '计划用时',
  `The_program_ends` date DEFAULT NULL COMMENT '计划结束',
  `Actually_over` date DEFAULT NULL COMMENT '实际结束',
  `Take_home_scores` bigint DEFAULT NULL COMMENT '实得分值',
  `bug` bigint DEFAULT NULL COMMENT 'BUG数',
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '备注',
  `Creation_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `Created_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `Modify_time` datetime(3) DEFAULT NULL COMMENT '修改时间',
  `Modified_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '修改人',
  `Completion_of_the_plan` decimal(10,2) DEFAULT NULL COMMENT '计划完成度',
  `Actually_get_started` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '实际用时',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_mbtyq377`
--

DROP TABLE IF EXISTS `sz_t_mbtyq377`;


CREATE TABLE `sz_t_mbtyq377` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `week` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `module` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `task_content` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `detailed_work` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `plan_the_start_time` date DEFAULT NULL,
  `planned_completion_time` date DEFAULT NULL,
  `actual_completion_time` date DEFAULT NULL,
  `developer` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `completion_status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_tnnua176`
--

DROP TABLE IF EXISTS `sz_t_tnnua176`;


CREATE TABLE `sz_t_tnnua176` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `week` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `module` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `task_content` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `detailed_work` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `plan_the_start_time` date DEFAULT NULL,
  `planned_completion_time` date DEFAULT NULL,
  `actual_completion_time` date DEFAULT NULL,
  `developer` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `completion_status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_tupjw155`
--

DROP TABLE IF EXISTS `sz_t_tupjw155`;


CREATE TABLE `sz_t_tupjw155` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `week` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `module` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `task_content` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `detailed_work` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `plan_the_start_time` date DEFAULT NULL,
  `planned_completion_time` date DEFAULT NULL,
  `actual_completion_time` date DEFAULT NULL,
  `developer` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `completion_status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_ynpfc469`
--

DROP TABLE IF EXISTS `sz_t_ynpfc469`;


CREATE TABLE `sz_t_ynpfc469` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `The_name_of_the_task` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '任务名称',
  `Estimated_score` bigint DEFAULT NULL COMMENT '预估分值',
  `Responsible_person` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '责任人',
  `Planning_begins` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '计划用时',
  `The_program_ends` date DEFAULT NULL COMMENT '计划结束',
  `Actually_over` date DEFAULT NULL COMMENT '实际结束',
  `Take_home_scores` bigint DEFAULT NULL COMMENT '实得分值',
  `bug` bigint DEFAULT NULL COMMENT 'BUG数',
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '备注',
  `Creation_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `Created_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `Modify_time` datetime(3) DEFAULT NULL COMMENT '修改时间',
  `Modified_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '修改人',
  `Completion_of_the_plan` decimal(10,2) DEFAULT NULL COMMENT '计划完成度',
  `Actually_get_started` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '实际用时',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `sz_t_yszen323`
--

DROP TABLE IF EXISTS `sz_t_yszen323`;


CREATE TABLE `sz_t_yszen323` (
  `ID` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `The_name_of_the_task` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '任务名称',
  `Estimated_score` bigint DEFAULT NULL COMMENT '预估分值',
  `Responsible_person` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '责任人',
  `Planning_begins` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '计划用时',
  `The_program_ends` date DEFAULT NULL COMMENT '计划结束',
  `Actually_over` date DEFAULT NULL COMMENT '实际结束',
  `Take_home_scores` bigint DEFAULT NULL COMMENT '实得分值',
  `bug` bigint DEFAULT NULL COMMENT 'BUG数',
  `memo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '备注',
  `Creation_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `Created_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `Modify_time` datetime(3) DEFAULT NULL COMMENT '修改时间',
  `Modified_by` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '修改人',
  `Completion_of_the_plan` decimal(10,2) DEFAULT NULL COMMENT '计划完成度',
  `Actually_get_started` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '实际用时',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `t_customer_quotation`
--

DROP TABLE IF EXISTS `t_customer_quotation`;


CREATE TABLE `t_customer_quotation` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `om_article_seq` int DEFAULT NULL COMMENT '型体seq',
  `customer_article_code` varchar(255) NOT NULL COMMENT '客户形体编号',
  `customer_article_name` varchar(255) DEFAULT NULL COMMENT '客户型体名称',
  `estimated_order_number` varchar(255) DEFAULT NULL COMMENT '预估单号',
  `season_number` varchar(255) DEFAULT NULL COMMENT '季节号',
  `estimated_currency` varchar(255) DEFAULT NULL COMMENT '预估币种',
  `estimated_exchange_rate` decimal(4,2) DEFAULT NULL COMMENT '预估汇率',
  `code` varchar(255) DEFAULT NULL COMMENT '编码',
  `order_contract_number` varchar(255) DEFAULT NULL COMMENT '订单合同号',
  `last_number` varchar(255) DEFAULT NULL COMMENT '楦头编号',
  `knife_mold_number` varchar(255) DEFAULT NULL COMMENT '刀模编号',
  `bottom_mold_number` varchar(255) DEFAULT NULL COMMENT '大底模号',
  `customer` varchar(255) DEFAULT NULL COMMENT '客户',
  `foreign_exchange_net_cost` varchar(255) DEFAULT NULL COMMENT '外汇净成本',
  `customer_buyer` varchar(255) DEFAULT NULL COMMENT '客户买主',
  `transaction_terms` varchar(255) DEFAULT NULL COMMENT '交易条件',
  `price_applicable_regions` varchar(255) DEFAULT NULL COMMENT '价格适用区域',
  `quotation_date` datetime DEFAULT NULL COMMENT '报价日期',
  `estimated_cost_price` varchar(255) DEFAULT NULL COMMENT '预估成本价',
  `cost` varchar(255) DEFAULT NULL COMMENT '成本',
  `quotation_cost` varchar(255) DEFAULT NULL COMMENT '报价成本',
  `profit2` varchar(50) DEFAULT NULL COMMENT '利润2',
  `interest_rate` varchar(255) DEFAULT NULL COMMENT '利率',
  `exchange_rate2` decimal(4,2) DEFAULT NULL COMMENT '汇率2',
  `using_currency` varchar(50) DEFAULT NULL COMMENT '币种',
  `drawback` varchar(255) DEFAULT NULL COMMENT '退税',
  `profit` varchar(255) DEFAULT NULL COMMENT '利润',
  `exchange_rate` decimal(4,2) DEFAULT NULL COMMENT '汇率',
  `quotation_cost2` varchar(50) DEFAULT NULL COMMENT '报价成本2',
  `hk_quotation_cost` varchar(50) DEFAULT NULL COMMENT 'HK报价成本',
  `hk_profit` varchar(50) DEFAULT NULL COMMENT 'hk利润',
  `hk_exchange_rate` decimal(4,2) DEFAULT NULL COMMENT 'hk汇率',
  `using_interest_rate` decimal(4,2) DEFAULT NULL COMMENT '使用利率',
  `using_profit` varchar(50) DEFAULT NULL COMMENT '利润',
  `using_exchange_rate` decimal(20,6) DEFAULT NULL COMMENT '汇率',
  `restatement_reason` varchar(255) DEFAULT NULL COMMENT '重报原因',
  `state` int DEFAULT NULL COMMENT '状态',
  `quotation_quantity` int DEFAULT NULL COMMENT '报价数量',
  `version_number` varchar(50) DEFAULT NULL COMMENT '版本号',
  `is_submit` varchar(50) DEFAULT NULL COMMENT '是否提交',
  `submit_date` datetime DEFAULT NULL COMMENT '提交日期',
  `review_status` varchar(50) DEFAULT NULL COMMENT '审核状态',
  `remarks1` varchar(255) DEFAULT NULL COMMENT '备注1',
  `establishment_date` datetime DEFAULT NULL COMMENT '建单日期',
  `modification_date` datetime DEFAULT NULL COMMENT '修改日期',
  `establishmenter` varchar(50) DEFAULT NULL COMMENT '建单人',
  `last_modified_by` varchar(50) DEFAULT NULL COMMENT '最后修改人',
  `om_article_image` varchar(50) DEFAULT NULL COMMENT '型体图片',
  `process_amount` decimal(20,6) DEFAULT NULL COMMENT '工艺金额',
  `management_amount` decimal(20,6) DEFAULT NULL COMMENT '管理金额',
  `other_amount` decimal(20,6) DEFAULT NULL COMMENT '其他金额',
  `material_amount` decimal(20,6) DEFAULT NULL COMMENT '物料金额',
  `is_bulk_price` int DEFAULT NULL COMMENT '是否大货确认价',
  `bulk_price_start_date` datetime DEFAULT NULL COMMENT '大货确认价有效期开始于',
  `bulk_price_end_date` datetime DEFAULT NULL COMMENT '大货确认价有效期结束于',
  `printing_frequency` int DEFAULT NULL COMMENT '打印次数',
  `shoe_shape_attribute` varchar(255) DEFAULT NULL COMMENT '鞋型属性',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='客户报价单';


--
-- Table structure for table `t_developer_management`
--

DROP TABLE IF EXISTS `t_developer_management`;


CREATE TABLE `t_developer_management` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `job_number` varchar(64) DEFAULT NULL COMMENT '工号',
  `name` varchar(255) DEFAULT NULL COMMENT '姓名',
  `working_age` varchar(64) DEFAULT NULL COMMENT '工龄',
  `age` varchar(64) DEFAULT NULL COMMENT '年龄',
  `sex` varchar(64) DEFAULT NULL COMMENT '性别',
  `major` varchar(64) DEFAULT NULL COMMENT '专业',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='开发人员管理';


--
-- Table structure for table `t_estimated_standard_cost`
--

DROP TABLE IF EXISTS `t_estimated_standard_cost`;


CREATE TABLE `t_estimated_standard_cost` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `estimated_order_number` varchar(50) DEFAULT NULL COMMENT '预估单号',
  `monetary_unit` int DEFAULT NULL COMMENT '货币单位',
  `exchange_rate` decimal(4,2) DEFAULT NULL COMMENT '汇率',
  `estimated_quantity` int DEFAULT NULL COMMENT '预估数量',
  `cost_unit_price` int DEFAULT NULL COMMENT '成本单价',
  `cost_frequency` int DEFAULT NULL COMMENT '成本数量',
  `order_contract_number` varchar(50) DEFAULT NULL COMMENT '订单合同号',
  `quotation_season` varchar(50) DEFAULT NULL COMMENT '报价季节',
  `country_code` varchar(50) DEFAULT NULL COMMENT '国家代码',
  `country_name` varchar(50) DEFAULT NULL COMMENT '国家姓名',
  `quotation_stage` varchar(50) DEFAULT NULL COMMENT '报价阶段',
  `estimated_factory` varchar(50) DEFAULT NULL COMMENT '预估工厂',
  `undertake_warehouse` varchar(50) DEFAULT NULL COMMENT '承接仓库',
  `restatement_reason` varchar(50) DEFAULT NULL COMMENT '重报原因',
  `estimated_department` varchar(50) DEFAULT NULL COMMENT '预估部门',
  `estimated_by` varchar(50) DEFAULT NULL COMMENT '预估人',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `estimated_description` text COMMENT '预估说明',
  `om_article_seq` int DEFAULT NULL COMMENT '型体seq',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='预估标准成本';


--
-- Table structure for table `t_ieprocessing_cost`
--

DROP TABLE IF EXISTS `t_ieprocessing_cost`;


CREATE TABLE `t_ieprocessing_cost` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `estimated_standard_cost_seq` int DEFAULT NULL COMMENT '预估成本主表seq',
  `estimated_order_number` varchar(50) DEFAULT NULL COMMENT '预估单号',
  `total_price` int DEFAULT NULL COMMENT '总价',
  `exchange_rate` decimal(4,2) DEFAULT NULL COMMENT '汇率',
  `currency` varchar(50) DEFAULT NULL COMMENT '币种',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='IE加工费用';


--
-- Table structure for table `t_inquiry_annotation_description`
--

DROP TABLE IF EXISTS `t_inquiry_annotation_description`;


CREATE TABLE `t_inquiry_annotation_description` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `inquiry_seq` int DEFAULT NULL COMMENT '询价表主键',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价编码',
  `content` text COMMENT '内容',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='注释说明';


--
-- Table structure for table `t_inquiry_append_condition`
--

DROP TABLE IF EXISTS `t_inquiry_append_condition`;


CREATE TABLE `t_inquiry_append_condition` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `inquiry_seq` int DEFAULT NULL COMMENT '询价表seq',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价编码',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `preconditions` varchar(50) DEFAULT NULL COMMENT '前提条件',
  `formula_content` varchar(50) DEFAULT NULL COMMENT '公式内容',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='询价追加条件';


--
-- Table structure for table `t_inquiry_details`
--

DROP TABLE IF EXISTS `t_inquiry_details`;


CREATE TABLE `t_inquiry_details` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `inquiry_seq` int DEFAULT NULL COMMENT '厂商材料报价单seq',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价编码',
  `inquiry_supplier_seq` int DEFAULT NULL COMMENT '询价供应商seq',
  `material_seq` int DEFAULT NULL COMMENT '物料seq',
  `material_simplified_code` varchar(50) DEFAULT NULL COMMENT '物料简码',
  `material_code` varchar(50) DEFAULT NULL COMMENT '物料编码',
  `material_name` varchar(500) DEFAULT NULL COMMENT '物料名称',
  `colour` varchar(50) DEFAULT NULL COMMENT '颜色',
  `specifications` varchar(50) DEFAULT NULL COMMENT '规格',
  `production_cycle` varchar(50) DEFAULT NULL COMMENT '生产周期',
  `unit` varchar(50) DEFAULT NULL COMMENT '单位',
  `price_batch` varchar(50) DEFAULT NULL COMMENT '价格批次',
  `start_date` datetime DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime DEFAULT NULL COMMENT '结束日期',
  `remarks` varchar(200) DEFAULT NULL COMMENT '备注',
  `initiation_mass` varchar(50) DEFAULT NULL COMMENT '起始量',
  `factory` varchar(50) DEFAULT NULL COMMENT '工厂',
  `price` int DEFAULT NULL COMMENT '报价',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='询价明细';


--
-- Table structure for table `t_inquiry_file`
--

DROP TABLE IF EXISTS `t_inquiry_file`;


CREATE TABLE `t_inquiry_file` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `inquiry_seq` int DEFAULT NULL COMMENT '询价表主键',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价编码',
  `file_name` varchar(50) DEFAULT NULL COMMENT '文件名',
  `file_size` varchar(50) DEFAULT NULL COMMENT '文件大小',
  `file_type` varchar(50) DEFAULT NULL COMMENT '文件类型',
  `file_path` varchar(100) DEFAULT NULL COMMENT '文件路径',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='附件';


--
-- Table structure for table `t_inquiry_staircase`
--

DROP TABLE IF EXISTS `t_inquiry_staircase`;


CREATE TABLE `t_inquiry_staircase` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键seq',
  `details_seq` int DEFAULT NULL COMMENT '明细表seq',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价编码',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '供应商编码',
  `supplier_name` varchar(50) DEFAULT NULL COMMENT '供应商名称',
  `unit` varchar(50) DEFAULT NULL COMMENT '单位',
  `minimum_order_quantity` int DEFAULT NULL COMMENT '最小起订量',
  `maximum_order_quantity` int DEFAULT NULL COMMENT '最大起订量',
  `price` int DEFAULT NULL COMMENT '报价',
  `start_date` datetime DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime DEFAULT NULL COMMENT '结束日期',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='报价阶梯';


--
-- Table structure for table `t_inquiry_supplier`
--

DROP TABLE IF EXISTS `t_inquiry_supplier`;


CREATE TABLE `t_inquiry_supplier` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `inquiry_seq` int DEFAULT NULL COMMENT '厂商材料报价单seq',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价编码',
  `supplier_code` varchar(50) DEFAULT NULL COMMENT '供应商编码',
  `supplier_name` varchar(50) DEFAULT NULL COMMENT '供应商名称',
  `is_deactivate` varchar(50) DEFAULT NULL COMMENT '停用',
  `minimum_purchase_quantity` varchar(50) DEFAULT NULL COMMENT '最小采购量',
  `minimum_pack_quantity` varchar(50) DEFAULT NULL COMMENT '最小包装量',
  `purchasing_unit` varchar(50) DEFAULT NULL COMMENT '采购单位',
  `payment_method` varchar(50) DEFAULT NULL COMMENT '付款方式',
  `output_lt` varchar(50) DEFAULT NULL COMMENT '量产LT',
  `insufficient_explanation` varchar(50) DEFAULT NULL COMMENT '起定不足说明',
  `sufficient_explanation` varchar(50) DEFAULT NULL COMMENT '起定足够说明',
  `production_method` varchar(50) DEFAULT NULL COMMENT '生产方式',
  `grey_fabric_form` varchar(50) DEFAULT NULL COMMENT '坯布形式',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `add_remarks` varchar(50) DEFAULT NULL COMMENT '追加备注',
  `is_branch_factory_inquiry` varchar(50) DEFAULT NULL COMMENT '是否分厂询价',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='询价供应商';


--
-- Table structure for table `t_manufacturer_material_inquiry`
--

DROP TABLE IF EXISTS `t_manufacturer_material_inquiry`;


CREATE TABLE `t_manufacturer_material_inquiry` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `inquiry_code` varchar(50) DEFAULT NULL COMMENT '询价编码',
  `currency` varchar(50) DEFAULT NULL COMMENT '货币单位',
  `quarter` varchar(50) DEFAULT NULL COMMENT '鞋型季度',
  `inquiry_department` varchar(50) DEFAULT NULL COMMENT '询价部门',
  `inquirer` varchar(50) DEFAULT NULL COMMENT '询价人',
  `purchasing_unit_price` varchar(50) DEFAULT NULL COMMENT '采购单位单价',
  `customer_inquiry` varchar(50) DEFAULT NULL COMMENT '客户询价',
  `price_batch` varchar(50) DEFAULT NULL COMMENT '价格批次',
  `start_date` datetime DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime DEFAULT NULL COMMENT '结束日期',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='厂商材料报价单';


--
-- Table structure for table `t_material_colour`
--

DROP TABLE IF EXISTS `t_material_colour`;


CREATE TABLE `t_material_colour` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `material_seq` int DEFAULT NULL COMMENT '物料主表Seq',
  `pandong` varchar(50) DEFAULT NULL COMMENT '潘东号(颜色的国际编号)',
  `colour_zh` int DEFAULT NULL COMMENT '颜色中文',
  `colour_en` int DEFAULT NULL COMMENT '颜色英文',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `create_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `update_time` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='物料颜色表';


--
-- Table structure for table `t_material_cost`
--

DROP TABLE IF EXISTS `t_material_cost`;


CREATE TABLE `t_material_cost` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键seq',
  `estimated_standard_cost_seq` int DEFAULT NULL COMMENT '预估成本主表seq',
  `estimated_order_number` varchar(50) DEFAULT NULL COMMENT '预估单号',
  `material_seq` int DEFAULT NULL COMMENT '物料主键seq',
  `position_seq` int DEFAULT NULL COMMENT '物料部位seq',
  `estimated_unit_price` decimal(20,2) DEFAULT NULL COMMENT '预估单价',
  `estimated_unit_consumption` decimal(20,2) DEFAULT NULL COMMENT '预估单耗',
  `estimated_loss` decimal(20,2) DEFAULT NULL COMMENT '预估损耗(%)',
  `estimated_amount` decimal(20,2) DEFAULT NULL COMMENT '预估金额',
  `system_estimated_amount` decimal(20,2) DEFAULT NULL COMMENT '系统预估金额',
  `process_unit_price` decimal(20,2) DEFAULT NULL COMMENT '工艺单价',
  `process_printing` int DEFAULT NULL COMMENT '工艺打印',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='物料费用';


--
-- Table structure for table `t_material_ledger`
--

DROP TABLE IF EXISTS `t_material_ledger`;


CREATE TABLE `t_material_ledger` (
  `seq` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(255) DEFAULT NULL COMMENT '编码',
  `bre_code` varchar(50) DEFAULT NULL COMMENT '简码',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  `pandong` varchar(50) DEFAULT NULL COMMENT '潘东号(颜色的国际编号)',
  `explain` varchar(50) DEFAULT NULL COMMENT '物料说明',
  `en_explain` varchar(125) DEFAULT NULL COMMENT '物料说明(英)',
  `spec` varchar(125) DEFAULT NULL COMMENT '规格',
  `type` int DEFAULT NULL COMMENT '物料类型',
  `clazz` int DEFAULT NULL COMMENT '分类',
  `quantity` varchar(50) DEFAULT NULL COMMENT '克重/数量',
  `unit` int DEFAULT NULL COMMENT '单位',
  `land` varchar(50) DEFAULT NULL COMMENT '厚度',
  `wide_width` int DEFAULT NULL COMMENT '宽幅',
  `width` varchar(50) DEFAULT NULL COMMENT '宽度',
  `parent_seq` int DEFAULT NULL COMMENT '父级',
  `colour` int DEFAULT NULL COMMENT '颜色',
  `danger_classes` varchar(255) DEFAULT NULL COMMENT '危险等级',
  `is_size` char(1) DEFAULT '0' COMMENT '是否码号管理 0：否',
  `size` varchar(255) DEFAULT NULL COMMENT '码号',
  `con_ratio` double(10,2) DEFAULT NULL COMMENT '转换比率',
  `pro_unit` varchar(255) DEFAULT NULL COMMENT '采购单位',
  `is_enquiry` char(1) DEFAULT NULL COMMENT '是否分厂询价:0-否，1-是',
  `is_combin` char(1) DEFAULT '0' COMMENT '是否组合物料:0-否，1-是',
  `expand` varchar(255) DEFAULT NULL COMMENT '拓展参数',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除者',
  `delete_flag` varchar(64) DEFAULT '0' COMMENT '删除标识(0未删，1已删)',
  `delete_time` datetime DEFAULT NULL COMMENT '删除时间',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_time` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料台账';


--
-- Table structure for table `t_material_ledger_info`
--

DROP TABLE IF EXISTS `t_material_ledger_info`;


CREATE TABLE `t_material_ledger_info` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `ledger_id` int DEFAULT NULL,
  `supplier_seq` int DEFAULT NULL COMMENT '供应商序号',
  `code` varchar(22) DEFAULT NULL COMMENT '物料编码',
  `template` int DEFAULT NULL COMMENT '模板代号',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  `pandong` varchar(255) DEFAULT NULL COMMENT '潘东号（类别值代号）',
  `colour` varchar(255) DEFAULT NULL COMMENT '颜色（类别值代号）',
  `if_usered` varchar(2) DEFAULT '10' COMMENT '使用状态\r\n10:未使用\r\n20:已使用',
  `type` int DEFAULT NULL COMMENT '类别（类别值代号）',
  `clazz` int DEFAULT NULL COMMENT '分类（类别值代号）',
  `form` int DEFAULT NULL COMMENT '型态（类别值代号）',
  `specification` int DEFAULT NULL COMMENT '规格（类别值代号）',
  `quantity` varchar(255) DEFAULT NULL COMMENT '克重/数量',
  `danger_classes` varchar(255) DEFAULT NULL COMMENT '危险等级',
  `if_process` int DEFAULT NULL COMMENT '是否需要加工',
  `effect_at` datetime DEFAULT NULL COMMENT '生效日期',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物料基本信息';


--
-- Table structure for table `t_material_supplier`
--

DROP TABLE IF EXISTS `t_material_supplier`;


CREATE TABLE `t_material_supplier` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `material_seq` int DEFAULT NULL COMMENT '物料台账seq',
  `supplier_seq` int DEFAULT NULL COMMENT '供应商seq',
  `is_default` char(1) DEFAULT '0' COMMENT '是否默认供应商:0-否,1-是',
  `material_code` varchar(125) DEFAULT NULL COMMENT '物料编码',
  `material_name` varchar(125) DEFAULT NULL COMMENT '物料名称',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='物料台账-供应商关联表';


--
-- Table structure for table `t_material_tem`
--

DROP TABLE IF EXISTS `t_material_tem`;


CREATE TABLE `t_material_tem` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `material_seq` int DEFAULT NULL COMMENT '物料id',
  `tem_seq` int DEFAULT NULL COMMENT '临时物料id',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='临时物料-物料关系表';


--
-- Table structure for table `t_mold_cost`
--

DROP TABLE IF EXISTS `t_mold_cost`;


CREATE TABLE `t_mold_cost` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `estimated_standard_cost_seq` int DEFAULT NULL COMMENT '预估成本主表seq',
  `estimated_order_number` varchar(50) DEFAULT NULL COMMENT '预估单号',
  `sequence_number` int DEFAULT NULL COMMENT '顺序号',
  `material_seq` int DEFAULT NULL COMMENT '物料seq',
  `material_name` varchar(50) DEFAULT NULL COMMENT '物料名称',
  `material_code` varchar(50) DEFAULT NULL COMMENT '物料编码',
  `colour` varchar(50) DEFAULT NULL COMMENT '颜色',
  `specifications` varchar(50) DEFAULT NULL COMMENT '规格',
  `supplier` varchar(50) DEFAULT NULL COMMENT '供应商',
  `first_mold_cost` decimal(4,2) DEFAULT NULL COMMENT '第一次模具费用 ',
  `average_cost` decimal(4,2) DEFAULT NULL COMMENT '平均费用',
  `last_mold_cost` decimal(4,2) DEFAULT NULL COMMENT '最后次模具费用',
  `exchange_rate` decimal(4,2) DEFAULT NULL COMMENT '汇率',
  `currency` varchar(50) DEFAULT NULL COMMENT '币种',
  `mold_cost` decimal(4,2) DEFAULT NULL COMMENT '模具费用',
  `unit_price` decimal(4,2) DEFAULT NULL COMMENT '单价',
  `quantity` int DEFAULT NULL COMMENT '数量',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='模具费用';


--
-- Table structure for table `t_om_article_commission`
--

DROP TABLE IF EXISTS `t_om_article_commission`;


CREATE TABLE `t_om_article_commission` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `estimated_standard_cost_seq` int DEFAULT NULL COMMENT '预估成本主表seq',
  `estimated_order_number` varchar(50) DEFAULT NULL COMMENT '预估单号',
  `commission_category` varchar(50) DEFAULT NULL COMMENT '佣金类别',
  `commission_unit_price` int DEFAULT NULL COMMENT '佣金单价',
  `commission_rate` decimal(4,2) DEFAULT NULL COMMENT '佣金比率',
  `commission_company` varchar(50) DEFAULT NULL COMMENT '佣金公司',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='型体佣金';


--
-- Table structure for table `t_other_cost`
--

DROP TABLE IF EXISTS `t_other_cost`;


CREATE TABLE `t_other_cost` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `estimated_standard_cost_seq` int DEFAULT NULL COMMENT '预估成本主表seq',
  `estimated_order_number` varchar(50) DEFAULT NULL COMMENT '预估单号',
  `sequence_number` int DEFAULT NULL COMMENT '顺序号',
  `cost_name` varchar(50) DEFAULT NULL COMMENT '费用名称',
  `quotation_amount` int DEFAULT NULL COMMENT '报价金额',
  `currency` varchar(50) DEFAULT NULL COMMENT '币种',
  `exchange_rate` decimal(20,2) DEFAULT NULL COMMENT '汇率',
  `local_currency_amount` int DEFAULT NULL COMMENT '本币金额',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `version` varchar(50) DEFAULT NULL COMMENT '版本',
  `is_effective` int DEFAULT NULL COMMENT '是否有效(1是0否)',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='其他费用';


--
-- Table structure for table `t_product_stage`
--

DROP TABLE IF EXISTS `t_product_stage`;


CREATE TABLE `t_product_stage` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(50) DEFAULT NULL COMMENT '阶段代号',
  `name` varchar(50) DEFAULT NULL COMMENT '阶段名称',
  `deadline` varchar(50) DEFAULT NULL COMMENT '处理期限',
  `number` varchar(50) DEFAULT NULL COMMENT '排序',
  `product_type` int DEFAULT NULL COMMENT '产品类型',
  `time` int DEFAULT NULL COMMENT '年份(下拉框：在常用类别中查找)',
  `season` int DEFAULT NULL COMMENT '季节(下拉框：在常用类别中查找)',
  `if_delete` char(1) DEFAULT NULL COMMENT '是否删除：0-否；1-是',
  `create_by_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_time_` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `update_by_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_time_` datetime(3) DEFAULT NULL COMMENT '更新时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_time` datetime(3) DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产品阶段设定';


--
-- Table structure for table `t_product_stage_user`
--

DROP TABLE IF EXISTS `t_product_stage_user`;


CREATE TABLE `t_product_stage_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stage_id` bigint DEFAULT NULL COMMENT '产品阶段ID',
  `developer_id` bigint DEFAULT NULL COMMENT '开发人员id',
  `developer_name` varchar(125) DEFAULT NULL COMMENT '开发人员名称',
  `create_by_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_time_` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `update_by_` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_time_` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产品阶段设定处理人';


--
-- Table structure for table `t_progress_feedback`
--

DROP TABLE IF EXISTS `t_progress_feedback`;


CREATE TABLE `t_progress_feedback` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `sample_order_code` varchar(255) DEFAULT NULL COMMENT '样品单号',
  `process_number` varchar(255) DEFAULT NULL COMMENT '工序编号',
  `process_name` varchar(255) DEFAULT NULL COMMENT '工序名称',
  `developers` varchar(255) DEFAULT NULL COMMENT '开发人员',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `completion_time` datetime DEFAULT NULL COMMENT '完成时间',
  `estimated_completion_time` datetime DEFAULT NULL COMMENT '预计完成时间',
  `time_consuming` varchar(50) DEFAULT NULL COMMENT '耗时',
  `abnormal` varchar(50) DEFAULT NULL COMMENT '是否异常',
  `remarks` varchar(50) DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品进度回馈';


--
-- Table structure for table `t_sample_process`
--

DROP TABLE IF EXISTS `t_sample_process`;


CREATE TABLE `t_sample_process` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `process_name` varchar(255) DEFAULT NULL COMMENT '工序名称',
  `process_code` varchar(50) DEFAULT NULL COMMENT '工序编码',
  `product_type` varchar(50) DEFAULT NULL COMMENT '产品类型',
  `deadline` varchar(50) DEFAULT NULL COMMENT '处理期限',
  `year` varchar(50) DEFAULT NULL COMMENT '年份',
  `quarter` varchar(50) DEFAULT NULL COMMENT '季度',
  `sort` varchar(50) DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品工序设定';


--
-- Table structure for table `t_sample_process_user`
--

DROP TABLE IF EXISTS `t_sample_process_user`;


CREATE TABLE `t_sample_process_user` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `sample_process_seq` int DEFAULT NULL COMMENT '样品工序ID',
  `developer_seq` int DEFAULT NULL COMMENT '处理人ID',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_date` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='样品工序设定处理人';


--
-- Table structure for table `t_standard_cost_budget`
--

DROP TABLE IF EXISTS `t_standard_cost_budget`;


CREATE TABLE `t_standard_cost_budget` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `art_seq` int DEFAULT NULL COMMENT '产品资料主键',
  `sku` varchar(50) DEFAULT NULL COMMENT 'sku',
  `quotation_number` varchar(50) DEFAULT NULL COMMENT '报价单编号',
  `logo_url` varchar(255) DEFAULT NULL COMMENT '图片地址',
  `code` varchar(30) DEFAULT NULL COMMENT '工厂型体编号',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `customer_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `customer_article_name` varchar(255) DEFAULT NULL COMMENT '客户型体名称',
  `customer_article_code` varchar(255) DEFAULT NULL COMMENT '客户型体编号',
  `product_class_seq` int DEFAULT NULL COMMENT '产品类别seq',
  `product_class_name` varchar(50) DEFAULT NULL COMMENT '产品类别名称',
  `color` int DEFAULT NULL COMMENT '颜色序号',
  `color_name` varchar(255) DEFAULT NULL COMMENT '颜色名称',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `sex` int DEFAULT NULL COMMENT '样鞋性别（字典表seq）',
  `sample_stage_seq` varchar(255) DEFAULT NULL COMMENT '样品阶段id',
  `sample_stage_name` varchar(255) DEFAULT NULL COMMENT '样品阶段名称',
  `quotation_size_code` varchar(255) DEFAULT NULL COMMENT '报价码',
  `transaction_price` decimal(10,2) DEFAULT NULL,
  `tag_price` decimal(10,2) DEFAULT NULL COMMENT '吊牌价',
  `product_unit_price` decimal(10,2) DEFAULT NULL COMMENT '产品单价',
  `profit_margin` decimal(10,2) DEFAULT NULL COMMENT '利润率',
  `target_unit_price` decimal(10,2) DEFAULT NULL COMMENT '目标单价',
  `net_usage` decimal(10,2) DEFAULT NULL,
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价格',
  `total_price_materials` decimal(10,2) DEFAULT NULL COMMENT '材料总价',
  `cost_rate` decimal(10,2) DEFAULT NULL COMMENT '成本率',
  `differential_price` decimal(10,2) DEFAULT NULL COMMENT '差异价',
  `currency` varchar(50) DEFAULT NULL COMMENT '币种',
  `exchange_rate` decimal(10,2) DEFAULT NULL COMMENT '汇率',
  `quotation_size_code_start` decimal(5,2) DEFAULT NULL COMMENT '报价尺码范围开始',
  `quotation_size_code_end` decimal(5,2) DEFAULT NULL COMMENT '报价尺码范围结束',
  `status` int DEFAULT NULL COMMENT '状态',
  `created_by` varchar(255) DEFAULT NULL COMMENT '创建人',
  `is_deleted` int DEFAULT '0' COMMENT '是否删除',
  `is_not_need_quotation` int DEFAULT '0' COMMENT '是否需要报价码',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(255) DEFAULT NULL COMMENT '修改人',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(255) DEFAULT NULL COMMENT '删除人',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间',
  `created_by_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=478 DEFAULT CHARSET=utf8mb3 COMMENT='标准成本预算';


--
-- Table structure for table `t_standard_cost_ie`
--

DROP TABLE IF EXISTS `t_standard_cost_ie`;


CREATE TABLE `t_standard_cost_ie` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `standard_cost_budget_seq` int DEFAULT NULL COMMENT '客户报价主表seq',
  `art_seq` int DEFAULT NULL COMMENT '型体序号',
  `art_position_seq` int DEFAULT NULL COMMENT '型体部位序号',
  `ie_code` varchar(255) DEFAULT NULL COMMENT '工艺编码',
  `ie_name` varchar(500) DEFAULT NULL COMMENT '工艺名称',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `material_category_name` text COMMENT '物料简码名称',
  `provider_seq` int DEFAULT NULL COMMENT '供应商seq',
  `provider_name` varchar(255) DEFAULT NULL COMMENT '供应商名称',
  `unit_price` decimal(14,4) DEFAULT NULL COMMENT '单价',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb3 COMMENT='客户报价工艺信息';


--
-- Table structure for table `t_standard_cost_material_details`
--

DROP TABLE IF EXISTS `t_standard_cost_material_details`;


CREATE TABLE `t_standard_cost_material_details` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `standard_cost_budget_seq` int DEFAULT NULL COMMENT '主表Seq',
  `quotation_supplier_seq` int DEFAULT NULL COMMENT '报价供应商seq',
  `quotation_supplier` varchar(255) DEFAULT NULL COMMENT '报价供应商',
  `material_category_seq` int DEFAULT NULL COMMENT '物料简码序号',
  `material_category_code` varchar(255) DEFAULT NULL COMMENT '物料简码',
  `material_category_name` varchar(255) DEFAULT NULL COMMENT '物料简码名称',
  `material_info_seq` int DEFAULT NULL COMMENT '物料编码seq',
  `material_info_code` varchar(100) DEFAULT NULL COMMENT '物料编码',
  `position_seq` int DEFAULT NULL COMMENT '部件序号',
  `position_code` varchar(255) DEFAULT NULL COMMENT '部位编号',
  `position_name` varchar(255) DEFAULT NULL COMMENT '部位名称',
  `position_type` varchar(255) DEFAULT NULL COMMENT '部位分类(改为物料分组)',
  `material_info_colour` varchar(100) DEFAULT NULL COMMENT '物料编码颜色编码',
  `material_info_colour_name` varchar(100) DEFAULT NULL COMMENT '物料编码颜色名称',
  `position_pieces` decimal(14,2) DEFAULT NULL COMMENT '部位片数',
  `lo_pieces` decimal(14,2) DEFAULT NULL COMMENT 'lo片数',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `net_usage` decimal(14,4) DEFAULT NULL COMMENT '净用量',
  `loss_rate` decimal(14,4) DEFAULT NULL COMMENT '损耗率',
  `wool_usage` decimal(14,4) DEFAULT NULL COMMENT '毛用量',
  `unit_price` decimal(14,4) DEFAULT NULL COMMENT '单价',
  `minimum_purchase_quantity` decimal(14,4) DEFAULT NULL COMMENT '最小采购量',
  `total_price` decimal(14,4) DEFAULT NULL COMMENT '总价',
  `each_expend` decimal(11,4) DEFAULT '1.0000' COMMENT '单耗',
  `unit_seq` int DEFAULT NULL COMMENT '单位id',
  `unit_name` varchar(100) DEFAULT NULL COMMENT '单位名称',
  `material_info_is_out_sourcing` varchar(100) DEFAULT '0' COMMENT '是否组合材料',
  `parent_seq` int DEFAULT NULL COMMENT '组合材料的父类seq',
  `quarter_code` int DEFAULT NULL COMMENT '季度序号',
  `customer_seq` int DEFAULT NULL COMMENT '客户Id',
  `sample_stage_name` varchar(255) DEFAULT NULL COMMENT '样品阶段名称',
  `provider_type_name` varchar(255) DEFAULT NULL,
  `unit_price_type` int DEFAULT '0' COMMENT '单价类型(0未取到单价,1大货价，2样品价，3手工单价)',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=17408 DEFAULT CHARSET=utf8mb3 COMMENT='标准成本预算-材料明细';


--
-- Table structure for table `t_standard_cost_quotation_details`
--

DROP TABLE IF EXISTS `t_standard_cost_quotation_details`;


CREATE TABLE `t_standard_cost_quotation_details` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `standard_cost_budget_seq` int DEFAULT NULL COMMENT '主表Seq',
  `serial_number` int DEFAULT NULL COMMENT '序号',
  `payment` varchar(100) DEFAULT NULL COMMENT '款项',
  `payment_type` int DEFAULT NULL COMMENT '款项类型',
  `is_disable` int DEFAULT NULL,
  `is_selection` int DEFAULT NULL,
  `is_kx_disable` int DEFAULT NULL,
  `amount_of_money` decimal(12,2) DEFAULT NULL COMMENT '金额',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=1472 DEFAULT CHARSET=utf8mb3 COMMENT='标准成本预算-报价明细';


--
-- Table structure for table `t_system_applic`
--

DROP TABLE IF EXISTS `t_system_applic`;


CREATE TABLE `t_system_applic` (
  `seq` int NOT NULL AUTO_INCREMENT,
  `code` varchar(64) DEFAULT NULL COMMENT '编码',
  `name` varchar(64) DEFAULT NULL COMMENT '名称',
  `link` varchar(255) DEFAULT NULL COMMENT '跳转链接',
  `identifier` varchar(255) DEFAULT NULL COMMENT '标识',
  `private_key` varchar(255) DEFAULT NULL COMMENT '秘钥',
  `is_delete` char(1) DEFAULT NULL COMMENT '是否删除:0-否,1-是',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `create_at` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `update_at` datetime DEFAULT NULL COMMENT '更新时间',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `delete_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COMMENT='应用管理';


--
-- Table structure for table `t_temporary_material`
--

DROP TABLE IF EXISTS `t_temporary_material`;


CREATE TABLE `t_temporary_material` (
  `seq` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(255) DEFAULT NULL COMMENT '编码',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  `pandong` varchar(50) DEFAULT NULL COMMENT '潘东号(颜色的国际编号)',
  `explain` varchar(50) DEFAULT NULL COMMENT '物料说明',
  `en_explain` varchar(125) DEFAULT NULL COMMENT '物料说明(英)',
  `parent_seq` int DEFAULT NULL COMMENT '所属父级',
  `clazz` int DEFAULT NULL COMMENT '分类',
  `unit` int DEFAULT NULL COMMENT '单位',
  `colour` int DEFAULT NULL COMMENT '颜色',
  `is_combina` char(1) DEFAULT NULL COMMENT '是否组合物料:0-否,1-是',
  `expand` varchar(255) DEFAULT NULL COMMENT '拓展参数',
  `is_true` char(1) DEFAULT NULL COMMENT '是否真实物料',
  `delete_flag` char(1) DEFAULT '0' COMMENT '删除标识(0未删，1已删)',
  `delete_by` varchar(64) DEFAULT NULL COMMENT '删除者',
  `delete_time` datetime DEFAULT NULL COMMENT '删除时间',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '创建人',
  `create_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '更新人',
  `update_time` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='临时物料';


--
-- Table structure for table `tb_2g8bnb`
--

DROP TABLE IF EXISTS `tb_2g8bnb`;


CREATE TABLE `tb_2g8bnb` (
  `DAYS` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `WKJ` bigint DEFAULT NULL,
  `KJ` bigint DEFAULT NULL,
  `KJL` decimal(20,0) DEFAULT NULL COMMENT 'kjl'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `tb_5sae9`
--

DROP TABLE IF EXISTS `tb_5sae9`;


CREATE TABLE `tb_5sae9` (
  `MAC_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `tb_9wri`
--

DROP TABLE IF EXISTS `tb_9wri`;


CREATE TABLE `tb_9wri` (
  `MAC_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_DATE` datetime(3) DEFAULT NULL,
  `MAC_STS_L` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_STS_R` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_OPERT` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_CUS` bigint DEFAULT NULL,
  `MAC_TYPE` bigint DEFAULT NULL,
  `MAC_SPEED_L` decimal(30,6) DEFAULT NULL,
  `MAC_SPEED_R` decimal(30,6) DEFAULT NULL,
  `MAC_OUTPUT` bigint DEFAULT NULL,
  `MAC_IE_RATIO` decimal(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `tb_go96`
--

DROP TABLE IF EXISTS `tb_go96`;


CREATE TABLE `tb_go96` (
  `MAC_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `MAC_DATE` datetime(3) DEFAULT NULL,
  `MAC_CUS` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


--
-- Table structure for table `warehousing`
--

DROP TABLE IF EXISTS `warehousing`;


CREATE TABLE `warehousing` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '组户',
  `aritlec_seq` int DEFAULT NULL COMMENT '型体序号',
  `type` char(2) DEFAULT NULL COMMENT '单据类型\r\n10 样品单号\r\n20 成品单号',
  `no` int NOT NULL COMMENT '单据号',
  `size` double DEFAULT NULL COMMENT '尺码',
  `trading_object` varchar(255) DEFAULT NULL COMMENT '交易对象',
  `trading_currency` varchar(255) DEFAULT NULL COMMENT '交易货币',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  `amount` double(255,0) DEFAULT NULL COMMENT '金额',
  `warehouse_no` int DEFAULT NULL COMMENT '仓库',
  `place` varchar(255) NOT NULL COMMENT '存储位置',
  `quantity` varchar(255) DEFAULT NULL COMMENT '初始数量',
  `residue_amount` varchar(255) DEFAULT NULL COMMENT '剩余',
  `issue` varchar(255) DEFAULT NULL COMMENT '发出数量',
  `odd_numbers` varchar(255) DEFAULT NULL COMMENT '单号',
  `org` varchar(255) DEFAULT NULL COMMENT '机构',
  `tenant` varchar(255) DEFAULT NULL COMMENT '组户',
  PRIMARY KEY (`seq`) USING BTREE,
  KEY `artrcle_seq` (`no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='批次库存';


--
-- Table structure for table `working_procedure`
--

DROP TABLE IF EXISTS `working_procedure`;


CREATE TABLE `working_procedure` (
  `seq` int NOT NULL AUTO_INCREMENT COMMENT '序号',
  `art_seq` int DEFAULT NULL COMMENT '型体序号',
  `is_deleted` char(1) DEFAULT NULL COMMENT '是否删除',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) DEFAULT NULL COMMENT '修改人',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `deleted_by` varchar(64) DEFAULT NULL COMMENT '删除人',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='工序流';


--
-- Final view structure for view `caigousumview`
--


-- Dump completed on 2025-10-05 16:11:31
