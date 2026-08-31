// Model Router — config-driven routing for NMT.
// Nueva lengua = 1-2 líneas en MODEL_ROUTES, sin tocar translateText().
// El comodín '*' atrapa todo lo no mapeado (fallback a NLLB-200).

export interface RouteConfig {
  model: string;
  type: 'byt5' | 'nllb';
}

export const MODEL_ROUTES: Record<string, RouteConfig> = {
  'es-wo': { model: 'sainzpaa/byt5-nmt-wolof-v1', type: 'byt5' },
  'wo-es': { model: 'sainzpaa/byt5-nmt-wolof-v1', type: 'byt5' },
  // futuros: 'es-bm', 'bm-es', 'es-ff', 'ff-es' → byt5
  '*': { model: 'facebook/nllb-200-distilled-600M', type: 'nllb' },
};

export function getRoute(src: string, tgt: string): RouteConfig {
  return MODEL_ROUTES[`${src}-${tgt}`] ?? MODEL_ROUTES['*'];
}
