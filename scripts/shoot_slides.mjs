// shoot_slides.mjs — renders scenes/sceneN.html to frames/sceneN.png via Playwright
import { mkdirSync } from "node:fs";
import { cwd } from "node:process";
import { chromium } from "playwright";

const count = Number(process.argv[2] ?? 4);
mkdirSync("frames", { recursive: true });
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
for (let i = 1; i <= count; i++) {
  const url = `file://${cwd().replace(/\\/g, "/")}/scenes/scene${i}.html`;
  await page.goto(url);
  await page.waitForTimeout(150);
  await page.screenshot({ path: `frames/scene${i}.png` });
  console.log("shot", i);
}
await browser.close();
