import { readFileSync, writeFileSync } from 'node:fs';

const base = process.env.VITE_BASE_PATH || '/';
if (base === '/') {
  process.exit(0);
}

const normalizedBase = base.endsWith('/') ? base.slice(0, -1) : base;
const file = 'dist/index.html';
let html = readFileSync(file, 'utf8');

html = html.replace(
  /(\s(?:src|href)=["'])\/(?!efet\/)(assets\/)/g,
  `$1${normalizedBase}/$2`
);

html = html.replace(
  /(\s(?:src|href)=["'])\/(?!efet\/)(graphics\/)/g,
  `$1${normalizedBase}/$2`
);

writeFileSync(file, html);
