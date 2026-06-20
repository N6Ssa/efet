import { initHeroChromeAnim, prepareHeroSvgLayer } from './hero-chrome-anim.js';

function resolveSvgUrl() {
  if (typeof import.meta !== 'undefined' && import.meta.env?.BASE_URL !== undefined) {
    return `${import.meta.env.BASE_URL}graphics/efet-web-elements.svg`;
  }
  return '/public/graphics/efet-web-elements.svg';
}

const SVG_URL = resolveSvgUrl();

let cleanup;

function bootChromeAnim(objectEl) {
  prepareHeroSvgLayer(objectEl);
  cleanup?.();
  cleanup = initHeroChromeAnim(objectEl) ?? undefined;
}

function mountHeroWebElements(mountNode) {
  if (!mountNode) return;

  let objectEl = mountNode.querySelector('.efet-web-elements-fragment__object');

  if (!objectEl) {
    const fragment = document.createElement('div');
    fragment.className = 'efet-web-elements-fragment';
    fragment.setAttribute('aria-hidden', 'true');

    objectEl = document.createElement('object');
    objectEl.className = 'efet-web-elements-fragment__object';
    objectEl.type = 'image/svg+xml';
    objectEl.data = SVG_URL;
    objectEl.tabIndex = -1;
    objectEl.setAttribute('aria-hidden', 'true');

    fragment.appendChild(objectEl);
    mountNode.appendChild(fragment);
  }

  const onLoad = () => bootChromeAnim(objectEl);
  objectEl.addEventListener('load', onLoad);

  if (objectEl.contentDocument?.documentElement) {
    onLoad();
  }
}

mountHeroWebElements(document.getElementById('efet-web-elements-root'));
