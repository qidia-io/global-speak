# DESIGN_GUIDE.md — Doctrina de diseño y movimiento (global-speak)

> **Referencia del equipo.** Fuente: skill `emil-design` (doctrina de Emil Kowalski —
> animations.dev, vaul, sonner, shadcn/ui — licencia MIT) + principios de interacción Apple.
> Cualquier componente, pantalla o animación de la app pasa por esta guía antes de darse por bueno.
> Repo fuente: https://github.com/emilkowalski/skills

---

## 1. El framework de decisión (en orden)

Antes de animar algo, responder las 5 preguntas. Si falla la 1 o la 2, **no se construye**.

### 1.1 ¿Con qué frecuencia se ve? → ¿Debe animar?

| Frecuencia | Decisión |
|---|---|
| 100+/día (tabs, teclado, comandos) | **Nunca animar.** Cero. |
| Decenas/día (hover, navegación de listas) | Eliminar o reducir drásticamente |
| Ocasional (modales, drawers, toasts) | Animación estándar |
| Raro / primera vez (onboarding, éxito, celebración) | Aquí vive el presupuesto de delight |

**Regla de oro: los tabs nunca hacen slide.** Son pares, no jerarquía. `animation: none`.

### 1.2 ¿Cuál es el propósito? (nombrarlo en una palabra)

`feedback` · `spatial consistency` · `state indication` · `preventing a jarring change` · `explanation` · `delight`
Si no puedes nombrarlo: **no lo construyas**.

### 1.3 ¿Qué easing?

| Uso | Curva |
|---|---|
| Entrar/salir (aparecer/desaparecer) | `--ease-out: cubic-bezier(0.23, 1, 0.32, 1)` |
| Moverse/morfear en pantalla | `--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1)` |
| Hover / cambio de color | `ease` (default) |
| Movimiento constante (progress, marquee) | `linear` |
| Drawers / sheets (iOS-like) | `--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1)` |

**Prohibido:** `ease-in` en UI (retrasa el momento más observado). Las easings built-in de CSS son demasiado débiles → usar las curvas custom.

### 1.4 ¿Qué duración?

| Elemento | Duración |
|---|---|
| Feedback de botón (press) | 100–160ms |
| Tooltips, popovers pequeños | 125–200ms |
| Dropdowns, selects | 150–250ms |
| Modales, drawers | 200–500ms |
| **Tope duro en UI** | **< 300ms** |

### 1.5 Springs (solo si el dedo participa)

- **Dedo involucrado → spring** (mantiene velocidad al interrumpirse; las curvas reinician).
- Framer Motion (2 params): `{ type: "spring", duration: 0.5, bounce: 0.2 }` (bounce 0.1–0.3, sutil).
- Física: `{ type: "spring", mass: 1, stiffness: 100, damping: 10 }`.
- Default UI: **critically damped** (sin overshoot). Bounce solo si el gesto llevaba momentum (flick).
- **Siempre animar desde el valor on-screen actual**, nunca el target (interruptibilidad).
- Velocity handoff al soltar: continuar a la velocidad del dedo. Flick rápido (`dist/ms > 0.11`) → dismiss aunque no pase el umbral.
- Rubber-banding en bordes, nunca hard stops: `rubberband(overshoot, dim, 0.55)`.

---

## 2. Tokens de movimiento (Tailwind)

```css
/* app/src/index.css (o tailwind.config) */
:root {
  --ease-out:     cubic-bezier(0.23, 1, 0.32, 1);
  --ease-in-out:  cubic-bezier(0.77, 0, 0.175, 1);
  --ease-drawer:  cubic-bezier(0.32, 0.72, 0, 1);

  --duration-press:    120ms;   /* botones */
  --duration-popover:  150ms;   /* tooltips, popovers, dropdowns */
  --duration-panel:    250ms;   /* modales, drawers, sheets */
  --duration-delight:  500ms;   /* onboarding, éxito (raro) */
}
```

Uso: `transition: transform var(--duration-press) var(--ease-out);`
Nunca duraciones >300ms en UI de uso frecuente.

---

## 3. Reglas de craft (no negociables)

### 3.1 Botones y elementos interactivos
- Feedback en **pointer-down** (`:active`), no en release: `:active { transform: scale(0.97) }` + `transition: transform 160ms ease-out`.
- Escala sutil 0.95–0.98. Nunca animar `scale(0)` — nada aparece de la nada: empezar desde `scale(0.9–0.97)` + `opacity: 0`.

### 3.2 Popovers y dropdowns
- `transform-origin: var(--transform-origin)` (el trigger), **NO center**. **Excepción: modales** → center.

### 3.3 Transiciones, no keyframes
- UI dinámica (toasts, toggles) → **CSS transitions** (interrumpibles, re-targetable). Los keyframes reinician de cero.

### 3.4 Entradas
- Preferir `@starting-style` (CSS) sobre el patrón `useEffect` + mounted.
- Crossfades bruscos: `filter: blur(2px)` enmascara la transición (nunca >20px, caro en Safari).
- `translateY(100%)` con porcentajes (relativo al propio tamaño) para drawers/toasts — nunca píxeles hardcodeados.

### 3.5 Stagger
- 30–80ms entre items, decorativo, **nunca bloquear interacción**.

