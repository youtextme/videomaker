// make_slides.mjs — generates scene HTML files for the explainer video
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(fileURLToPath(import.meta.url));
const outDir = join(root, "scenes");
mkdirSync(outDir, { recursive: true });

// Edit scenes[] to change the story: id, variant (see skylines), accent hex,
// kicker, title, sub, caption (on-screen subtitle), narration (spoken text).
const scenes = [
  {
    id: 1, variant: "tower", accent: "#D9A441", kicker: "SEOUL · MIND SERIES",
    title: "The Voice Inside",
    sub: "How language shapes your mind",
    caption: "There is a voice inside your head. It talks to you all day — and it quietly builds your world.",
    narration: "There's a voice inside your head. It talks to you all day long — and neuroscience says that voice is quietly building the world you live in.",
  },
  {
    id: 2, variant: "palace", accent: "#C73E3A", kicker: "SCENE 01 · INNER SPEECH",
    title: "It's real neural speech",
    sub: "Broca's area lights up when you talk to yourself",
    caption: "Inner speech isn't a metaphor — brain scans show it uses the same machinery as speaking out loud.",
    narration: "That inner voice isn't a metaphor. Brain scans show silent self-talk lights up Broca's area — the very same machinery you use for real speech.",
  },
  {
    id: 3, variant: "hanok", accent: "#2F6D80", kicker: "SCENE 02 · AFFECT LABELING",
    title: "Name a feeling, tame it",
    sub: "UCLA 2007 · Lieberman et al.",
    caption: "Putting fear into words calms the amygdala — your brain's alarm bell.",
    narration: "Name a feeling and you tame it. In UCLA scans, simply putting fear into words calmed the amygdala — the brain's alarm bell.",
  },
  {
    id: 4, variant: "river", accent: "#4A7C59", kicker: "SCENE 03 · DISTANCED SELF-TALK",
    title: "Coach yourself by name",
    sub: "Kross et al., 2014",
    caption: "\u201CYou've prepared for this.\u201D Tiny pronoun shifts cut anxiety almost effortlessly.",
    narration: "Under pressure, coach yourself in second person: 'You've prepared for this.' That tiny pronoun shift measurably cuts anxiety, almost for free.",
  },
  {
    id: 5, variant: "notebook", accent: "#7B5EA7", kicker: "SCENE 04 · EXPRESSIVE WRITING",
    title: "Write it down to shelve it",
    sub: "Pennebaker paradigm · 146-study meta-analysis",
    caption: "Fifteen honest minutes of writing turns chaos into cause-and-effect structure.",
    narration: "Or write it down. Fifteen minutes of honest writing about hard days improves health, immunity, even grades.",
  },
  {
    id: 6, variant: "sunrise", accent: "#E07A3F", kicker: "SCENE 05 · THE MORNING WINDOW",
    title: "Mornings tune the whole day",
    sub: "Cortisol awakening response · first 45 minutes",
    caption: "Your alarm system is touchy after waking — so your first sentence acts like a tuning fork.",
    narration: "Mornings matter most. Right after waking, a cortisol surge leaves your alarm system touchy — so your first sentence tunes the whole day.",
  },
  {
    id: 7, variant: "checklist", accent: "#B23A48", kicker: "THE PLAYBOOK",
    title: "Four moves that work",
    sub: "Label precisely · Create distance · Write weekly · Ask, don't command",
    caption: "Precise labels. Friendly distance. Weekly writing. Questions over commands.",
    narration: "So four moves: label feelings precisely. Talk to yourself like a friend. Write weekly. Ask questions instead of commands.",
  },
  {
    id: 8, variant: "tower", accent: "#2E4057", kicker: "SEOUL · NIGHT VIEW",
    title: "Speak kindly inward",
    sub: "Language is the highest-bandwidth interface with your own mind",
    caption: "The listener inside is listening. Hand it a better script.",
    narration: "Language is the highest-bandwidth interface you have with your own mind. Speak to yourself like a friend — because the listener inside is always listening.",
  },
];

