============================================
-- Global Speak — Población inicial de BD
-- Generado: script automático
============================================

BEGIN;

-- 1. Lenguas
INSERT INTO languages (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200_support, priority) VALUES ('wo', 'wol', 'Wolof', 'Wolof', 'Níger-Congo', 'Senegal, Gambia', 10.0, FALSE, TRUE, 'high') ON CONFLICT (code) DO NOTHING;
INSERT INTO languages (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200_support, priority) VALUES ('es', 'spa', 'Spanish', 'Español', 'Indo-European', 'Spain, Americas', 500.0, FALSE, TRUE, 'high') ON CONFLICT (code) DO NOTHING;
INSERT INTO languages (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200_support, priority) VALUES ('fr', 'fra', 'French', 'Français', 'Indo-European', 'France, Africa', 320.0, FALSE, TRUE, 'high') ON CONFLICT (code) DO NOTHING;
INSERT INTO languages (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200_support, priority) VALUES ('sw', 'swa', 'Swahili', 'Kiswahili', 'Níger-Congo', 'East Africa', 80.0, FALSE, TRUE, 'high') ON CONFLICT (code) DO NOTHING;
INSERT INTO languages (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200_support, priority) VALUES ('it', 'ita', 'Italian', 'Italiano', 'Indo-European', 'Italy', 68.0, FALSE, TRUE, 'medium') ON CONFLICT (code) DO NOTHING;
INSERT INTO languages (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200_support, priority) VALUES ('ff', 'ful', 'Fula', 'Fulfulde', 'Níger-Congo', 'West Africa', 40.0, FALSE, TRUE, 'medium') ON CONFLICT (code) DO NOTHING;
INSERT INTO languages (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200_support, priority) VALUES ('bm', 'bam', 'Bambara', 'Bamanankan', 'Mandé', 'Mali, Ivory Coast', 15.0, FALSE, TRUE, 'medium') ON CONFLICT (code) DO NOTHING;
INSERT INTO languages (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200_support, priority) VALUES ('en', 'eng', 'English', 'English', 'Indo-European', 'Global', 1500.0, FALSE, TRUE, 'medium') ON CONFLICT (code) DO NOTHING;

-- 2. Modelos
INSERT INTO models (name, architecture, hf_repo, description, source_lang, target_lang, base_model, parameters, size_mb, status) VALUES ('sainzpaa/SPANISH-WOLOF-BYT5', 'ByT5-large', 'sainzpaa/SPANISH-WOLOF-BYT5', 'Fine-tuned ByT5 para Español ↔ Wolof', 'es', 'wo', 'google/byt5-small', 580000000, 2300.0, 'production') ON CONFLICT (name) DO NOTHING;
INSERT INTO models (name, architecture, hf_repo, description, source_lang, target_lang, base_model, parameters, size_mb, status) VALUES ('facebook/nllb-200-distilled-600M', 'NLLB-200 distilled', 'facebook/nllb-200-distilled-600M', 'NLLB-200 distillado 600M — 200 lenguas', NULL, NULL, NULL, 600000000, 1200.0, 'production') ON CONFLICT (name) DO NOTHING;
INSERT INTO models (name, architecture, hf_repo, description, source_lang, target_lang, base_model, parameters, size_mb, status) VALUES ('openai/whisper-large-v3', 'Whisper Large V3', 'openai/whisper-large-v3', 'Speech-to-Text multilingüe', NULL, NULL, NULL, 1550000000, 3100.0, 'production') ON CONFLICT (name) DO NOTHING;
INSERT INTO models (name, architecture, hf_repo, description, source_lang, target_lang, base_model, parameters, size_mb, status) VALUES ('facebook/mms-tts', 'MMS-TTS', 'facebook/mms-tts', 'Text-to-Speech 1100+ lenguas', NULL, NULL, NULL, 400000000, 1800.0, 'production') ON CONFLICT (name) DO NOTHING;

-- 3. Pipeline por defecto (Wolof ↔ Español)

INSERT INTO pipelines (name, sst_model, nmt_model, tts_model, source_lang, target_lang, status)
VALUES (
    'Wolof-Español',
    (SELECT id FROM models WHERE name = 'Whisper Large V3'),
    (SELECT id FROM models WHERE name = 'ByT5-large'),
    (SELECT id FROM models WHERE name = 'MMS-TTS'),
    'wo', 'es', 'development'
);

COMMIT;