### 3.6 Hold-to-delete
- Overlay `clip-path: inset(0 100% 0 0)`: mantener 2s `linear`, soltar 200ms `ease-out`.
- Entrar lento donde el usuario decide; salir rápido donde el sistema responde.

### 3.7 Sonner (toasts — ya instalado)
- Transiciones, no keyframes. Easing/duración acordes a la personalidad de la app.
- Pausar timers con pestaña oculta, gaps entre toasts apilados, pointer capture en drag — edge cases invisibles.

---

## 4. Rendimiento (reglas duras)

- **Solo `transform` y `opacity`** en GPU. `width/height/margin/padding/top/left` → layout pass por frame.
  - Excepción: elemento absolutamente posicionado sin hijos (pill de tabs, fill de progress).
- **Framer Motion**: `x`/`y`/`scale` shorthand **NO son** hardware-accelerated (rAF en main thread).
  Bajo carga: `transform: "translateX(...)"` completo o CSS. `transition: all` → propiedades exactas.
- CSS animations > JS bajo carga (off-main-thread). CSS para lo predeterminado; JS/springs solo para lo dinámico/interrumpible.
- Nunca animar `BlurView` intensity (Android re-renderiza el blur). Crossfade de un BlurView estático.
- No actualizar CSS variables del padre para mover hijos (recalc storm) — transform directo en el elemento.

---

## 5. Accesibilidad

- `@media (prefers-reduced-motion: reduce)` → crossfades cortos de opacity, SIN movimiento (no "sin feedback").
- `@media (prefers-reduced-transparency: reduce)` → superficies sólidas sin blur.
- Hover gateado: `@media (hover: hover) and (pointer: fine)` — los touch disparan hover al tocar.
- Vibrancy: sobre translúcidos, texto con más contraste + peso + letter-spacing.
- Tipografía: tracking negativo en display (`-0.02em`), ~0 en body; leading inverso (tight en grande, holgado en body).

---

## 6. Anti-patrones (checklist de review)

| ❌ Anti-patrón | ✅ Correcto | Por qué |
|---|---|---|
| `transition: all` | `transition: transform 200ms ease-out` | `all` anima fuera de GPU |
| `scale(0)` o fade puro sin transform | `scale(0.95)` + `opacity: 0` | Nada aparece de la nada |
| `ease-in` en UI | `ease-out` / curva custom | Retrasa el momento más observado |
| Popover con `transform-origin: center` | Origin del trigger | Crecen desde donde salen (modales exentos) |
| Animación en teclado / acción 100+/día | Ninguna | Frecuencia alta = cero animación |
| Duración > 300ms en UI frecuente | 150–250ms | La UI debe sentirse inmediata |
| Hover sin media query | `@media (hover: hover) and (pointer: fine)` | Touch dispara hover al tocar |
| Keyframes en elemento disparado rápido | Transición CSS | Keyframes reinician de cero |
| Todo aparece a la vez | Stagger 30–80ms | Cascada natural |
| Framer `x`/`y` bajo carga | `transform: "translateX()"` | Hardware acceleration |
| Entrar y salir a la misma velocidad | Salida más rápida (ej. 500ms/200ms) | El sistema responde, el usuario decide |
| Animación en `:hover` sin `:active` en botones | Press feedback en pointer-down | Los botones responden al presionar |

---

## 7. Formato de review obligatorio

Toda revisión de UI usa la tabla **| Before | After | Why |** (una fila por issue) y termina con veredicto **Approve / Block**:

| Before | After | Why |
|---|---|---|
| `transition-all duration-300` en ModeCard | `transition: transform 200ms var(--ease-out)` | Especificar propiedades; `all` anima layout |
| `whileTap` sin `whileHover` gateado | `whileHover={{ scale: 1.02 }}` + touch: none | Hover solo con pointer fino |

---

## 8. Cómo usar esta guía

1. **Al construir** un componente → cargar skill `emil-design` + esta guía; seguir secciones 1–5.
2. **Antes de un PR de UI** → correr la checklist de la sección 6 sobre el diff.
3. **En review** → formato sección 7.
4. **Al auditar** la app → skill `emil-design` referencias `find-animation-opportunities.md` (qué animar) y `review-animations.md` (estándares estrictos + veredicto).

## 9. Estado de adopción

- [x] **SW.3.4 (#170)** — tokens de movimiento en Tailwind (sección 2) — `ease-out-expo`, `ease-in-out-expo`, `ease-drawer` en `tailwind.config.ts` (31-ago-2026, mbok)
- [x] **SW.3.4 (#170)** — anti-patrones eliminados de componentes custom (checklist sección 6) — 8/9 componentes corregidos; sin `transition-all`, sin `ease-in`, sin `scale(0)` (31-ago-2026, mbok + review Nemrod)
- [x] **SW.3.4 (#170)** — press feedback universal en elementos interactivos — `active:scale-95` + `transition-[transform,...] duration-150` (31-ago-2026)
- [x] **SW.3.4 (#170)** — reduced-motion respetado en toda la app — `useReducedMotion()` en 6 componentes (31-ago-2026)
- [ ] **SW.3.4 (#170)** — Sonner configurado a medida (posición, tema, timing) — pendiente
- [x] **SW.3.4 (#170)** — review completo de componentes custom con formato Before/After/Why — Approve (31-ago-2026, Nemrod)

*Actualizado: 31-ago-2026 · Nemrod (arquitectura) · fuente: skill `emil-design` (MIT) + Apple HIG*