const skylines = {
  tower: `
  <g fill="#0B1220" opacity="0.9">
    <rect x="0" y="820" width="1920" height="260"/>
    <rect x="120" y="700" width="90" height="130"/><rect x="240" y="660" width="70" height="170"/>
    <rect x="1500" y="680" width="80" height="150"/><rect x="1620" y="720" width="110" height="110"/>
    <rect x="330" y="750" width="120" height="80"/><rect x="1380" y="760" width="100" height="70"/>
  </g>
  <g transform="translate(930,430)">
    <path d="M0 -160 L14 -40 L-14 -40 Z" fill="#1E2A3A"/>
    <path d="M-34 -40 L34 -40 L26 0 L-26 0 Z" fill="#15202E"/>
    <path d="M0 -190 L6 -160 L-6 -160 Z" fill="#1E2A3A"/>
    <circle cx="0" cy="-52" r="10" fill="#D9A441" opacity="0.95"/>
    <line x1="0" y1="-190" x2="0" y2="-230" stroke="#15202E" stroke-width="4"/>
    <ellipse cx="0" cy="20" rx="90" ry="16" fill="#0B1220"/>
  </g>`,
  palace: `
  <g transform="translate(960,560)">
    <rect x="-420" y="60" width="840" height="220" fill="#101B2A"/>
    <path d="M-360 60 Q-300 -40 -240 60 L-200 60 Q-140 -60 -80 60 L-40 60 Q0 -90 40 60 L80 60 Q140 -60 200 60 L240 60 Q300 -40 360 60 Z" fill="#13233A"/>
    <rect x="-70" y="120" width="140" height="160" fill="#0B1420"/>
    <rect x="-460" y="50" width="920" height="18" fill="#0B1420"/>
    <g fill="#C73E3A" opacity="0.85">
      <rect x="-380" y="86" width="24" height="8"/><rect x="-320" y="86" width="24" height="8"/>
      <rect x="356" y="86" width="24" height="8"/><rect x="296" y="86" width="24" height="8"/>
      <rect x="-24" y="86" width="48" height="8"/>
    </g>
  </g>
  <g fill="#0B1220"><rect x="0" y="840" width="1920" height="240"/></g>
  <g fill="#D9A441" opacity="0.7">
    <circle cx="180" cy="900" r="26"/><circle cx="1740" cy="920" r="22"/><circle cx="120" cy="1000" r="18"/>
  </g>`,
  hanok: `
  <g transform="translate(0,600)">
    <path d="M60 160 Q210 20 360 160 L360 240 L60 240 Z" fill="#101B2A"/>
    <path d="M400 180 Q550 40 700 180 L700 260 L400 260 Z" fill="#0E1826"/>
    <path d="M760 150 Q930 0 1100 150 L1100 250 L760 250 Z" fill="#121F31"/>
    <path d="M1160 180 Q1310 40 1460 180 L1460 260 L1160 260 Z" fill="#0E1826"/>
    <path d="M1500 150 Q1670 10 1840 150 L1840 240 L1500 240 Z" fill="#101B2A"/>
    <g stroke="#D9A441" stroke-width="6" opacity="0.55">
      <line x1="150" y1="140" x2="270" y2="140"/><line x1="500" y1="160" x2="620" y2="160"/>
      <line x1="860" y1="130" x2="1000" y2="130"/><line x1="1260" y1="160" x2="1380" y2="160"/><line x1="1610" y1="130" x2="1750" y2="130"/>
    </g>
    <rect x="0" y="230" width="1920" height="130" fill="#0B1220"/>
  </g>
  <g fill="#D9A441" opacity="0.75">
    <circle cx="960" cy="330" r="70" opacity="0.25"/><circle cx="960" cy="330" r="46" opacity="0.5"/>
  </g>`,
  river: `
  <g fill="#0B1220"><rect x="0" y="700" width="1920" height="60"/></g>
  <g>
    <rect x="0" y="760" width="1920" height="320" fill="#0D1B2E"/>
    <path d="M0 800 H1920" stroke="#1B3A5C" stroke-width="4"/>
    <path d="M0 880 H1920" stroke="#16304C" stroke-width="4"/>
    <path d="M0 960 H1920" stroke="#1B3A5C" stroke-width="4"/>
    <g stroke="#274B72" stroke-width="10">
      <line x1="300" y1="764" x2="300" y2="1020"/><line x1="700" y1="764" x2="700" y2="1020"/>
      <line x1="1100" y1="764" x2="1100" y2="1020"/><line x1="1500" y1="764" x2="1500" y2="1020"/>
    </g>
    <path d="M0 768 H1920" stroke="#3A6B99" stroke-width="12"/>
  </g>
  <g fill="#101B2A">
    <rect x="140" y="560" width="80" height="145"/><rect x="260" y="600" width="64" height="105"/>
    <rect x="1580" y="580" width="90" height="125"/><rect x="1720" y="620" width="70" height="85"/>
  </g>
  <g fill="#D9A441" opacity="0.5">
    <rect x="156" y="580" width="8" height="8"/><rect x="176" y="600" width="8" height="8"/>
    <rect x="1596" y="600" width="8" height="8"/><rect x="1616" y="620" width="8" height="8"/>
  </g>`,
  sunrise: `
  <defs><linearGradient id="sun" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#F2B36B"/><stop offset="1" stop-color="#E07A3F"/>
  </linearGradient></defs>
  <circle cx="960" cy="640" r="180" fill="#E8944F" opacity="0.28"/>
  <circle cx="960" cy="640" r="120" fill="#EDAE63"/>
  <g fill="#0B1220" opacity="0.92">
    <path d="M0 720 L1920 720 L1920 1080 L0 1080 Z"/>
    <rect x="200" y="600" width="70" height="130"/><rect x="1660" y="590" width="80" height="140"/>
  </g>
  <g stroke="#0B1220" stroke-width="14" opacity="0.9">
    <path d="M0 760 Q480 700 960 760 T1920 760"/>
  </g>`,
};

