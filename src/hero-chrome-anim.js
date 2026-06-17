/**
 * Wave float + pointer drag for chrome SVG mesh groups (inside <object>).
 */
export function initHeroChromeAnim(object) {
  const hero = document.querySelector('.hero');
  const doc = object?.contentDocument;
  if (!hero || !doc?.documentElement) return undefined;

  const svg = doc.documentElement;
  const groups = [...doc.querySelectorAll('.chrome-mesh')];
  if (!groups.length) return undefined;

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

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
  }));

  let rafId = 0;
  let activeItem = null;
  let dragStartX = 0;
  let dragStartY = 0;
  let dragOriginX = 0;
  let dragOriginY = 0;
  let hoverItem = null;

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

    items.forEach((item) => {
      const box = item.el.getBoundingClientRect();
      const pad = 14;
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
    if (event.button !== 0) return;

    const item = pickItem(event.clientX, event.clientY);
    if (!item) return;

    activeItem = item;
    dragStartX = event.clientX;
    dragStartY = event.clientY;
    dragOriginX = item.dragPxX;
    dragOriginY = item.dragPxY;

    setHeroCursor('grabbing');
    hero.classList.add('hero--chrome-drag');
    event.preventDefault();
  };

  const onPointerMove = (event) => {
    if (activeItem) {
      activeItem.dragPxX = dragOriginX + (event.clientX - dragStartX);
      activeItem.dragPxY = dragOriginY + (event.clientY - dragStartY);
      return;
    }

    const item = pickItem(event.clientX, event.clientY);
    hoverItem = item;
    setHeroCursor(item ? 'grab' : 'default');
  };

  const onPointerUp = () => {
    activeItem = null;
    hero.classList.remove('hero--chrome-drag');
    setHeroCursor(hoverItem ? 'grab' : 'default');
  };

  hero.addEventListener('pointerdown', onPointerDown);
  window.addEventListener('pointermove', onPointerMove);
  window.addEventListener('pointerup', onPointerUp);
  window.addEventListener('pointercancel', onPointerUp);

  const tick = (time) => {
    const { sx, sy } = getScale();

    items.forEach((item) => {
      const waveX = reducedMotion
        ? 0
        : Math.sin(time * 0.001 * item.freq + item.phase) * item.ampX;
      const waveY = reducedMotion
        ? 0
        : Math.cos(time * 0.001 * item.freq * 0.88 + item.phase * 1.05) * item.ampY;

      const tx = waveX + item.dragPxX * sx;
      const ty = waveY + item.dragPxY * sy;
      item.el.setAttribute('transform', `translate(${tx.toFixed(3)} ${ty.toFixed(3)})`);
    });

    rafId = requestAnimationFrame(tick);
  };

  rafId = requestAnimationFrame(tick);

  return () => {
    cancelAnimationFrame(rafId);
    hero.removeEventListener('pointerdown', onPointerDown);
    window.removeEventListener('pointermove', onPointerMove);
    window.removeEventListener('pointerup', onPointerUp);
    window.removeEventListener('pointercancel', onPointerUp);
    hero.style.cursor = '';
    hero.classList.remove('hero--chrome-drag');
    items.forEach((item) => item.el.removeAttribute('transform'));
  };
}
