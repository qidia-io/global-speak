import { useState, useEffect, useCallback } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { Mic, Type, AlertCircle, Volume2, Copy, Check } from 'lucide-react';
import { HeroBanner } from '@/components/HeroBanner';
import { LanguagePairSelector } from '@/components/LanguageSelector';
import { HistoryPanel } from '@/components/HistoryPanel';
import { RecordButton } from '@/components/RecordButton';
import { VoiceTile } from '@/components/VoiceTile';
import { 
  startRecording, 
  stopRecording, 
  isRecording as checkIsRecording,
  requestMicrophonePermission,
  playAudio 
} from '@/services/audio';
import { 
  speechToText, 
  translateText, 
  textToSpeech, 
  isMockMode 
} from '@/services/inferenceClient';
import { 
  getHistory, 
  addHistoryItem, 
  removeHistoryItem,
  HistoryItem 
} from '@/services/storage';
import { isRTL } from '@/config/languages';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

export default function VoiceScreen() {
  const navigate = useNavigate();
  const [fromLang, setFromLang] = useState('en');
  const [toLang, setToLang] = useState('es');
  const [isRecording, setIsRecording] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [history, setHistory] = useState<HistoryItem[]>([]);
  const [currentTranscript, setCurrentTranscript] = useState('');
  const [currentTranslation, setCurrentTranslation] = useState('');
  const [playingId, setPlayingId] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const [hasMicPermission, setHasMicPermission] = useState<boolean | null>(null);

  useEffect(() => {
    setHistory(getHistory().filter(item => item.mode === 'voice'));
  }, []);

  useEffect(() => {
    requestMicrophonePermission().then(setHasMicPermission);
  }, []);

  const handleSwapLanguages = () => {
    const temp = fromLang;
    setFromLang(toLang);
    setToLang(temp);
  };

  const handleStartRecording = async () => {
    if (hasMicPermission === false) {
      toast.error('Microphone access is required for voice translation');
      return;
    }

    try {
      await startRecording();
      setIsRecording(true);
      setCurrentTranscript('');
      setCurrentTranslation('');
    } catch (error) {
      toast.error('Failed to start recording');
    }
  };

  const handleStopRecording = async () => {
    try {
      setIsRecording(false);
      setIsProcessing(true);

      const audioBlob = await stopRecording();
      
      // Step 1: Speech to Text
      const transcript = await speechToText(audioBlob, fromLang);
      setCurrentTranscript(transcript);

      // Step 2: Translate
      const translation = await translateText(transcript, fromLang, toLang);
      setCurrentTranslation(translation);

      // Step 3: Text to Speech (optional)
      let ttsAudioRef: string | undefined;
      if (!isMockMode()) {
        const ttsUrl = await textToSpeech(translation, toLang);
        if (ttsUrl) {
          ttsAudioRef = ttsUrl;
        }
      }

      // Save to history
      const newItem = addHistoryItem({
        fromLang,
        toLang,
        sourceText: transcript,
        translatedText: translation,
        ttsAudioRef,
        mode: 'voice',
      });

      setHistory(prev => [newItem, ...prev]);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Translation failed');
    } finally {
      setIsProcessing(false);
    }
  };

  const handlePlayAudio = async (item: HistoryItem) => {
    if (!item.ttsAudioRef) return;
    
    try {
      setPlayingId(item.id);
      await playAudio(item.ttsAudioRef);
    } catch (error) {
      toast.error('Failed to play audio');
    } finally {
      setPlayingId(null);
    }
  };

  const handleCopy = (item: HistoryItem) => {
    navigator.clipboard.writeText(item.translatedText);
    toast.success('Copied to clipboard');
  };

  const handleDelete = (item: HistoryItem) => {
    removeHistoryItem(item.id);
    setHistory(prev => prev.filter(h => h.id !== item.id));
  };

  const handleCopyTranslation = () => {
    if (currentTranslation) {
      navigator.clipboard.writeText(currentTranslation);
      setCopied(true);
      toast.success('Copied to clipboard');
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const handlePlayTranslation = async () => {
    if (currentTranslation && !isMockMode()) {
      try {
        const ttsUrl = await textToSpeech(currentTranslation, toLang);
        if (ttsUrl) {
          await playAudio(ttsUrl);
        }
      } catch (error) {
        toast.error('Failed to play audio');
      }
    }
  };

  return (
    <div className="min-h-screen px-5 py-6">
      <div className="max-w-lg mx-auto">
        {/* Header */}
        <div className="mb-4">
          <h1 className="text-xl font-bold text-foreground">Global Translator</h1>
          <p className="text-xs text-muted-foreground">
            Multilingual & Simultaneous Translation
          </p>
        </div>

        {/* Mock mode indicator */}
        {isMockMode() && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="flex items-center gap-2 px-3 py-2 mb-4 rounded-lg bg-amber-500/10 text-amber-600 text-xs"
          >
            <AlertCircle className="w-4 h-4" />
            <span>Mock mode: Configure HF_TOKEN in Settings for real translations</span>
          </motion.div>
        )}

        {/* Hero Banner */}
        <HeroBanner className="mb-6" />

        {/* Mode Toggle */}
        <div className="flex items-center gap-2 mb-4">
          <span className="text-sm font-medium text-foreground">Voice Conversation</span>
          <div className="flex-1" />
          <div className="flex bg-secondary rounded-lg p-1">
            <button className="px-3 py-1.5 text-xs font-medium rounded-md bg-primary text-primary-foreground">
              <Mic className="w-3.5 h-3.5 inline mr-1" />
              Voice
            </button>
            <button 
              onClick={() => navigate('/text')}
              className="px-3 py-1.5 text-xs font-medium rounded-md text-muted-foreground hover:text-foreground"
            >
              <Type className="w-3.5 h-3.5 inline mr-1" />
              Text
            </button>
          </div>
        </div>

        {/* Language Selectors */}
        <LanguagePairSelector
          fromLang={fromLang}
          toLang={toLang}
          onFromChange={setFromLang}
          onToChange={setToLang}
          onSwap={handleSwapLanguages}
        />

        {/* Voice Tiles */}
        <div className="grid grid-cols-2 gap-3 mt-5">
          <VoiceTile
            langCode={fromLang}
            variant="from"
            isRecording={isRecording}
            onClick={isRecording ? handleStopRecording : handleStartRecording}
            disabled={isProcessing}
          />
          <VoiceTile
            langCode={toLang}
            variant="to"
            disabled
          />
        </div>

        {/* Record Button */}
        <div className="flex flex-col items-center mt-6 mb-6">
          <RecordButton
            isRecording={isRecording}
            isProcessing={isProcessing}
            onStart={handleStartRecording}
            onStop={handleStopRecording}
            disabled={hasMicPermission === false}
          />
          <p className="text-xs text-muted-foreground mt-3">
            {isRecording 
              ? 'Tap to stop recording' 
              : isProcessing 
                ? 'Processing...' 
                : 'Tap to start speaking'}
          </p>
        </div>

        {/* Current Translation Result */}
        {(currentTranscript || currentTranslation) && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-card rounded-2xl border border-border p-4 mb-6"
          >
            {currentTranscript && (
              <div className="mb-3">
                <label className="text-xs text-muted-foreground mb-1 block">
                  Transcription
                </label>
                <p className="text-sm text-foreground bg-secondary/50 rounded-lg px-3 py-2">
                  {currentTranscript}
                </p>
              </div>
            )}
            {currentTranslation && (
              <div>
                <label className="text-xs text-muted-foreground mb-1 block">
                  Translation
                </label>
                <p className={cn(
                  "text-sm font-medium text-primary bg-primary/10 rounded-lg px-3 py-2",
                  isRTL(toLang) && "rtl"
                )}>
                  {currentTranslation}
                </p>
                <div className="flex gap-2 mt-2">
                  {!isMockMode() && (
                    <button
                      onClick={handlePlayTranslation}
                      className="flex items-center gap-1 px-3 py-1.5 text-xs font-medium rounded-lg bg-secondary hover:bg-secondary/80"
                    >
                      <Volume2 className="w-3.5 h-3.5" />
                      Play
                    </button>
                  )}
                  <button
                    onClick={handleCopyTranslation}
                    className="flex items-center gap-1 px-3 py-1.5 text-xs font-medium rounded-lg bg-secondary hover:bg-secondary/80"
                  >
                    {copied ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
                    {copied ? 'Copied' : 'Copy'}
                  </button>
                </div>
              </div>
            )}
          </motion.div>
        )}

        {/* History Panel */}
        <HistoryPanel
          items={history}
          onPlay={handlePlayAudio}
          onCopy={handleCopy}
          onDelete={handleDelete}
          isPlaying={playingId}
        />
      </div>
    </div>
  );
}
