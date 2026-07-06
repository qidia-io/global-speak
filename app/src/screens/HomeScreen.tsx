import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { Mic, Type, MessageCircle, Globe, MessageSquare } from 'lucide-react';
import { ModeCard } from '@/components/ModeCard';
import { FeatureBlock } from '@/components/FeatureBlock';

export default function HomeScreen() {
  const navigate = useNavigate();

  const features = [
    {
      icon: MessageCircle,
      title: 'Real-time Conversation',
      description: 'Have natural conversations across language barriers',
    },
    {
      icon: Globe,
      title: 'Global Reach',
      description: 'Focus on languages from developing countries worldwide',
    },
    {
      icon: MessageSquare,
      title: 'Speech Bubbles',
      description: 'Chat-style interface with audio playback',
    },
  ];

  return (
    <div className="min-h-screen px-5 py-8">
      <div className="max-w-lg mx-auto">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex justify-center mb-6"
        >
          <span className="inline-flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-primary/10 text-primary text-xs font-medium">
            <Globe className="w-3.5 h-3.5" />
            25+ Languages Supported
          </span>
        </motion.div>

        {/* Main Title */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="text-center mb-8"
        >
          <h1 className="text-4xl font-bold text-foreground mb-3">
            Voice Translation
          </h1>
          <p className="text-muted-foreground text-base leading-relaxed max-w-xs mx-auto">
            Break language barriers with real-time voice and text translation focusing on developing countries
          </p>
        </motion.div>

        {/* Mode Cards */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="grid grid-cols-2 gap-4 mb-10"
        >
          <ModeCard
            icon={Mic}
            title="Voice Mode"
            description="Speak naturally and get instant translations"
            variant="primary"
            onClick={() => navigate('/voice')}
          />
          <ModeCard
            icon={Type}
            title="Text Mode"
            description="Type or paste text for translation"
            variant="secondary"
            onClick={() => navigate('/text')}
          />
        </motion.div>

        {/* Feature Blocks */}
        <div className="grid grid-cols-3 gap-4">
          {features.map((feature, index) => (
            <FeatureBlock
              key={feature.title}
              icon={feature.icon}
              title={feature.title}
              description={feature.description}
              delay={0.3 + index * 0.1}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
