-- Add temperature column to llm_configs table
ALTER TABLE llm_configs ADD COLUMN temperature FLOAT DEFAULT 0.7 COMMENT '模型温度';
