// Hugging Face Inference Client with Mock Mode support
// Uses .env variables or falls back to mock mode

interface InferenceConfig {
  hfToken: string | null;
  sstModel: string;
  nmtModel: string;
  ttsModel: string;
  sstEndpoint?: string;
  nmtEndpoint?: string;
  ttsEndpoint?: string;
}

const getConfig = (): InferenceConfig => ({
  hfToken: localStorage.getItem('HF_TOKEN') || null,
  sstModel: localStorage.getItem('HF_SST_MODEL') || 'openai/whisper-large-v3',
  nmtModel: localStorage.getItem('HF_NMT_MODEL') || 'facebook/nllb-200-distilled-600M',
  ttsModel: localStorage.getItem('HF_TTS_MODEL') || 'facebook/mms-tts',
  sstEndpoint: localStorage.getItem('SST_ENDPOINT_URL') || undefined,
  nmtEndpoint: localStorage.getItem('NMT_ENDPOINT_URL') || undefined,
  ttsEndpoint: localStorage.getItem('TTS_ENDPOINT_URL') || undefined,
});

export const isMockMode = (): boolean => {
  const config = getConfig();
  return !config.hfToken;
};

// Speech to Text
export const speechToText = async (
  audioBlob: Blob,
  sourceLang: string
): Promise<string> => {
  const config = getConfig();
  
  if (isMockMode()) {
    // Mock mode - return placeholder
    await new Promise(resolve => setTimeout(resolve, 1000));
    return `[Mock transcription for ${sourceLang}] This is a placeholder transcription. Configure HF_TOKEN to enable real speech recognition.`;
  }

  try {
    const endpoint = config.sstEndpoint || `https://api-inference.huggingface.co/models/${config.sstModel}`;
    
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.hfToken}`,
        'Content-Type': 'audio/wav',
      },
      body: audioBlob,
    });

    if (!response.ok) {
      throw new Error(`SST API error: ${response.status}`);
    }

    const result = await response.json();
    return result.text || result.transcription || '';
  } catch (error) {
    console.error('Speech to text error:', error);
    throw new Error('Failed to transcribe audio. Please try again.');
  }
};

// Language code mapping for NLLB model
const nllbLanguageCodes: Record<string, string> = {
  'en': 'eng_Latn',
  'es': 'spa_Latn',
  'sw': 'swh_Latn',
  'hi': 'hin_Deva',
  'ar': 'arb_Arab',
  'bn': 'ben_Beng',
  'pt': 'por_Latn',
  'ru': 'rus_Cyrl',
  'id': 'ind_Latn',
  'ur': 'urd_Arab',
  'fr': 'fra_Latn',
  'de': 'deu_Latn',
  'ja': 'jpn_Jpan',
  'ko': 'kor_Hang',
  'zh': 'zho_Hans',
  'vi': 'vie_Latn',
  'th': 'tha_Thai',
  'ta': 'tam_Taml',
  'te': 'tel_Telu',
  'mr': 'mar_Deva',
  'tr': 'tur_Latn',
  'pl': 'pol_Latn',
  'uk': 'ukr_Cyrl',
  'nl': 'nld_Latn',
  'it': 'ita_Latn',
  'wo': 'wol_Latn',
};

// Text Translation
export const translateText = async (
  text: string,
  sourceLang: string,
  targetLang: string
): Promise<string> => {
  const config = getConfig();
  
  if (isMockMode()) {
    // Mock mode - return placeholder
    await new Promise(resolve => setTimeout(resolve, 800));
    return `[Mock translation to ${targetLang}] "${text}" — Configure HF_TOKEN to enable real translation.`;
  }

  try {
    const endpoint = config.nmtEndpoint || `https://api-inference.huggingface.co/models/${config.nmtModel}`;
    
    const srcCode = nllbLanguageCodes[sourceLang] || 'eng_Latn';
    const tgtCode = nllbLanguageCodes[targetLang] || 'eng_Latn';

    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.hfToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        inputs: text,
        parameters: {
          src_lang: srcCode,
          tgt_lang: tgtCode,
        },
      }),
    });

    if (!response.ok) {
      throw new Error(`NMT API error: ${response.status}`);
    }

    const result = await response.json();
    
    if (Array.isArray(result) && result[0]?.translation_text) {
      return result[0].translation_text;
    }
    if (result.translation_text) {
      return result.translation_text;
    }
    if (typeof result === 'string') {
      return result;
    }
    
    throw new Error('Unexpected translation response format');
  } catch (error) {
    console.error('Translation error:', error);
    throw new Error('Failed to translate text. Please try again.');
  }
};

// Text to Speech
export const textToSpeech = async (
  text: string,
  targetLang: string
): Promise<string | null> => {
  const config = getConfig();
  
  if (isMockMode()) {
    // Mock mode - return null (disable playback)
    console.log('[Mock TTS] Playback disabled in mock mode');
    return null;
  }

  try {
    const endpoint = config.ttsEndpoint || `https://api-inference.huggingface.co/models/${config.ttsModel}`;
    
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.hfToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ inputs: text }),
    });

    if (!response.ok) {
      throw new Error(`TTS API error: ${response.status}`);
    }

    const audioBlob = await response.blob();
    return URL.createObjectURL(audioBlob);
  } catch (error) {
    console.error('Text to speech error:', error);
    return null;
  }
};

// Save configuration
export const saveConfig = (config: Partial<InferenceConfig>) => {
  if (config.hfToken !== undefined) {
    if (config.hfToken) {
      localStorage.setItem('HF_TOKEN', config.hfToken);
    } else {
      localStorage.removeItem('HF_TOKEN');
    }
  }
  if (config.sstModel) localStorage.setItem('HF_SST_MODEL', config.sstModel);
  if (config.nmtModel) localStorage.setItem('HF_NMT_MODEL', config.nmtModel);
  if (config.ttsModel) localStorage.setItem('HF_TTS_MODEL', config.ttsModel);
  if (config.sstEndpoint !== undefined) {
    if (config.sstEndpoint) {
      localStorage.setItem('SST_ENDPOINT_URL', config.sstEndpoint);
    } else {
      localStorage.removeItem('SST_ENDPOINT_URL');
    }
  }
  if (config.nmtEndpoint !== undefined) {
    if (config.nmtEndpoint) {
      localStorage.setItem('NMT_ENDPOINT_URL', config.nmtEndpoint);
    } else {
      localStorage.removeItem('NMT_ENDPOINT_URL');
    }
  }
  if (config.ttsEndpoint !== undefined) {
    if (config.ttsEndpoint) {
      localStorage.setItem('TTS_ENDPOINT_URL', config.ttsEndpoint);
    } else {
      localStorage.removeItem('TTS_ENDPOINT_URL');
    }
  }
};

export const loadConfig = (): InferenceConfig => getConfig();
