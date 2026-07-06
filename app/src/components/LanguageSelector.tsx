import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, Search, ArrowLeftRight } from 'lucide-react';
import { languages, Language, getLanguageByCode } from '@/config/languages';
import { cn } from '@/lib/utils';

interface LanguageSelectorProps {
  value: string;
  onChange: (code: string) => void;
  label?: string;
  excludeCode?: string;
}

export function LanguageSelector({ 
  value, 
  onChange, 
  label,
  excludeCode 
}: LanguageSelectorProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [search, setSearch] = useState('');

  const selectedLanguage = getLanguageByCode(value);

  const filteredLanguages = useMemo(() => {
    return languages.filter(lang => {
      if (excludeCode && lang.code === excludeCode) return false;
      if (!search) return true;
      const searchLower = search.toLowerCase();
      return (
        lang.name.toLowerCase().includes(searchLower) ||
        lang.nativeName.toLowerCase().includes(searchLower) ||
        lang.code.toLowerCase().includes(searchLower)
      );
    });
  }, [search, excludeCode]);

  const handleSelect = (lang: Language) => {
    onChange(lang.code);
    setIsOpen(false);
    setSearch('');
  };

  return (
    <div className="relative">
      {label && (
        <label className="block text-xs font-medium text-muted-foreground mb-1.5">
          {label}
        </label>
      )}
      
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={cn(
          "flex items-center gap-2 px-4 py-3 rounded-xl bg-card border border-border",
          "hover:bg-secondary/50 transition-colors w-full min-w-[140px]",
          "focus:outline-none focus:ring-2 focus:ring-primary/20"
        )}
      >
        <span className="text-xl">{selectedLanguage?.flag}</span>
        <span className="flex-1 text-left font-medium text-sm">
          {selectedLanguage?.name}
        </span>
        <ChevronDown 
          className={cn(
            "w-4 h-4 text-muted-foreground transition-transform",
            isOpen && "rotate-180"
          )} 
        />
      </button>

      <AnimatePresence>
        {isOpen && (
          <>
            <div 
              className="fixed inset-0 z-40" 
              onClick={() => {
                setIsOpen(false);
                setSearch('');
              }} 
            />
            <motion.div
              initial={{ opacity: 0, y: -10, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -10, scale: 0.95 }}
              transition={{ duration: 0.15 }}
              className={cn(
                "absolute top-full left-0 right-0 mt-2 z-50",
                "bg-card border border-border rounded-xl shadow-lg overflow-hidden"
              )}
            >
              <div className="p-2 border-b border-border">
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <input
                    type="text"
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    placeholder="Search languages..."
                    className={cn(
                      "w-full pl-9 pr-4 py-2 text-sm rounded-lg",
                      "bg-secondary/50 border-0 focus:outline-none focus:ring-2 focus:ring-primary/20",
                      "placeholder:text-muted-foreground"
                    )}
                    autoFocus
                  />
                </div>
              </div>
              
              <div className="max-h-64 overflow-y-auto scrollbar-hide">
                {filteredLanguages.length === 0 ? (
                  <div className="px-4 py-6 text-center text-sm text-muted-foreground">
                    No languages found
                  </div>
                ) : (
                  filteredLanguages.map((lang) => (
                    <button
                      key={lang.code}
                      onClick={() => handleSelect(lang)}
                      className={cn(
                        "w-full flex items-center gap-3 px-4 py-3 text-left",
                        "hover:bg-secondary/50 transition-colors",
                        value === lang.code && "bg-primary/10"
                      )}
                    >
                      <span className="text-xl">{lang.flag}</span>
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-sm">{lang.name}</div>
                        <div className="text-xs text-muted-foreground truncate">
                          {lang.nativeName}
                        </div>
                      </div>
                      {lang.rtl && (
                        <span className="text-xs bg-secondary px-2 py-0.5 rounded">
                          RTL
                        </span>
                      )}
                    </button>
                  ))
                )}
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}

interface LanguagePairSelectorProps {
  fromLang: string;
  toLang: string;
  onFromChange: (code: string) => void;
  onToChange: (code: string) => void;
  onSwap?: () => void;
}

export function LanguagePairSelector({
  fromLang,
  toLang,
  onFromChange,
  onToChange,
  onSwap,
}: LanguagePairSelectorProps) {
  const handleSwap = () => {
    if (onSwap) {
      onSwap();
    } else {
      const temp = fromLang;
      onFromChange(toLang);
      onToChange(temp);
    }
  };

  return (
    <div className="flex items-end gap-2">
      <div className="flex-1">
        <LanguageSelector
          value={fromLang}
          onChange={onFromChange}
          label="From"
          excludeCode={toLang}
        />
      </div>
      
      <button
        onClick={handleSwap}
        className={cn(
          "flex-shrink-0 p-3 rounded-xl bg-card border border-border",
          "hover:bg-secondary/50 transition-colors",
          "focus:outline-none focus:ring-2 focus:ring-primary/20"
        )}
        aria-label="Swap languages"
      >
        <ArrowLeftRight className="w-5 h-5 text-muted-foreground" />
      </button>
      
      <div className="flex-1">
        <LanguageSelector
          value={toLang}
          onChange={onToChange}
          label="To"
          excludeCode={fromLang}
        />
      </div>
    </div>
  );
}
