import { useEffect, useState } from 'react';

/**
 * True only when the primary input supports hover (mouse/trackpad).
 * Gates hover-only effects behind `(hover: hover) and (pointer: fine)`
 * so touch devices don't trigger hover states on tap.
 * (Doctrina emil-design: "Hover solo con @media (hover:hover) and (pointer:fine)")
 */
export function useCanHover() {
  const [canHover, setCanHover] = useState(false);

  useEffect(() => {
    const mql = window.matchMedia('(hover: hover) and (pointer: fine)');
    const onChange = () => setCanHover(mql.matches);
    setCanHover(mql.matches);
    mql.addEventListener('change', onChange);
    return () => mql.removeEventListener('change', onChange);
  }, []);

  return canHover;
}
