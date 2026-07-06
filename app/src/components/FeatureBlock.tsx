import { motion } from 'framer-motion';
import { LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

interface FeatureBlockProps {
  icon: LucideIcon;
  title: string;
  description: string;
  delay?: number;
}

export function FeatureBlock({ icon: Icon, title, description, delay = 0 }: FeatureBlockProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, delay }}
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
