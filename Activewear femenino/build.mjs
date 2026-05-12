import { cpSync, existsSync, mkdirSync, rmSync } from "node:fs";
import { join } from "node:path";

const outDir = "public";
const files = ["index.html", "styles.css", "script.js"];

if (existsSync(outDir)) {
  rmSync(outDir, { recursive: true, force: true });
}

mkdirSync(outDir);

for (const file of files) {
  cpSync(file, join(outDir, file));
}

cpSync("assets", join(outDir, "assets"), { recursive: true });