function mascotSVG(accent) {
  return `
  <svg class="mascot" viewBox="0 0 220 260" aria-hidden="true">
    <!-- friendly local guide character (original, not based on any real person) -->
    <ellipse cx="110" cy="246" rx="66" ry="10" fill="rgba(0,0,0,0.35)"/>
    <path d="M62 246 C62 196 84 178 110 178 C136 178 158 196 158 246 Z" fill="#2F6D80"/>
    <path d="M96 186 L110 206 L124 186 Z" fill="#F7F3E9"/>
    <circle cx="110" cy="112" r="58" fill="#F2C9A0"/>
    <path d="M52 104 C56 54 164 54 168 104 C150 88 70 88 52 104 Z" fill="#2A2A2A"/>
    <path d="M46 106 C44 84 66 78 74 92 C60 94 52 98 46 106 Z" fill="#2A2A2A"/>
    <path d="M174 106 C176 84 154 78 146 92 C160 94 168 98 174 106 Z" fill="#2A2A2A"/>
    <rect x="42" y="98" width="136" height="16" rx="8" fill="#1F1F1F"/>
    <circle cx="110" cy="46" r="14" fill="${accent}"/>
    <circle cx="88" cy="116" r="7" fill="#222"/>
    <circle cx="132" cy="116" r="7" fill="#222"/>
    <circle cx="90.5" cy="113.5" r="2.4" fill="#fff"/>
    <circle cx="134.5" cy="113.5" r="2.4" fill="#fff"/>
    <path d="M86 138 Q110 158 134 138" stroke="#7A4A32" stroke-width="5" fill="none" stroke-linecap="round"/>
    <circle cx="72" cy="134" r="9" fill="#E88C7D" opacity="0.55"/>
    <circle cx="148" cy="134" r="9" fill="#E88C7D" opacity="0.55"/>
    <!-- headset mic -->
    <path d="M52 108 C52 148 76 168 96 170" stroke="#111" stroke-width="5" fill="none"/>
    <circle cx="99" cy="171" r="7" fill="#111"/>
    <circle cx="167" cy="118" r="8" fill="#111"/>
  </svg>`;
}

