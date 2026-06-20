/**
 * Wave float + pointer drag for chrome SVG mesh groups (inside <object>).
 */

const HERO_GLOW_COLOR = '#ec6ea3';
const HERO_GLOW_CX = '120';
const HERO_GLOW_CY = '178';
const HERO_GLOW_R = '120';
const HERO_GLOW_STOPS = [
  ['0%', '0.95'],
  ['34%', '0.5'],
  ['66%', '0'],
];

export function prepareHeroSvgLayer(object) {
  const doc = object?.contentDocument;
  if (!doc?.documentElement) return;

  const svg = doc.documentElement;
  const svgNS = 'http://www.w3.org/2000/svg';

  doc.querySelectorAll('rect.st110').forEach((rect) => {
    rect.setAttribute('visibility', 'hidden');
  });

  doc.querySelector('rect.st304')?.setAttribute('fill', 'none');

  const existingCircle = svg.querySelector('#hero-pink-glow-circle');
  if (existingCircle) {
    existingCircle.setAttribute('cx', HERO_GLOW_CX);
    existingCircle.setAttribute('cy', HERO_GLOW_CY);
    existingCircle.setAttribute('r', HERO_GLOW_R);
    svg.querySelectorAll('#heroPinkGlowGrad stop').forEach((stop, index) => {
      stop.setAttribute('stop-color', HERO_GLOW_COLOR);
      if (HERO_GLOW_STOPS[index]) {
        stop.setAttribute('offset', HERO_GLOW_STOPS[index][0]);
        stop.setAttribute('stop-opacity', HERO_GLOW_STOPS[index][1]);
      }
    });
    return;
  }

  let defs = svg.querySelector('defs');
  if (!defs) {
    defs = doc.createElementNS(svgNS, 'defs');
    svg.insertBefore(defs, svg.firstChild);
  }

  const filter = doc.createElementNS(svgNS, 'filter');
  filter.setAttribute('id', 'heroPinkGlowBlur');
  filter.setAttribute('x', '-40%');
  filter.setAttribute('y', '-40%');
  filter.setAttribute('width', '180%');
  filter.setAttribute('height', '180%');
  const blur = doc.createElementNS(svgNS, 'feGaussianBlur');
  blur.setAttribute('in', 'SourceGraphic');
  blur.setAttribute('stdDeviation', '10');
  filter.appendChild(blur);
  defs.appendChild(filter);

  const grad = doc.createElementNS(svgNS, 'radialGradient');
  grad.setAttribute('id', 'heroPinkGlowGrad');
  grad.setAttribute('cx', '50%');
  grad.setAttribute('cy', '50%');
  grad.setAttribute('r', '50%');
  HERO_GLOW_STOPS.forEach(([offset, opacity]) => {
    const stop = doc.createElementNS(svgNS, 'stop');
    stop.setAttribute('offset', offset);
    stop.setAttribute('stop-color', HERO_GLOW_COLOR);
    stop.setAttribute('stop-opacity', opacity);
    grad.appendChild(stop);
  });
  defs.appendChild(grad);

  const circle = doc.createElementNS(svgNS, 'circle');
  circle.setAttribute('id', 'hero-pink-glow-circle');
  circle.setAttribute('cx', HERO_GLOW_CX);
  circle.setAttribute('cy', HERO_GLOW_CY);
  circle.setAttribute('r', HERO_GLOW_R);
  circle.setAttribute('fill', 'url(#heroPinkGlowGrad)');
  circle.setAttribute('filter', 'url(#heroPinkGlowBlur)');

  const bgRect = doc.querySelector('rect.st304');
  if (bgRect?.nextSibling) {
    svg.insertBefore(circle, bgRect.nextSibling);
  } else {
    svg.insertBefore(circle, svg.firstChild);
  }
}

