import { createElement, useEffect, useRef } from 'react';
import { initHeroChromeAnim } from '../hero-chrome-anim.js';

/** Original Illustrator artboard — do not change. */
export const EFET_WEB_VIEWBOX = Object.freeze({
  width: 488.04,
  height: 288.69,
});

const SVG_URL = `${import.meta.env.BASE_URL}graphics/efet-web-elements.svg`;

function bootChromeAnim(objectEl, cleanupRef) {
  if (!objectEl) return;
  cleanupRef.current?.();
  cleanupRef.current = initHeroChromeAnim(objectEl) ?? undefined;
}

/**
 * Renders the original EFET web-elements SVG (viewBox 0 0 488.04 288.69)
 * without modifying paths, colors, gradients, masks, or clipPaths.
 * The file in public/graphics/ is the single source of truth.
 */
export function EfetWebElementsFragment({ className = '' }) {
  const objectRef = useRef(null);
  const cleanupRef = useRef(null);

  useEffect(() => {
    const objectEl = objectRef.current;
    if (!objectEl) return undefined;

    const onLoad = () => bootChromeAnim(objectEl, cleanupRef);

    if (objectEl.contentDocument?.documentElement) onLoad();
    else objectEl.addEventListener('load', onLoad);

    return () => {
      objectEl.removeEventListener('load', onLoad);
      cleanupRef.current?.();
      cleanupRef.current = undefined;
    };
  }, []);

  return createElement(
    'div',
    {
      className: ['efet-web-elements-fragment', className].filter(Boolean).join(' '),
      'aria-hidden': true,
    },
    createElement('object', {
      ref: objectRef,
      className: 'efet-web-elements-fragment__object',
      type: 'image/svg+xml',
      data: SVG_URL,
      tabIndex: -1,
      'aria-hidden': true,
      onLoad: (event) => bootChromeAnim(event.currentTarget, cleanupRef),
    })
  );
}
