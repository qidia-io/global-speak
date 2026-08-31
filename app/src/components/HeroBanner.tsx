import { motion, useReducedMotion } from 'framer-motion';
import { Globe, Mic, MessageSquare } from 'lucide-react';
import { cn } from '@/lib/utils';

interface HeroBannerProps {
  className?: string;
}

export function HeroBanner({ className }: HeroBannerProps) {
  const reduceMotion = useReducedMotion();

  const features = [
    {
      icon: Globe,
      title: '25+ Languages',
      subtitle: 'Focus on developing countries',
    },
    {
      icon: Mic,
      title: 'Voice Conversation',
      subtitle: 'Speak & listen naturally',
    },
    {
      icon: MessageSquare,
      title: 'Simultaneous Pairs',
      subtitle: 'Multiple translations at once',
    },
  ];

  return (
    <motion.div
      initial={reduceMotion ? { opacity: 0 } : { opacity: 0, y: 20 }}
      animate={reduceMotion ? { opacity: 1 } : { opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: [0.23, 1, 0.32, 1] }}
      className={cn(
        "relative overflow-hidden rounded-2xl bg-gradient-hero p-6 text-white",
        className
      )}
    >
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -right-20 -top-20 w-60 h-60 bg-white/10 rounded-full blur-3xl" />
        <div className="absolute -left-10 -bottom-10 w-40 h-40 bg-white/5 rounded-full blur-2xl" />
      </div>

      <div className="relative z-10">
        <h2 className="text-xl font-bold text-center mb-6">
          Connect the World Through Language
        </h2>

        <div className="grid grid-cols-3 gap-3">
          {features.map((feature, index) => (
            <motion.div
              key={feature.title}
              initial={reduceMotion ? { opacity: 0 } : { opacity: 0, y: 10 }}
              animate={reduceMotion ? { opacity: 1 } : { opacity: 1, y: 0 }}
              transition={{ delay: 0.15 + index * 0.08, duration: 0.3, ease: [0.23, 1, 0.32, 1] }}
              className="text-center"
            >
              <div className="w-10 h-10 mx-auto mb-2 rounded-xl bg-white/20 flex items-center justify-center">
                <feature.icon className="w-5 h-5" />
              </div>
              <div className="text-xs font-semibold mb-0.5">
                {feature.title}
              </div>
              <div className="text-[10px] text-white/70 leading-tight">
                {feature.subtitle}
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </motion.div>
  );
}
