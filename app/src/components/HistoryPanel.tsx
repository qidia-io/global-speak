import { motion, AnimatePresence } from 'framer-motion';
import { Clock, Play, Copy, Trash2, Volume2 } from 'lucide-react';
import { HistoryItem, formatTimestamp } from '@/services/storage';
import { getLanguageByCode, isRTL } from '@/config/languages';
import { cn } from '@/lib/utils';

interface HistoryPanelProps {
  items: HistoryItem[];
  onPlay?: (item: HistoryItem) => void;
  onCopy?: (item: HistoryItem) => void;
  onDelete?: (item: HistoryItem) => void;
  isPlaying?: string | null;
  className?: string;
}

export function HistoryPanel({
  items,
  onPlay,
  onCopy,
  onDelete,
  isPlaying,
  className,
}: HistoryPanelProps) {
  if (items.length === 0) {
    return (
      <div className={cn("bg-card rounded-2xl border border-border p-6", className)}>
        <div className="flex items-center gap-2 mb-4">
          <Clock className="w-5 h-5 text-muted-foreground" />
          <h3 className="font-semibold">Translation History</h3>
        </div>
        <div className="text-center py-8">
          <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-secondary flex items-center justify-center">
            <Clock className="w-8 h-8 text-muted-foreground" />
          </div>
          <p className="text-sm text-muted-foreground">
            No translations yet.
            <br />
            Start translating to see your history here.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className={cn("bg-card rounded-2xl border border-border overflow-hidden", className)}>
      <div className="flex items-center gap-2 p-4 border-b border-border">
        <Clock className="w-5 h-5 text-muted-foreground" />
        <h3 className="font-semibold flex-1">Translation History</h3>
        <span className="text-xs text-muted-foreground bg-secondary px-2 py-1 rounded-full">
          {items.length}
        </span>
      </div>

      <div className="max-h-96 overflow-y-auto scrollbar-hide">
        <AnimatePresence>
          {items.map((item, index) => {
            const fromLang = getLanguageByCode(item.fromLang);
            const toLang = getLanguageByCode(item.toLang);
            const isTargetRTL = isRTL(item.toLang);

            return (
              <motion.div
                key={item.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                transition={{ delay: index * 0.05 }}
                className="p-4 border-b border-border last:border-b-0 hover:bg-secondary/30 transition-colors"
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <span>{fromLang?.flag}</span>
                    <span>→</span>
                    <span>{toLang?.flag}</span>
                    <span className="ml-1">{formatTimestamp(item.timestamp)}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    {onPlay && item.ttsAudioRef && (
                      <button
                        onClick={() => onPlay(item)}
                        className={cn(
                          "p-1.5 rounded-lg hover:bg-secondary transition-colors",
                          isPlaying === item.id && "text-primary animate-pulse"
                        )}
                        aria-label="Play audio"
                      >
                        {isPlaying === item.id ? (
                          <Volume2 className="w-4 h-4" />
                        ) : (
                          <Play className="w-4 h-4" />
                        )}
                      </button>
                    )}
                    {onCopy && (
                      <button
                        onClick={() => onCopy(item)}
                        className="p-1.5 rounded-lg hover:bg-secondary transition-colors"
                        aria-label="Copy translation"
                      >
                        <Copy className="w-4 h-4" />
                      </button>
                    )}
                    {onDelete && (
                      <button
                        onClick={() => onDelete(item)}
                        className="p-1.5 rounded-lg hover:bg-destructive/10 hover:text-destructive transition-colors"
                        aria-label="Delete"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    )}
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="text-sm text-muted-foreground bg-secondary/50 rounded-lg px-3 py-2">
                    {item.sourceText}
                  </div>
                  <div 
                    className={cn(
                      "text-sm font-medium bg-primary/10 text-primary rounded-lg px-3 py-2",
                      isTargetRTL && "rtl"
                    )}
                  >
                    {item.translatedText}
                  </div>
                </div>
              </motion.div>
            );
          })}
        </AnimatePresence>
      </div>
    </div>
  );
}