function html(s) {
  const skyline = skylines[s.variant] ?? "";
  return `<!doctype html>
<html><head><meta charset="utf-8">
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  html,body { width:1920px; height:1080px; overflow:hidden; }
  body { font-family:'Malgun Gothic','Segoe UI',Georgia,serif; background:#0E1626; color:#F7F3E9; position:relative; }
  .sky { position:absolute; inset:0;
    background:
      radial-gradient(1200px 600px at 50% 30%, #1B2C47 0%, #0E1626 70%),
      linear-gradient(#0C1424, #101C30);
  }
  .stars { position:absolute; inset:0; }
  svg.skyline { position:absolute; inset:0; width:1920px; height:1080px; }
  .kicker { position:absolute; top:56px; left:80px; font-size:26px; letter-spacing:6px; color:${s.accent}; font-weight:700; text-transform:uppercase;}
  .loc { position:absolute; top:52px; right:80px; font-size:24px; letter-spacing:3px; color:#8FA3BF; }
  h1 { position:absolute; top:150px; left:80px; right:520px; font-size:96px; line-height:1.08; color:#F7F3E9;
       text-shadow:0 4px 30px rgba(0,0,0,.6); font-weight:800; }
  h1 em { color:${s.accent}; font-style:normal; }
  .subwrap { position:absolute; top:392px; left:80px; max-width:1150px; font-size:40px; color:#B8C7DD; line-height:1.35; }
  .captionbar { position:absolute; left:0; right:0; bottom:0; height:170px; background:rgba(6,10,18,0.82);
    border-top:3px solid ${s.accent}; display:flex; align-items:center; justify-content:center; padding:0 340px; }
  .caption { font-size:40px; line-height:1.3; text-align:center; color:#EDF2F9; font-weight:600; }
  .mascot { position:absolute; left:64px; bottom:120px; width:230px; filter:drop-shadow(0 10px 24px rgba(0,0,0,.5)); z-index:5; }
  .badge { position:absolute; right:80px; bottom:200px; background:rgba(217,164,65,0.14); border:2px solid ${s.accent};
    color:#F0D9A8; font-size:24px; padding:14px 22px; border-radius:999px; letter-spacing:2px; z-index:4;}
</style></head>
<body>
  <div class="sky"></div>
  ${stars()}
  <svg class="skyline" viewBox="0 0 1920 1080" preserveAspectRatio="xMidYMax slice">${skyline}</svg>
  <div class="kicker">${s.kicker}</div>
  <div class="loc">📍 SEOUL · SOUTH KOREA</div>
  <h1>${s.title}</h1>
  <div class="subwrap">${s.sub}</div>
  <div class="badge">한국어 안내 OK · Local guide</div>
  ${mascotSVG(s.accent)}
  <div class="captionbar"><div class="caption">${s.caption}</div></div>
</body></html>`;
}

function stars() {
  let out = '<svg class="stars" width="1920" height="1080">';
  let seed = 7;
  const rnd = () => { seed = (seed * 16807) % 2147483647; return seed / 2147483647; };
  for (let i = 0; i < 90; i++) {
    const x = Math.floor(rnd() * 1920), y = Math.floor(rnd() * 560);
    const r = rnd() * 1.6 + 0.4, o = rnd() * 0.6 + 0.15;
    out += `<circle cx="${x}" cy="${y}" r="${r.toFixed(2)}" fill="#CFE0F4" opacity="${o.toFixed(2)}"/>`;
  }
  return out + "</svg>";
}

for (const s of scenes) {
  writeFileSync(join(outDir, `scene${s.id}.html`), html(s));
}
writeFileSync(join(root, "script.json"), JSON.stringify(scenes.map(({ id, narration }) => ({ id, narration })), null, 2));
console.log("Wrote", scenes.length, "scene HTML files + script.json");
