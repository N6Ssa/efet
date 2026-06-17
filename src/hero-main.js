import { createElement } from 'react';
import { createRoot } from 'react-dom/client';
import { EfetWebElementsFragment } from './components/EfetWebElementsFragment.js';

const mountNode = document.getElementById('efet-web-elements-root');

if (mountNode) {
  createRoot(mountNode).render(createElement(EfetWebElementsFragment));
}
