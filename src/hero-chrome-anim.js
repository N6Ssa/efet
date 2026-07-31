/**
 * Wave float, pointer flee, and drag for hero metal PNGs.
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

  doc.querySelectorAll('.chrome-mesh').forEach((group) => {
    group.setAttribute('visibility', 'hidden');
    group.setAttribute('data-hero-hidden', 'true');
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
  if (!hero) return undefined;

  prepareHeroSvgLayer(object);

  const metalAssets = [...hero.querySelectorAll('.hero-metal')];
  if (!metalAssets.length) return undefined;

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const isCoarsePointer = window.matchMedia('(max-width: 959px), (pointer: coarse)').matches;
  const isMobileLayout = window.matchMedia('(max-width: 959px)').matches;
  const mobileScale = isMobileLayout ? 1.43 : 1;

  const items = metalAssets.map((el, index) => ({
    el,
    fallDistance: 50 + index * 5,
    dragPxX: 0,
    dragPxY: 0,
    fleePxX: 0,
    fleePxY: 0,
  }));

  const fleeEnabled = !isCoarsePointer && !reducedMotion;
  const FLEE_RADIUS = 260;
  const MAX_FLEE = 110;
  const FLEE_FOLLOW = 0.065;
  const FLEE_RETURN = 0.035;
  const POINTER_FOLLOW = 0.085;

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
  let smoothPointerX = null;
  let smoothPointerY = null;
  let pointerInside = false;
  let previousFrameTime = 0;

  const eventTarget = hero;

  items.forEach((item) => {
    item.el.style.willChange = 'transform';
  });

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
    smoothPointerX = null;
    smoothPointerY = null;
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

  const updateFlee = (time) => {
    const elapsed = previousFrameTime ? Math.min(time - previousFrameTime, 32) : 16.67;
    const frameScale = elapsed / 16.67;
    previousFrameTime = time;
    const canFlee = fleeEnabled
      && !activeItem
      && pointerInside
      && pointerX !== null
      && pointerY !== null;

    if (canFlee) {
      if (smoothPointerX === null || smoothPointerY === null) {
        smoothPointerX = pointerX;
        smoothPointerY = pointerY;
      } else {
        const pointerLerp = 1 - Math.pow(1 - POINTER_FOLLOW, frameScale);
        smoothPointerX += (pointerX - smoothPointerX) * pointerLerp;
        smoothPointerY += (pointerY - smoothPointerY) * pointerLerp;
      }
    }

    items.forEach((item) => {
      let targetX = 0;
      let targetY = 0;

      if (canFlee && smoothPointerX !== null && smoothPointerY !== null) {
        const box = item.el.getBoundingClientRect();
        const cx = box.left + box.width / 2 - item.fleePxX;
        const cy = box.top + box.height / 2 - item.fleePxY;
        const dx = cx - smoothPointerX;
        const dy = cy - smoothPointerY;
        const dist = Math.hypot(dx, dy);

        if (dist > 0 && dist < FLEE_RADIUS) {
          const t = 1 - dist / FLEE_RADIUS;
          const ease = t * t * (3 - 2 * t);
          const mag = MAX_FLEE * ease;
          const softenedDistance = Math.max(dist, 32);
          targetX = (dx / softenedDistance) * mag;
          targetY = (dy / softenedDistance) * mag;
        }
      }

      const follow = canFlee ? FLEE_FOLLOW : FLEE_RETURN;
      const positionLerp = 1 - Math.pow(1 - follow, frameScale);
      item.fleePxX += (targetX - item.fleePxX) * positionLerp;
      item.fleePxY += (targetY - item.fleePxY) * positionLerp;

      if (!canFlee && Math.abs(item.fleePxX) < 0.01) {
        item.fleePxX = 0;
      }
      if (!canFlee && Math.abs(item.fleePxY) < 0.01) {
        item.fleePxY = 0;
      }
    });
  };

  const tick = (time) => {
    updateFlee(time);

    items.forEach((item) => {
      const waveTime = time * 0.0009;
      const waveX = 0;
      const waveY = reducedMotion
        ? 0
        : ((1 - Math.cos(waveTime)) / 2) * item.fallDistance;

      const tx = waveX + item.dragPxX + item.fleePxX;
      const ty = waveY + item.dragPxY + item.fleePxY;
      item.el.style.transform = `translate3d(${tx.toFixed(3)}px, ${ty.toFixed(3)}px, 0) scale(${mobileScale})`;
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
    items.forEach((item) => {
      item.el.style.transform = '';
      item.el.style.willChange = '';
    });
  };
}
