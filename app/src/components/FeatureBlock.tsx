import { motion, useReducedMotion } from 'framer-motion';
import { LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

interface FeatureBlockProps {
  icon: LucideIcon;
  title: string;
  description: string;
  delay?: number;
}

export function FeatureBlock({ icon: Icon, title, description, delay = 0 }: FeatureBlockProps) {
  const reduceMotion = useReducedMotion();

  return (
    <motion.div
      initial={reduceMotion ? { opacity: 0 } : { opacity: 0, y: 20 }}
      animate={reduceMotion ? { opacity: 1 } : { opacity: 1, y: 0 }}
      transition={{ duration: 0.3, delay, ease: [0.23, 1, 0.32, 1] }}
      className="text-center"
    >
      <div className={cn(
        "w-12 h-12 mx-auto mb-3 rounded-full",
        "bg-primary/10 flex items-center justify-center"
      )}>
        <Icon className="w-5 h-5 text-primary" />
      </div>
      <h4 className="font-semibold text-sm mb-1">{title}</h4>
      <p className="text-xs text-muted-foreground leading-relaxed">
        {description}
      </p>
    </motion.div>
  );
}
