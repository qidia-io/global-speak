import { motion } from 'framer-motion';
import { LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

interface ModeCardProps {
  icon: LucideIcon;
  title: string;
  description: string;
  variant: 'primary' | 'secondary';
  onClick: () => void;
  className?: string;
}

export function ModeCard({
  icon: Icon,
  title,
  description,
  variant,
  onClick,
  className,
}: ModeCardProps) {
  const isPrimary = variant === 'primary';

  return (
    <motion.button
      whileHover={{ scale: 1.02, y: -2 }}
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      className={cn(
        "relative overflow-hidden rounded-2xl p-6 text-left w-full",
        "transition-all duration-300",
        isPrimary
          ? "bg-gradient-voice text-white shadow-button-primary"
          : "bg-card border border-border text-foreground shadow-card hover:shadow-card-hover",
        className
      )}
    >
      {/* Background decoration for primary */}
      {isPrimary && (
        <div className="absolute inset-0 overflow-hidden">
          <div className="absolute -right-10 -top-10 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
        </div>
      )}

      <div className="relative z-10">
        <div
          className={cn(
            "w-12 h-12 rounded-xl flex items-center justify-center mb-4",
            isPrimary ? "bg-white/20" : "bg-primary/10"
          )}
        >
          <Icon
            className={cn(
              "w-6 h-6",
              isPrimary ? "text-white" : "text-primary"
            )}
          />
        </div>

        <h3
          className={cn(
            "text-lg font-bold mb-1",
            isPrimary ? "text-white" : "text-foreground"
          )}
        >
          {title}
        </h3>

        <p
          className={cn(
            "text-sm leading-relaxed",
            isPrimary ? "text-white/80" : "text-muted-foreground"
          )}
        >
          {description}
        </p>

        <div
          className={cn(
            "mt-4 inline-flex items-center gap-1 text-sm font-medium",
            isPrimary ? "text-white/90" : "text-primary"
          )}
        >
          Get started
          <svg
            className="w-4 h-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M9 5l7 7-7 7"
            />
          </svg>
        </div>
      </div>
    </motion.button>
  );
}
