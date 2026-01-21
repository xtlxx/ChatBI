-- =========================================================
-- 企业级 AI SQL 分析平台数据库初始化脚本 (优化版)
-- 版本: 1.1.0
-- 优化要点: 安全性、可扩展性、性能、数据一致性
-- 创建时间: 2026-01-20
-- =========================================================
-- 使用数据库 (根据实际情况修改)
-- CREATE DATABASE IF NOT EXISTS chatbi DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE chatbi;
-- ============================================
-- 1. 用户表
-- 优化:
-- - `id` 改为 `BIGINT` 以支持海量用户。
-- - 时间戳使用 `DATETIME(3)` 提供毫秒级精度。
-- - 移除了多余的索引 (`UNIQUE` 约束已自动创建索引)。
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    email VARCHAR(100) UNIQUE NOT NULL COMMENT '邮箱',
    hashed_password VARCHAR(255) NOT NULL COMMENT '哈希密码 (应使用bcrypt或Argon2)',
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    updated_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表';
-- ============================================
-- 2. 数据库连接配置表
-- 优化:
-- - `id`, `user_id` 改为 `BIGINT`。
-- - [安全] `password` 字段改为 `encrypted_password VARBINARY(512)`，强制应用层加密。
-- - `type` 字段改为 `ENUM` 保证数据一致性。
-- - 添加 `UNIQUE KEY` 防止同一用户下连接重名。
-- ============================================
CREATE TABLE IF NOT EXISTS db_connections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '连接ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    name VARCHAR(100) NOT NULL COMMENT '连接名称',
    type ENUM(
        'mysql',
        'postgresql',
        'mssql',
        'clickhouse',
        'sqlite',
        'oracle',
        'other'
    ) NOT NULL COMMENT '数据库类型',
    host VARCHAR(255) NOT NULL COMMENT '主机地址',
    port INT NOT NULL COMMENT '端口号',
    username VARCHAR(100) NOT NULL COMMENT '数据库用户名',
    encrypted_password VARBINARY(512) NOT NULL COMMENT '加密后的数据库密码',
    database_name VARCHAR(100) NOT NULL COMMENT '数据库名',
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    updated_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_id_name (user_id, name) COMMENT '同一用户下的连接名称应唯一'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '数据库连接配置表';
-- ============================================
-- 3. LLM 配置表
-- 优化:
-- - `id`, `user_id` 改为 `BIGINT`。
-- - [安全] `api_key` 字段改为 `encrypted_api_key VARBINARY(1024)`，强制应用层加密。
-- - `provider` 字段改为 `ENUM` 保证数据一致性。
-- - `base_url` 长度增加到 512。
-- ============================================
CREATE TABLE IF NOT EXISTS llm_configs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    provider ENUM(
        'openai',
        'qwen',
        'deepseek',
        'anthropic',
        'moonshot',
        'ollama',
        'gemini',
        'other'
    ) NOT NULL COMMENT 'LLM提供商',
    model_name VARCHAR(100) NOT NULL COMMENT '模型名称',
    encrypted_api_key VARBINARY(1024) NOT NULL COMMENT '加密后的API密钥',
    base_url VARCHAR(512) NULL COMMENT '自定义API端点',
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    updated_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id_provider (user_id, provider) COMMENT '快速查找用户的LLM配置'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'LLM配置表';
-- ============================================
-- 4. 聊天会话表
-- 优化:
-- - `id` 明确为 `VARCHAR(36)` 以适应标准UUID。
-- - `user_id` 改为 `BIGINT`。
-- ============================================
CREATE TABLE IF NOT EXISTS chat_sessions (
    id VARCHAR(36) PRIMARY KEY COMMENT '会话ID (UUID)',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    title VARCHAR(200) NOT NULL COMMENT '会话标题',
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    updated_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '聊天会话表';
-- ============================================
-- 5. 聊天消息表
-- 优化:
-- - `id` 改为 `BIGINT`。
-- - `session_id` 明确为 `VARCHAR(36)`。
-- - `role` 字段改为 `ENUM`。
-- - `content` 字段改为 `MEDIUMTEXT` 以支持更长的上下文和代码块。
-- - [性能] 创建了 `(session_id, created_at)` 复合索引，极大提升聊天记录加载速度。
-- 未来规划: 当此表数据量巨大时，应考虑按 `created_at` 进行范围分区 (PARTITION BY RANGE)。
-- ============================================
CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '消息ID',
    session_id VARCHAR(36) NOT NULL COMMENT '会话ID',
    role ENUM('user', 'ai', 'system') NOT NULL COMMENT '角色',
    content MEDIUMTEXT NOT NULL COMMENT '消息内容',
    metadata JSON NULL COMMENT '元数据 (thoughts, sql_query, chart_data等)',
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    FOREIGN KEY (session_id) REFERENCES chat_sessions(id) ON DELETE CASCADE,
    INDEX idx_session_id_created_at (session_id, created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '聊天消息表';
-- ============================================
-- 6. 插入测试数据 (可选)
-- 注意: hashed_password 是一个示例值，实际生产中必须由您的应用程序通过安全哈希算法（如 bcrypt）动态生成。
-- ============================================
INSERT INTO users (username, email, hashed_password)
VALUES (
        'admin',
        'admin@example.com',
        '$2b$12$Ebed8ZOn2gBw.o.C.mI8O.ds34f/PlTjKLs2T6T.pl.b.Q3g7fQ8i' -- 示例密码: password123
    ),
    (
        'demo',
        'demo@example.com',
        '$2b$12$Vd5dK8C.Zz.P9R.E4fI7Y.Lz2n.Q8mI0j.e6T.s.q9W.p0r.u7W.k' -- 示例密码: demo123
    ) ON DUPLICATE KEY
UPDATE username =
VALUES(username);
-- ============================================
-- 完成
-- ============================================
SELECT 'Optimized database schema created successfully!' AS status;
-- 查看所有创建的表
SHOW TABLES;