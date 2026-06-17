import { cpSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const base = process.env.VITE_BASE_PATH || '/';
const normalizedBase = base === '/' ? '' : (base.endsWith('/') ? base.slice(0, -1) : base);

const distDir = join(root, 'dist');
const indexPath = join(root, 'index.html');
const distIndexPath = join(distDir, 'index.html');

mkdirSync(distDir, { recursive: true });

let html = readFileSync(indexPath, 'utf8');

html = html.replaceAll("class='tn-atom'field=", "class='tn-atom' field=");

html = html.replace(
  /<img class='tn-atom__img t-img' data-original='([^']*)'\s*\n\s*src='([^']*)'\s*\n\s*alt='' imgfield='([^']*)'\s*\n\s*\/>/g,
  "<img class='tn-atom__img t-img' data-original='$1' src='$2' alt='' imgfield='$3' />"
);

const cssHref = `${normalizedBase}/assets/custom-top.css`;
const jsSrc = `${normalizedBase}/assets/hero.js`;

html = html.replace(
  /<link rel="stylesheet" href="\/src\/custom-top\.css"\s*\/>/,
  `<link rel="stylesheet" href="${cssHref}" />`
);

html = html.replace(
  /<script type="module" src="\/src\/hero-main\.js"><\/script>/,
  `<script type="module" src="${jsSrc}"></script>`
);

writeFileSync(distIndexPath, html);

if (existsSync(join(root, 'public'))) {
  cpSync(join(root, 'public'), distDir, { recursive: true });
}
