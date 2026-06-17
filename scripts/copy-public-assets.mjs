import { cpSync, existsSync, rmSync } from 'node:fs';

const dest = 'public/assets';

if (existsSync(dest)) {
  rmSync(dest, { recursive: true, force: true });
}

cpSync('assets', dest, { recursive: true });
