import { motion } from 'framer-motion';
import { Mic, MessageSquare } from 'lucide-react';
import { cn } from '@/lib/utils';
import { getLanguageByCode } from '@/config/languages';

interface VoiceTileProps {
  langCode: string;
  isActive?: boolean;
  isRecording?: boolean;
  variant: 'from' | 'to';
  onClick?: () => void;
  disabled?: boolean;
}

export function VoiceTile({
  langCode,
  isActive,
  isRecording,
  variant,
  onClick,
  disabled,
}: VoiceTileProps) {
  const lang = getLanguageByCode(langCode);
  const isFrom = variant === 'from';

  return (
    <motion.button
      whileHover={{ scale: disabled ? 1 : 1.02 }}
      whileTap={{ scale: disabled ? 1 : 0.98 }}
      onClick={onClick}
      disabled={disabled}
      className={cn(
        "relative overflow-hidden rounded-2xl p-5 w-full text-left transition-all",
        "flex flex-col items-center justify-center min-h-[140px]",
        isFrom
          ? "bg-gradient-voice text-white"
          : "bg-success/10 border-2 border-success/20 text-foreground",
        isRecording && isFrom && "ring-4 ring-white/30",
        disabled && "opacity-50 cursor-not-allowed"
      )}
    >
      {/* Background decoration */}
      {isFrom && (
        <div className="absolute inset-0 overflow-hidden">
          <div className="absolute -right-6 -top-6 w-20 h-20 bg-white/10 rounded-full blur-xl" />
        </div>
      )}

      <div className="relative z-10 text-center">
        <div className="text-3xl mb-2">{lang?.flag}</div>
        <div className={cn(
          "font-semibold mb-1",
          isFrom ? "text-white" : "text-foreground"
        )}>
          {lang?.name}
        </div>
        <div className={cn(
          "flex items-center gap-1.5 text-xs",
          isFrom ? "text-white/70" : "text-muted-foreground"
        )}>
          <Mic className="w-3.5 h-3.5" />
          <span>Tap to speak</span>
        </div>
      </div>

      {/* Recording indicator */}
      {isRecording && (
        <div className="absolute top-3 right-3">
          <span className="flex h-3 w-3">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75" />
            <span className="relative inline-flex rounded-full h-3 w-3 bg-white" />
          </span>
        </div>
      )}
    </motion.button>
  );
}
