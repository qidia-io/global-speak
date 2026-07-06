-- global-speak Database Schema
-- PostgreSQL 18
-- Creado: Julio 2026

-- ============================================
-- 1. Model Registry
-- ============================================
CREATE TABLE models (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL UNIQUE,
    architecture    VARCHAR(100) NOT NULL,
    hf_repo         VARCHAR(255),
    description     TEXT,
    source_lang     VARCHAR(10),
    target_lang     VARCHAR(10),
    base_model      VARCHAR(255),
    parameters      BIGINT,
    size_mb         NUMERIC(10,2),
    status          VARCHAR(50) DEFAULT 'development',
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 2. Languages
-- ============================================
CREATE TABLE languages (
    code            VARCHAR(10) PRIMARY KEY,
    iso_639_3       VARCHAR(10),
    name_en         VARCHAR(100),
    name_native     VARCHAR(100),
    family          VARCHAR(100),
    region          VARCHAR(255),
    speakers_m      NUMERIC(8,2),
    rtl             BOOLEAN DEFAULT FALSE,
    nllb200_support BOOLEAN DEFAULT FALSE,
    priority        VARCHAR(20) DEFAULT 'low'
);

-- ============================================
-- 3. Training Runs
-- ============================================
CREATE TABLE training_runs (
    id              SERIAL PRIMARY KEY,
    model_id        INTEGER REFERENCES models(id),
    epochs          INTEGER,
    batch_size      INTEGER,
    learning_rate   NUMERIC(10,8),
    dataset_size    INTEGER,
    dataset_source  TEXT,
    hardware        VARCHAR(100),
    duration_min    NUMERIC(10,2),
    loss_final      NUMERIC(10,6),
    status          VARCHAR(50) DEFAULT 'pending',
    notes           TEXT,
    started_at      TIMESTAMP,
    finished_at     TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 4. Evaluation Results
-- ============================================
CREATE TABLE evaluations (
    id              SERIAL PRIMARY KEY,
    training_run_id INTEGER REFERENCES training_runs(id),
    model_id        INTEGER REFERENCES models(id),
    metric          VARCHAR(50),
    score           NUMERIC(10,6),
    source_lang     VARCHAR(10),
    target_lang     VARCHAR(10),
    test_set_name   VARCHAR(255),
    sample_count    INTEGER,
    evaluated_at    TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 5. Datasets
-- ============================================
CREATE TABLE datasets (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    source_lang     VARCHAR(10),
    target_lang     VARCHAR(10),
    source          VARCHAR(255),
    sentence_count  INTEGER,
    size_mb         NUMERIC(10,2),
    quality_score   NUMERIC(3,2),
    notes           TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 6. Pipeline Configurations
-- ============================================
CREATE TABLE pipelines (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    sst_model       INTEGER REFERENCES models(id),
    nmt_model       INTEGER REFERENCES models(id),
    tts_model       INTEGER REFERENCES models(id),
    source_lang     VARCHAR(10),
    target_lang     VARCHAR(10),
    status          VARCHAR(50) DEFAULT 'development',
    avg_latency_ms  NUMERIC(10,2),
    created_at      TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 7. Pipeline Test Logs
-- ============================================
CREATE TABLE pipeline_logs (
    id              SERIAL PRIMARY KEY,
    pipeline_id     INTEGER REFERENCES pipelines(id),
    source_text     TEXT,
    transcribed_text TEXT,
    translated_text TEXT,
    sst_latency_ms  INTEGER,
    nmt_latency_ms  INTEGER,
    tts_latency_ms  INTEGER,
    total_latency_ms INTEGER,
    success         BOOLEAN,
    error_message   TEXT,
    tested_at       TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 8. Deployments
-- ============================================
CREATE TABLE deployments (
    id              SERIAL PRIMARY KEY,
    pipeline_id     INTEGER REFERENCES pipelines(id),
    app_version     VARCHAR(50),
    platform        VARCHAR(50),
    status          VARCHAR(50) DEFAULT 'pending',
    notes           TEXT,
    deployed_at     TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 9. App Builds
-- ============================================
CREATE TABLE app_builds (
    id              SERIAL PRIMARY KEY,
    version         VARCHAR(50) NOT NULL,
    platform        VARCHAR(50) NOT NULL,
    framework       VARCHAR(50),
    status          VARCHAR(50) DEFAULT 'pending',
    artifact_url    TEXT,
    commit_sha      VARCHAR(64),
    notes           TEXT,
    built_at        TIMESTAMP DEFAULT NOW()
);
