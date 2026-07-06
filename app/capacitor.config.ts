import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.lovable.de6d6f0f1812429997c77cebc13536aa',
  appName: 'Global Translator',
  webDir: 'dist',
  server: {
    url: 'https://de6d6f0f-1812-4299-97c7-7cebc13536aa.lovableproject.com?forceHideBadge=true',
    cleartext: true,
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      launchAutoHide: true,
      backgroundColor: '#3B82F6',
      showSpinner: false,
    },
  },
  ios: {
    contentInset: 'automatic',
  },
  android: {
    backgroundColor: '#F8FAFC',
  },
};

export default config;
