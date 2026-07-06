import { useState } from 'react';
import { motion } from 'framer-motion';
import { Mic, Square, Loader2 } from 'lucide-react';
import { cn } from '@/lib/utils';

interface RecordButtonProps {
  isRecording: boolean;
  isProcessing: boolean;
  onStart: () => void;
  onStop: () => void;
  disabled?: boolean;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function RecordButton({
  isRecording,
  isProcessing,
  onStart,
  onStop,
  disabled,
  size = 'lg',
  className,
}: RecordButtonProps) {
  const sizeClasses = {
    sm: 'w-14 h-14',
    md: 'w-18 h-18',
    lg: 'w-24 h-24',
  };

  const iconSizes = {
    sm: 'w-6 h-6',
    md: 'w-8 h-8',
    lg: 'w-10 h-10',
  };

  const handleClick = () => {
    if (disabled || isProcessing) return;
    if (isRecording) {
      onStop();
    } else {
      onStart();
    }
  };

  return (
    <motion.button
      whileHover={{ scale: disabled ? 1 : 1.05 }}
      whileTap={{ scale: disabled ? 1 : 0.95 }}
      onClick={handleClick}
      disabled={disabled || isProcessing}
      className={cn(
        "relative rounded-full flex items-center justify-center transition-all",
        sizeClasses[size],
        isRecording
          ? "bg-destructive text-destructive-foreground"
          : "bg-primary text-primary-foreground",
        disabled && "opacity-50 cursor-not-allowed",
        !disabled && !isProcessing && "shadow-button-primary",
        className
      )}
    >
      {/* Pulse animation when recording */}
      {isRecording && (
        <>
          <span className="absolute inset-0 rounded-full bg-destructive animate-ping opacity-30" />
          <span className="absolute inset-0 rounded-full bg-destructive animate-pulse opacity-50" />
        </>
      )}

      <span className="relative z-10">
        {isProcessing ? (
          <Loader2 className={cn(iconSizes[size], "animate-spin")} />
        ) : isRecording ? (
          <Square className={iconSizes[size]} />
        ) : (
          <Mic className={iconSizes[size]} />
        )}
      </span>
    </motion.button>
  );
}
