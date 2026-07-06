import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Key, Server, Trash2, Info, ExternalLink, Shield } from 'lucide-react';
import { loadConfig, saveConfig, isMockMode } from '@/services/inferenceClient';
import { clearHistory, getHistory } from '@/services/storage';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';

export default function SettingsScreen() {
  const [hfToken, setHfToken] = useState('');
  const [sstModel, setSstModel] = useState('');
  const [nmtModel, setNmtModel] = useState('');
  const [ttsModel, setTtsModel] = useState('');
  const [sstEndpoint, setSstEndpoint] = useState('');
  const [nmtEndpoint, setNmtEndpoint] = useState('');
  const [ttsEndpoint, setTtsEndpoint] = useState('');
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [historyCount, setHistoryCount] = useState(0);

  useEffect(() => {
    const config = loadConfig();
    setHfToken(config.hfToken || '');
    setSstModel(config.sstModel);
    setNmtModel(config.nmtModel);
    setTtsModel(config.ttsModel);
    setSstEndpoint(config.sstEndpoint || '');
    setNmtEndpoint(config.nmtEndpoint || '');
    setTtsEndpoint(config.ttsEndpoint || '');
    setHistoryCount(getHistory().length);
  }, []);

  const handleSave = () => {
    saveConfig({
      hfToken: hfToken || null,
      sstModel,
      nmtModel,
      ttsModel,
      sstEndpoint: sstEndpoint || undefined,
      nmtEndpoint: nmtEndpoint || undefined,
      ttsEndpoint: ttsEndpoint || undefined,
    });
    toast.success('Settings saved');
  };

  const handleClearHistory = () => {
    clearHistory();
    setHistoryCount(0);
    toast.success('History cleared');
  };

  return (
    <div className="min-h-screen px-5 py-6">
      <div className="max-w-lg mx-auto">
        {/* Header */}
        <div className="mb-6">
          <h1 className="text-xl font-bold text-foreground">Settings</h1>
          <p className="text-xs text-muted-foreground">
            Configure translation services
          </p>
        </div>

        {/* Mock Mode Status */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className={cn(
            "flex items-center gap-3 p-4 rounded-xl mb-6",
            isMockMode()
              ? "bg-amber-500/10 border border-amber-500/20"
              : "bg-success/10 border border-success/20"
          )}
        >
          <div className={cn(
            "w-10 h-10 rounded-full flex items-center justify-center",
            isMockMode() ? "bg-amber-500/20" : "bg-success/20"
          )}>
            <Key className={cn(
              "w-5 h-5",
              isMockMode() ? "text-amber-600" : "text-success"
            )} />
          </div>
          <div className="flex-1">
            <div className={cn(
              "font-medium text-sm",
              isMockMode() ? "text-amber-700" : "text-success"
            )}>
              {isMockMode() ? 'Mock Mode Active' : 'Connected'}
            </div>
            <div className="text-xs text-muted-foreground">
              {isMockMode() 
                ? 'Add HF_TOKEN to enable real translations' 
                : 'Hugging Face API connected'}
            </div>
          </div>
        </motion.div>

        {/* API Token Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-card rounded-2xl border border-border p-4 mb-4"
        >
          <div className="flex items-center gap-2 mb-3">
            <Key className="w-4 h-4 text-primary" />
            <h3 className="font-semibold text-sm">Hugging Face Token</h3>
          </div>
          <input
            type="password"
            value={hfToken}
            onChange={(e) => setHfToken(e.target.value)}
            placeholder="hf_xxxxxxxxxxxxxxxx"
            className={cn(
              "w-full px-4 py-3 text-sm rounded-xl",
              "bg-secondary/50 border border-border",
              "focus:outline-none focus:ring-2 focus:ring-primary/20",
              "placeholder:text-muted-foreground"
            )}
          />
          <a 
            href="https://huggingface.co/settings/tokens" 
            target="_blank" 
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1 mt-2 text-xs text-primary hover:underline"
          >
            Get your token from Hugging Face
            <ExternalLink className="w-3 h-3" />
          </a>
        </motion.div>

        {/* Advanced Settings Toggle */}
        <motion.button
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.15 }}
          onClick={() => setShowAdvanced(!showAdvanced)}
          className="w-full flex items-center justify-between p-4 bg-card rounded-2xl border border-border mb-4"
        >
          <div className="flex items-center gap-2">
            <Server className="w-4 h-4 text-muted-foreground" />
            <span className="font-semibold text-sm">Advanced Settings</span>
          </div>
          <svg
            className={cn(
              "w-4 h-4 text-muted-foreground transition-transform",
              showAdvanced && "rotate-180"
            )}
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        </motion.button>

        {/* Advanced Settings Content */}
        {showAdvanced && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="bg-card rounded-2xl border border-border p-4 mb-4 space-y-4"
          >
            <div>
              <label className="block text-xs font-medium text-muted-foreground mb-1.5">
                SST Model ID
              </label>
              <input
                type="text"
                value={sstModel}
                onChange={(e) => setSstModel(e.target.value)}
                placeholder="openai/whisper-large-v3"
                className={cn(
                  "w-full px-3 py-2 text-sm rounded-lg",
                  "bg-secondary/50 border border-border",
                  "focus:outline-none focus:ring-2 focus:ring-primary/20"
                )}
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-muted-foreground mb-1.5">
                NMT Model ID
              </label>
              <input
                type="text"
                value={nmtModel}
                onChange={(e) => setNmtModel(e.target.value)}
                placeholder="facebook/nllb-200-distilled-600M"
                className={cn(
                  "w-full px-3 py-2 text-sm rounded-lg",
                  "bg-secondary/50 border border-border",
                  "focus:outline-none focus:ring-2 focus:ring-primary/20"
                )}
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-muted-foreground mb-1.5">
                TTS Model ID
              </label>
              <input
                type="text"
                value={ttsModel}
                onChange={(e) => setTtsModel(e.target.value)}
                placeholder="facebook/mms-tts"
                className={cn(
                  "w-full px-3 py-2 text-sm rounded-lg",
                  "bg-secondary/50 border border-border",
                  "focus:outline-none focus:ring-2 focus:ring-primary/20"
                )}
              />
            </div>

            <div className="pt-2 border-t border-border">
              <div className="flex items-center gap-1 mb-3">
                <Info className="w-3.5 h-3.5 text-muted-foreground" />
                <span className="text-xs text-muted-foreground">Custom Endpoints (optional)</span>
              </div>
              
              <div className="space-y-3">
                <input
                  type="text"
                  value={sstEndpoint}
                  onChange={(e) => setSstEndpoint(e.target.value)}
                  placeholder="SST Endpoint URL"
                  className={cn(
                    "w-full px-3 py-2 text-sm rounded-lg",
                    "bg-secondary/50 border border-border",
                    "focus:outline-none focus:ring-2 focus:ring-primary/20"
                  )}
                />
                <input
                  type="text"
                  value={nmtEndpoint}
                  onChange={(e) => setNmtEndpoint(e.target.value)}
                  placeholder="NMT Endpoint URL"
                  className={cn(
                    "w-full px-3 py-2 text-sm rounded-lg",
                    "bg-secondary/50 border border-border",
                    "focus:outline-none focus:ring-2 focus:ring-primary/20"
                  )}
                />
                <input
                  type="text"
                  value={ttsEndpoint}
                  onChange={(e) => setTtsEndpoint(e.target.value)}
                  placeholder="TTS Endpoint URL"
                  className={cn(
                    "w-full px-3 py-2 text-sm rounded-lg",
                    "bg-secondary/50 border border-border",
                    "focus:outline-none focus:ring-2 focus:ring-primary/20"
                  )}
                />
              </div>
            </div>
          </motion.div>
        )}

        {/* Save Button */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <Button 
            onClick={handleSave}
            className="w-full rounded-xl h-12"
          >
            Save Settings
          </Button>
        </motion.div>

        {/* Clear History */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25 }}
          className="mt-6"
        >
          <div className="bg-card rounded-2xl border border-border p-4">
            <div className="flex items-center justify-between">
              <div>
                <div className="font-semibold text-sm">Translation History</div>
                <div className="text-xs text-muted-foreground">
                  {historyCount} items stored locally
                </div>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={handleClearHistory}
                className="text-destructive hover:text-destructive hover:bg-destructive/10"
              >
                <Trash2 className="w-4 h-4 mr-1" />
                Clear
              </Button>
            </div>
          </div>
        </motion.div>

        {/* Privacy Note */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mt-6"
        >
          <div className="flex items-start gap-3 p-4 rounded-xl bg-secondary/50">
            <Shield className="w-5 h-5 text-primary mt-0.5" />
            <div>
              <div className="font-semibold text-sm mb-1">Privacy First</div>
              <p className="text-xs text-muted-foreground leading-relaxed">
                No account required. No personal data stored on servers. 
                All translation history is kept locally on your device only.
              </p>
            </div>
          </div>
        </motion.div>

        {/* Version */}
        <div className="mt-8 text-center">
          <p className="text-xs text-muted-foreground">
            Global Translator v1.0.0 (MVP)
          </p>
        </div>
      </div>
    </div>
  );
}