export function initHeroChromeAnim(object) {
  const hero = document.querySelector('.hero');
  const doc = object?.contentDocument;
  if (!hero || !doc?.documentElement) return undefined;

  prepareHeroSvgLayer(object);

  const svg = doc.documentElement;
  const groups = [...doc.querySelectorAll('.chrome-mesh')];
  if (!groups.length) return undefined;

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const isCoarsePointer = window.matchMedia('(max-width: 959px), (pointer: coarse)').matches;

  const style = doc.createElementNS('http://www.w3.org/2000/svg', 'style');
  style.textContent = '.chrome-mesh { transform-box: fill-box; transform-origin: center; cursor: grab; }';
  svg.insertBefore(style, svg.firstChild);

  const items = groups.map((el, index) => ({
    el,
    phase: index * 1.35,
    freq: 0.62 + index * 0.07,
    ampX: 1.6 + (index % 3) * 0.35,
    ampY: 2.2 + (index % 2) * 0.45,
    dragPxX: 0,
    dragPxY: 0,
    fleePxX: 0,
    fleePxY: 0,
  }));

  const fleeEnabled = !isCoarsePointer && !reducedMotion;
  const FLEE_RADIUS = 112;
  const MAX_FLEE = 34;
  const FLEE_LERP = 0.072;
  const FLEE_RETURN = 0.048;

  let rafId = 0;
  let activeItem = null;
  let dragStartX = 0;
  let dragStartY = 0;
  let dragOriginX = 0;
  let dragOriginY = 0;
  let hoverItem = null;
  let activePointerId = null;
  let pointerX = null;
  let pointerY = null;
  let pointerInside = false;

  const eventTarget = hero;

  const getScale = () => {
    const rect = svg.getBoundingClientRect();
    const viewBox = svg.viewBox.baseVal;
    return {
      sx: viewBox.width / (rect.width || 1),
      sy: viewBox.height / (rect.height || 1),
    };
  };

  const pickItem = (clientX, clientY) => {
    let best = null;
    let bestDist = Infinity;
    const pad = isCoarsePointer ? 28 : 14;

    items.forEach((item) => {
      const box = item.el.getBoundingClientRect();
      if (
        clientX < box.left - pad ||
        clientX > box.right + pad ||
        clientY < box.top - pad ||
        clientY > box.bottom + pad
      ) {
        return;
      }

      const cx = box.left + box.width / 2;
      const cy = box.top + box.height / 2;
      const dist = Math.hypot(clientX - cx, clientY - cy);
      if (dist < bestDist) {
        bestDist = dist;
        best = item;
      }
    });

    return best;
  };

  const setHeroCursor = (cursor) => {
    hero.style.cursor = cursor;
  };

  const onPointerDown = (event) => {
    if (event.pointerType === 'mouse' && event.button !== 0) return;

    const item = pickItem(event.clientX, event.clientY);
    if (!item) return;

    activeItem = item;
    activePointerId = event.pointerId;
    dragStartX = event.clientX;
    dragStartY = event.clientY;
    dragOriginX = item.dragPxX;
    dragOriginY = item.dragPxY;

    setHeroCursor('grabbing');
    hero.classList.add('hero--chrome-drag');
    eventTarget.setPointerCapture?.(event.pointerId);
    event.preventDefault();
  };

  const trackPointer = (event) => {
    if (fleeEnabled && event.pointerType === 'mouse') {
      pointerX = event.clientX;
      pointerY = event.clientY;
      pointerInside = true;
    }
  };

  const onPointerMove = (event) => {
    trackPointer(event);

    if (activeItem) {
      if (activePointerId !== null && event.pointerId !== activePointerId) return;
      activeItem.dragPxX = dragOriginX + (event.clientX - dragStartX);
      activeItem.dragPxY = dragOriginY + (event.clientY - dragStartY);
      event.preventDefault();
      return;
    }

    const item = pickItem(event.clientX, event.clientY);
    hoverItem = item;
    setHeroCursor(item ? 'grab' : 'default');
  };

  const onPointerLeave = () => {
    pointerInside = false;
    pointerX = null;
    pointerY = null;
  };

  const endDrag = (event) => {
    if (activePointerId !== null && event?.pointerId !== undefined && event.pointerId !== activePointerId) {
      return;
    }
    activeItem = null;
    activePointerId = null;
    hero.classList.remove('hero--chrome-drag');
    setHeroCursor(hoverItem ? 'grab' : 'default');
  };

  const pointerOptions = { passive: false };

  eventTarget.addEventListener('pointerdown', onPointerDown, pointerOptions);
  eventTarget.addEventListener('pointermove', onPointerMove, pointerOptions);
  eventTarget.addEventListener('pointerup', endDrag);
  eventTarget.addEventListener('pointercancel', endDrag);
  eventTarget.addEventListener('pointerleave', onPointerLeave);

  const updateFlee = () => {
    if (!fleeEnabled || activeItem) {
      items.forEach((item) => {
        item.fleePxX += (0 - item.fleePxX) * FLEE_RETURN;
        item.fleePxY += (0 - item.fleePxY) * FLEE_RETURN;
      });
      return;
    }

    const canFlee = pointerInside && pointerX !== null && pointerY !== null;

    items.forEach((item) => {
      let targetX = 0;
      let targetY = 0;

      if (canFlee) {
        const box = item.el.getBoundingClientRect();
        const cx = box.left + box.width / 2;
        const cy = box.top + box.height / 2;
        const dx = cx - pointerX;
        const dy = cy - pointerY;
        const dist = Math.hypot(dx, dy);

        if (dist > 0 && dist < FLEE_RADIUS) {
          const t = 1 - dist / FLEE_RADIUS;
          const ease = t * t * (3 - 2 * t);
          const mag = MAX_FLEE * ease;
          targetX = (dx / dist) * mag;
          targetY = (dy / dist) * mag;
        }
      }

      const lerp = canFlee ? FLEE_LERP : FLEE_RETURN;
      item.fleePxX += (targetX - item.fleePxX) * lerp;
      item.fleePxY += (targetY - item.fleePxY) * lerp;
    });
  };

  const tick = (time) => {
    const { sx, sy } = getScale();
    updateFlee();

    items.forEach((item) => {
      const waveX = reducedMotion
        ? 0
        : Math.sin(time * 0.001 * item.freq + item.phase) * item.ampX;
      const waveY = reducedMotion
        ? 0
        : Math.cos(time * 0.001 * item.freq * 0.88 + item.phase * 1.05) * item.ampY;

      const tx = waveX + (item.dragPxX + item.fleePxX) * sx;
      const ty = waveY + (item.dragPxY + item.fleePxY) * sy;
      item.el.setAttribute('transform', `translate(${tx.toFixed(3)} ${ty.toFixed(3)})`);
    });

    rafId = requestAnimationFrame(tick);
  };

  rafId = requestAnimationFrame(tick);

  return () => {
    cancelAnimationFrame(rafId);
    eventTarget.removeEventListener('pointerdown', onPointerDown, pointerOptions);
    eventTarget.removeEventListener('pointermove', onPointerMove, pointerOptions);
    eventTarget.removeEventListener('pointerup', endDrag);
    eventTarget.removeEventListener('pointercancel', endDrag);
    eventTarget.removeEventListener('pointerleave', onPointerLeave);
    hero.style.cursor = '';
    hero.classList.remove('hero--chrome-drag');
    items.forEach((item) => item.el.removeAttribute('transform'));
  };
}
