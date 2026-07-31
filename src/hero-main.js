import { initHeroChromeAnim, prepareHeroSvgLayer } from './hero-chrome-anim.js';

function resolveSvgUrl() {
  if (typeof import.meta !== 'undefined' && import.meta.env?.BASE_URL !== undefined) {
    return `${import.meta.env.BASE_URL}graphics/efet-web-elements.svg`;
  }
  return '/public/graphics/efet-web-elements.svg';
}

const SVG_URL = resolveSvgUrl();
const METAL_ASSETS = [
  ['cone', 'cone'],
  ['sphere', 'sphere'],
  ['cube', 'cube'],
  ['blob', 'blob'],
  ['torus', 'torus'],
  ['wave', 'wave'],
];

let cleanup;

function resolveMetalAssetUrl(name) {
  if (typeof import.meta !== 'undefined' && import.meta.env?.BASE_URL !== undefined) {
    return `${import.meta.env.BASE_URL}assets/metal-${name}.png`;
  }
  return `/assets/metal-${name}.png`;
}

function mountMetalAssets(mountNode) {
  const chromeStage = mountNode.closest('.hero-chrome-stage') ?? mountNode;
  if (chromeStage.querySelector('.hero-metal-layer')) return;

  const layer = document.createElement('div');
  layer.className = 'hero-metal-layer';
  layer.setAttribute('aria-hidden', 'true');

  METAL_ASSETS.forEach(([name, className]) => {
    const image = document.createElement('img');
    image.className = `hero-metal hero-metal-${className}`;
    image.src = resolveMetalAssetUrl(name);
    image.alt = '';
    layer.appendChild(image);
  });

  chromeStage.appendChild(layer);
}

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

  mountMetalAssets(mountNode);

  const onLoad = () => bootChromeAnim(objectEl);
  objectEl.addEventListener('load', onLoad);

  if (objectEl.contentDocument?.documentElement) {
    onLoad();
  }
}

mountHeroWebElements(document.getElementById('efet-web-elements-root'));
