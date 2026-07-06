import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { Mic, Type, AlertCircle, Volume2, Copy, Check, Loader2 } from 'lucide-react';
import { LanguagePairSelector } from '@/components/LanguageSelector';
import { HistoryPanel } from '@/components/HistoryPanel';
import { translateText, textToSpeech, isMockMode } from '@/services/inferenceClient';
import { 
  getHistory, 
  addHistoryItem, 
  removeHistoryItem,
  HistoryItem 
} from '@/services/storage';
import { playAudio } from '@/services/audio';
import { isRTL } from '@/config/languages';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';

export default function TextScreen() {
  const navigate = useNavigate();
  const [fromLang, setFromLang] = useState('en');
  const [toLang, setToLang] = useState('hi');
  const [inputText, setInputText] = useState('');
  const [translatedText, setTranslatedText] = useState('');
  const [isTranslating, setIsTranslating] = useState(false);
  const [history, setHistory] = useState<HistoryItem[]>([]);
  const [playingId, setPlayingId] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const [isPlayingTranslation, setIsPlayingTranslation] = useState(false);

  useEffect(() => {
    setHistory(getHistory().filter(item => item.mode === 'text'));
  }, []);

  const handleSwapLanguages = () => {
    const temp = fromLang;
    setFromLang(toLang);
    setToLang(temp);
    
    // Swap texts too
    if (translatedText) {
      setInputText(translatedText);
      setTranslatedText(inputText);
    }
  };

  const handleTranslate = async () => {
    if (!inputText.trim()) {
      toast.error('Please enter text to translate');
      return;
    }

    try {
      setIsTranslating(true);
      const translation = await translateText(inputText, fromLang, toLang);
      setTranslatedText(translation);

      // Get TTS audio
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
        sourceText: inputText,
        translatedText: translation,
        ttsAudioRef,
        mode: 'text',
      });

      setHistory(prev => [newItem, ...prev]);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Translation failed');
    } finally {
      setIsTranslating(false);
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
    if (translatedText) {
      navigator.clipboard.writeText(translatedText);
      setCopied(true);
      toast.success('Copied to clipboard');
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const handlePlayTranslation = async () => {
    if (translatedText && !isMockMode()) {
      try {
        setIsPlayingTranslation(true);
        const ttsUrl = await textToSpeech(translatedText, toLang);
        if (ttsUrl) {
          await playAudio(ttsUrl);
        }
      } catch (error) {
        toast.error('Failed to play audio');
      } finally {
        setIsPlayingTranslation(false);
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
            Text Translation Mode
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

        {/* Mode Toggle */}
        <div className="flex items-center gap-2 mb-4">
          <span className="text-sm font-medium text-foreground">Text Translation</span>
          <div className="flex-1" />
          <div className="flex bg-secondary rounded-lg p-1">
            <button 
              onClick={() => navigate('/voice')}
              className="px-3 py-1.5 text-xs font-medium rounded-md text-muted-foreground hover:text-foreground"
            >
              <Mic className="w-3.5 h-3.5 inline mr-1" />
              Voice
            </button>
            <button className="px-3 py-1.5 text-xs font-medium rounded-md bg-primary text-primary-foreground">
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

        {/* Input Area */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mt-5"
        >
          <div className="bg-card rounded-2xl border border-border overflow-hidden">
            <textarea
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              placeholder="Enter text to translate..."
              className={cn(
                "w-full min-h-[120px] p-4 text-sm bg-transparent resize-none",
                "focus:outline-none placeholder:text-muted-foreground",
                isRTL(fromLang) && "rtl"
              )}
            />
            <div className="flex items-center justify-between px-4 py-2 border-t border-border bg-secondary/30">
              <span className="text-xs text-muted-foreground">
                {inputText.length} characters
              </span>
              <Button
                onClick={handleTranslate}
                disabled={!inputText.trim() || isTranslating}
                size="sm"
                className="rounded-lg"
              >
                {isTranslating ? (
                  <>
                    <Loader2 className="w-4 h-4 mr-1 animate-spin" />
                    Translating...
                  </>
                ) : (
                  'Translate'
                )}
              </Button>
            </div>
          </div>
        </motion.div>

        {/* Translation Output */}
        {translatedText && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="mt-4"
          >
            <div className="bg-primary/5 rounded-2xl border border-primary/20 overflow-hidden">
              <div 
                className={cn(
                  "p-4 min-h-[100px]",
                  isRTL(toLang) && "rtl"
                )}
              >
                <p className="text-sm font-medium text-primary">
                  {translatedText}
                </p>
              </div>
              <div className="flex items-center gap-2 px-4 py-2 border-t border-primary/10 bg-primary/5">
                {!isMockMode() && (
                  <button
                    onClick={handlePlayTranslation}
                    disabled={isPlayingTranslation}
                    className="flex items-center gap-1 px-3 py-1.5 text-xs font-medium rounded-lg bg-primary/10 hover:bg-primary/20 text-primary transition-colors"
                  >
                    <Volume2 className={cn("w-3.5 h-3.5", isPlayingTranslation && "animate-pulse")} />
                    {isPlayingTranslation ? 'Playing...' : 'Play'}
                  </button>
                )}
                <button
                  onClick={handleCopyTranslation}
                  className="flex items-center gap-1 px-3 py-1.5 text-xs font-medium rounded-lg bg-primary/10 hover:bg-primary/20 text-primary transition-colors"
                >
                  {copied ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
                  {copied ? 'Copied' : 'Copy'}
                </button>
              </div>
            </div>
          </motion.div>
        )}

        {/* History Panel */}
        <div className="mt-6">
          <HistoryPanel
            items={history}
            onPlay={handlePlayAudio}
            onCopy={handleCopy}
            onDelete={handleDelete}
            isPlaying={playingId}
          />
        </div>
      </div>
    </div>
  );
}
