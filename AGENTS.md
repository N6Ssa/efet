# Repository Guidelines

## Project Structure & Module Organization

This repository is a Vite-powered, static reproduction of the EFET Studio site.

- `index.html` is the primary Tilda-exported page. Keep its existing block IDs (for example, `rec1921353361`) and inline styles intact unless the change requires them.
- `src/` contains the maintained hero enhancement: `hero-main.js` is the entry point, `hero-chrome-anim.js` controls SVG animation, and `custom-top.css` contains scoped overrides.
- `public/graphics/` contains assets served unchanged during development and copied into builds. `assets/` holds source/reference visuals; `tilda/` contains archived Tilda-specific experiments.
- `scripts/` assembles the final page and patches paths for GitHub Pages. Treat `dist/` and `public/assets/` as generated output.

## Build, Test, and Development Commands

- `npm install` installs the Node dependencies used by Vite.
- `npm run dev` copies public assets and starts Vite at `http://127.0.0.1:5173`.
- `npm run build` creates the deployable `dist/` directory, assembles `index.html`, and fixes GitHub Pages paths.
- `npm run preview` serves the latest production build for a local smoke test.
- On Windows, `start.bat` or `powershell -ExecutionPolicy Bypass -File dev_server.ps1` starts the legacy live-reload server.

There is no automated test suite. Before opening a PR, run `npm run build`, then use `npm run preview` to verify the hero, responsive layout, and asset paths.

## Coding Style & Naming Conventions

Use two-space indentation in JavaScript, CSS, and JSON. Keep modern JavaScript modules in `src/` with descriptive kebab-case filenames such as `hero-chrome-anim.js`. Use `const` by default, guard DOM lookups, and retain the existing semicolon style. Prefer narrowly scoped CSS selectors under the relevant hero/root class; do not reformat the large Tilda export for unrelated edits.

## Commit & Pull Request Guidelines

Recent commits use short, imperative, sentence-style subjects, often naming the affected area: `Fix mobile hero SVG clip and tighten mobile layout`. Keep commits focused and avoid generated files. PRs should describe the visual or behavioral change, link the relevant issue when available, include desktop and mobile screenshots for UI changes, and confirm that `npm run build` succeeds. The `main` branch deploys to GitHub Pages through `.github/workflows/deploy-pages.yml`.
