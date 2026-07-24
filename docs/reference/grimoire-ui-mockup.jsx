import { useState, useEffect, useRef } from "react";

// ============================================================
// PIXEL ART UI, Project Grimoire
// Dark fantasy medieval palette, hard edges, dithered depth
// ============================================================

const C = {
  bg:         "#0a0806",
  panel:      "#12100c",
  panelMid:   "#1a1610",
  panelLight: "#221e16",
  border:     "#2e2416",
  borderGold: "#5a3e10",
  gold:       "#c8922a",
  goldLight:  "#e8b44a",
  goldDim:    "#6b4f18",
  green:      "#2a5224",
  greenLight: "#3d7a35",
  greenDim:   "#1a3018",
  bone:       "#c8b99a",
  boneDim:    "#7a6e58",
  boneFaint:  "#3a3428",
  red:        "#7a1c1c",
  redLight:   "#b02828",
  purple:     "#2e1848",
  purpleLight:"#6030a0",
  void:       "#0e0818",
  sky:        "#1a2840",
  skyMid:     "#243650",
  ground:     "#2a1e10",
  groundMid:  "#1e1608",
};

// Pixel font simulation, all caps, monospace feel
const PX = {
  fontFamily: "'Courier New', Courier, monospace",
  fontDisplay: "'Georgia', serif",
};

// ============================================================
// PIXEL ART PRIMITIVES
// ============================================================

function PixelBorder({ children, color = C.border, bg = C.panel, style = {}, onClick }) {
  return (
    <div onClick={onClick} style={{
      background: bg,
      border: `2px solid ${color}`,
      boxShadow: `inset 0 0 0 1px ${C.bg}, 2px 2px 0 ${C.bg}`,
      imageRendering: "pixelated",
      position: "relative",
      ...style,
    }}>
      {/* Corner pixels */}
      <div style={{ position:"absolute", top:0, left:0, width:2, height:2, background:C.bg }} />
      <div style={{ position:"absolute", top:0, right:0, width:2, height:2, background:C.bg }} />
      <div style={{ position:"absolute", bottom:0, left:0, width:2, height:2, background:C.bg }} />
      <div style={{ position:"absolute", bottom:0, right:0, width:2, height:2, background:C.bg }} />
      {children}
    </div>
  );
}

function PixelBar({ pct, color, height = 6, bg = C.boneFaint }) {
  const segments = 20;
  const filled = Math.round((pct / 100) * segments);
  return (
    <div style={{ display:"flex", gap:1 }}>
      {Array.from({ length: segments }).map((_, i) => (
        <div key={i} style={{
          flex:1, height,
          background: i < filled ? color : bg,
          imageRendering: "pixelated",
        }} />
      ))}
    </div>
  );
}

// Pixel icon, 8x8 grid drawn with divs
function PixelIcon({ type, size = 16 }) {
  const px = size / 8;
  const icons = {
    bow: [
      "00100100",
      "01000010",
      "10111101",
      "01000010",
      "00100100",
      "00010000",
      "00001000",
      "00000100",
    ],
    sword: [
      "00000010",
      "00000101",
      "00001010",
      "00010100",
      "00101000",
      "01010000",
      "10100000",
      "01000000",
    ],
    flask: [
      "00111000",
      "00111000",
      "01111100",
      "11111110",
      "11011110",
      "11111110",
      "01111100",
      "00000000",
    ],
    book: [
      "01111110",
      "10000001",
      "10111101",
      "10000001",
      "10111101",
      "10000001",
      "10111101",
      "01111110",
    ],
    scales: [
      "00010000",
      "01111100",
      "00010000",
      "01010100",
      "10101010",
      "01010100",
      "00010000",
      "00111000",
    ],
    pick: [
      "00000110",
      "00001100",
      "00011000",
      "11110000",
      "01100000",
      "00110000",
      "00011000",
      "00001100",
    ],
    leaf: [
      "00001000",
      "00011100",
      "00111110",
      "01111100",
      "00111000",
      "00011000",
      "00001100",
      "00000110",
    ],
    axe: [
      "00001110",
      "00011110",
      "00111100",
      "01111000",
      "11110100",
      "01101000",
      "00010000",
      "00010000",
    ],
  };
  const grid = icons[type] || icons.book;
  return (
    <div style={{ display:"grid", gridTemplateColumns:`repeat(8,${px}px)`, imageRendering:"pixelated" }}>
      {grid.flatMap((row, r) =>
        row.split("").map((cell, c) => (
          <div key={`${r}-${c}`} style={{
            width: px, height: px,
            background: cell === "1" ? C.goldLight : "transparent",
          }} />
        ))
      )}
    </div>
  );
}

function PixelDivider({ color = C.border }) {
  return (
    <div style={{ display:"flex", alignItems:"center", gap:4, margin:"2px 0" }}>
      <div style={{ flex:1, height:1, background:color }} />
      <div style={{ width:3, height:3, background:color }} />
      <div style={{ flex:1, height:1, background:color }} />
    </div>
  );
}

// ============================================================
// TALENT SCREEN
// ============================================================

const TALENTS = [
  { name:"Foraging",     level:34, xp:67, icon:"leaf",  color:C.greenLight, activity:"Mirelands",         idle:true  },
  { name:"Felling",      level:21, xp:42, icon:"axe",   color:"#8B6914",    activity:"Ironbark Grove",     idle:true  },
  { name:"Delving",      level:28, xp:15, icon:"pick",  color:"#7a7a8c",    activity:"Iron Seam",          idle:true  },
  { name:"Alchemy",      level:19, xp:88, icon:"flask", color:C.purpleLight,activity:"Healing Draught",    idle:false },
  { name:"Marksmanship", level:31, xp:55, icon:"bow",   color:C.gold,       activity:"Grimwood Fringe",    idle:true  },
  { name:"Cookery",      level:12, xp:71, icon:"flask", color:"#c0632b",    activity:"Venison Stew",       idle:true  },
  { name:"Smelting",     level:9,  xp:34, icon:"pick",  color:"#e05c00",    activity:"Iron Bars",          idle:false },
  { name:"Inscription",  level:7,  xp:20, icon:"book",  color:C.boneDim,    activity:"Zone Map",           idle:false },
];

function TalentsScreen() {
  const [selected, setSelected] = useState(null);
  const [filter, setFilter] = useState("all");
  const filters = ["all","gathering","processing","combat"];
  const filterMap = {
    gathering:  ["Foraging","Felling","Delving"],
    processing: ["Alchemy","Cookery","Smelting","Inscription"],
    combat:     ["Marksmanship"],
  };
  const shown = filter === "all" ? TALENTS : TALENTS.filter(t => (filterMap[filter]||[]).includes(t.name));

  return (
    <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
      {/* Filter tabs */}
      <div style={{ display:"flex", gap:2 }}>
        {filters.map(f => (
          <button key={f} onClick={() => setFilter(f)} style={{
            flex:1,
            background: filter===f ? C.goldDim : C.panelMid,
            color: filter===f ? C.goldLight : C.boneDim,
            border: `2px solid ${filter===f ? C.gold : C.border}`,
            boxShadow: filter===f ? `inset 0 0 0 1px ${C.bg}` : "none",
            padding:"5px 0",
            fontSize:9,
            fontFamily: PX.fontFamily,
            textTransform:"uppercase",
            letterSpacing:1,
            cursor:"pointer",
          }}>{f}</button>
        ))}
      </div>

      {shown.map((t, i) => (
        <PixelBorder key={t.name}
          color={selected===i ? C.borderGold : C.border}
          bg={selected===i ? C.panelLight : C.panelMid}
          onClick={() => setSelected(selected===i ? null : i)}
          style={{ padding:"8px 10px", cursor:"pointer" }}
        >
          <div style={{ display:"flex", alignItems:"center", gap:10 }}>
            <PixelIcon type={t.icon} size={16} />
            <div style={{ flex:1, minWidth:0 }}>
              <div style={{ display:"flex", justifyContent:"space-between", marginBottom:4 }}>
                <span style={{ color:C.bone, fontSize:11, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:1 }}>{t.name}</span>
                <span style={{ color:C.gold, fontSize:11, fontFamily:PX.fontFamily }}>LV {t.level}</span>
              </div>
              <PixelBar pct={t.xp} color={t.color} height={5} />
              <div style={{ display:"flex", justifyContent:"space-between", marginTop:4 }}>
                <span style={{ color:C.boneDim, fontSize:9, fontFamily:PX.fontFamily }}>{t.activity}</span>
                <span style={{ color:t.idle?C.greenLight:C.boneFaint, fontSize:9, fontFamily:PX.fontFamily }}>
                  {t.idle ? "▶ IDLE" : "○ OFF"}
                </span>
              </div>
            </div>
          </div>
        </PixelBorder>
      ))}
    </div>
  );
}

// ============================================================
// COMBAT / BOWSTRING SCREEN
// ============================================================

const ENEMIES = {
  "Grimwood Brigand": { weakZone:{ x:50, y:18 }, weakLabel:"HEAD",  hp:80,  xp:42,  tag:"Outlaw" },
  "Forest Wolf":      { weakZone:{ x:60, y:35 }, weakLabel:"CHEST", hp:60,  xp:35,  tag:"Beast"  },
  "Poacher":          { weakZone:{ x:45, y:22 }, weakLabel:"HEAD",  hp:70,  xp:38,  tag:"Outlaw" },
  "Bandit Scout ★":   { weakZone:{ x:50, y:15 }, weakLabel:"HELM",  hp:110, xp:90,  tag:"Outlaw" },
};

function PixelEnemy({ type, glowWeak, weakPct }) {
  const isWolf = type === "Forest Wolf";
  const isBandit = type.includes("★");

  // Simple pixel art enemy silhouettes using CSS
  const humanoidBody = (
    <div style={{ position:"relative", width:48, height:72, imageRendering:"pixelated" }}>
      {/* Head */}
      <div style={{ position:"absolute", left:14, top:0, width:20, height:18,
        background: isBandit ? "#3a2a1a" : "#2a1e10",
        border:`2px solid ${C.border}`,
        boxShadow: glowWeak && ENEMIES[type]?.weakLabel==="HEAD" || glowWeak && ENEMIES[type]?.weakLabel==="HELM"
          ? `0 0 ${4+weakPct/10}px ${weakPct/10}px #ffcc44, 0 0 2px #ffcc44`
          : "none",
      }} />
      {/* Helm for bandit */}
      {isBandit && <div style={{ position:"absolute", left:12, top:-4, width:24, height:8, background:"#5a4030", border:`2px solid ${C.border}` }} />}
      {/* Eyes */}
      <div style={{ position:"absolute", left:18, top:5, width:3, height:3, background:"#cc3333" }} />
      <div style={{ position:"absolute", left:26, top:5, width:3, height:3, background:"#cc3333" }} />
      {/* Body */}
      <div style={{ position:"absolute", left:10, top:18, width:28, height:26,
        background:"#2a2010", border:`2px solid ${C.border}`,
        boxShadow: glowWeak && ENEMIES[type]?.weakLabel==="CHEST"
          ? `0 0 ${4+weakPct/10}px ${weakPct/10}px #ffcc44` : "none",
      }} />
      {/* Cloak detail */}
      <div style={{ position:"absolute", left:8, top:22, width:4, height:18, background:"#3a2a14" }} />
      <div style={{ position:"absolute", left:36, top:22, width:4, height:18, background:"#3a2a14" }} />
      {/* Arms */}
      <div style={{ position:"absolute", left:2, top:20, width:8, height:18, background:"#221810", border:`1px solid ${C.border}` }} />
      <div style={{ position:"absolute", left:38, top:20, width:8, height:18, background:"#221810", border:`1px solid ${C.border}` }} />
      {/* Weapon */}
      <div style={{ position:"absolute", left:40, top:14, width:3, height:28, background:"#4a3828" }} />
      {/* Legs */}
      <div style={{ position:"absolute", left:12, top:44, width:10, height:24, background:"#1e1810", border:`1px solid ${C.border}` }} />
      <div style={{ position:"absolute", left:26, top:44, width:10, height:24, background:"#1e1810", border:`1px solid ${C.border}` }} />
      {/* Boots */}
      <div style={{ position:"absolute", left:10, top:62, width:14, height:8, background:"#140e08" }} />
      <div style={{ position:"absolute", left:24, top:62, width:14, height:8, background:"#140e08" }} />
    </div>
  );

  const wolfBody = (
    <div style={{ position:"relative", width:64, height:48, imageRendering:"pixelated" }}>
      {/* Body */}
      <div style={{ position:"absolute", left:8, top:14, width:44, height:26, background:"#3a3028", border:`2px solid ${C.border}`,
        boxShadow: glowWeak ? `0 0 ${4+weakPct/10}px ${weakPct/10}px #ffcc44` : "none",
      }} />
      {/* Head */}
      <div style={{ position:"absolute", left:34, top:4, width:24, height:22, background:"#2e2820", border:`2px solid ${C.border}` }} />
      {/* Snout */}
      <div style={{ position:"absolute", left:52, top:12, width:10, height:10, background:"#24201a" }} />
      {/* Ears */}
      <div style={{ position:"absolute", left:36, top:0, width:6, height:8, background:"#2e2820" }} />
      <div style={{ position:"absolute", left:46, top:0, width:6, height:8, background:"#2e2820" }} />
      {/* Eye glow */}
      <div style={{ position:"absolute", left:46, top:8, width:4, height:4, background:"#cc4400" }} />
      {/* Legs */}
      {[8,18,30,40].map((x,i) => (
        <div key={i} style={{ position:"absolute", left:x, top:36, width:8, height:14, background:"#2a2418" }} />
      ))}
      {/* Tail */}
      <div style={{ position:"absolute", left:0, top:10, width:12, height:8, background:"#3a3028", transform:"rotate(-20deg)" }} />
    </div>
  );

  return isWolf ? wolfBody : humanoidBody;
}

function CombatScreen() {
  const [phase, setPhase] = useState("zone"); // zone | enemy | combat
  const [selectedZone, setSelectedZone] = useState(0);
  const [selectedEnemy, setSelectedEnemy] = useState(null);
  const [playerHp, setPlayerHp] = useState(85);
  const [enemyHp, setEnemyHp] = useState(100);
  const [log, setLog] = useState([]);
  const [drawing, setDrawing] = useState(false);
  const [drawPct, setDrawPct] = useState(0);
  const [aimX, setAimX] = useState(50);
  const [aimY, setAimY] = useState(50);
  const [glowWeak, setGlowWeak] = useState(true);
  const [weakPct, setWeakPct] = useState(100);
  const [arrow, setArrow] = useState(null);
  const [hitResult, setHitResult] = useState(null);
  const drawRef = useRef(null);
  const drawStartRef = useRef(null);
  const combatRef = useRef(null);

  const zones = [
    { name:"Grimwood Fringe", tier:1, req:1,  enemies:["Grimwood Brigand","Forest Wolf","Poacher","Bandit Scout ★"] },
    { name:"Saltmarsh Shore", tier:1, req:1,  enemies:["Saltmarsh Smuggler","Shore Crab","Coastal Serpent"] },
    { name:"Ashfen Mire",     tier:2, req:21, enemies:["Bogwalker Skeleton","Ashfen Treant","Mire Wraith"] },
  ];
  const zone = zones[selectedZone];
  const enemy = ENEMIES[selectedEnemy] || ENEMIES["Grimwood Brigand"];

  // Glow pulse when drawing
  useEffect(() => {
    if (!drawing) return;
    const t = setInterval(() => {
      setWeakPct(p => {
        const next = p - 3;
        if (next <= 0) { setGlowWeak(false); return 0; }
        return next;
      });
    }, 30);
    return () => clearInterval(t);
  }, [drawing]);

  // Auto combat idle tick
  useEffect(() => {
    if (phase !== "combat") return;
    const t = setInterval(() => {
      const dmg = Math.floor(Math.random()*6)+6; // mid-draw baseline
      setEnemyHp(h => {
        const next = Math.max(0, h-dmg);
        addLog(`Auto: ${dmg} dmg`);
        if (next === 0) { resetEnemy(); return 100; }
        return next;
      });
    }, 2500);
    return () => clearInterval(t);
  }, [phase]);

  function addLog(msg, color = C.bone) {
    setLog(l => [{ msg, color, id: Date.now()+Math.random() }, ...l.slice(0,5)]);
  }

  function resetEnemy() {
    const xp = enemy.xp + (Math.random() > 0.5 ? Math.floor(Math.random()*20) : 0);
    addLog(`${selectedEnemy} slain! +${xp} XP`, C.greenLight);
    setGlowWeak(true);
    setWeakPct(100);
  }

  function handlePointerDown(e) {
    if (phase !== "combat") return;
    e.preventDefault();
    const rect = combatRef.current?.getBoundingClientRect();
    if (!rect) return;
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    drawStartRef.current = { x: clientX, y: clientY };
    setDrawing(true);
    setGlowWeak(true);
    setWeakPct(100);
    setDrawPct(0);
    drawRef.current = setInterval(() => {
      setDrawPct(p => Math.min(p+4, 100));
    }, 40);
  }

  function handlePointerMove(e) {
    if (!drawing || !drawStartRef.current || !combatRef.current) return;
    e.preventDefault();
    const rect = combatRef.current.getBoundingClientRect();
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    const relX = ((clientX - rect.left) / rect.width) * 100;
    const relY = ((clientY - rect.top) / rect.height) * 100;
    // Invert for bowstring, drag back = aim opposite
    const dx = drawStartRef.current.x - clientX;
    const dy = drawStartRef.current.y - clientY;
    setAimX(Math.max(10, Math.min(90, 50 + dx * 0.3)));
    setAimY(Math.max(5, Math.min(80, 30 - dy * 0.2)));
  }

  function handlePointerUp(e) {
    if (!drawing) return;
    e.preventDefault();
    clearInterval(drawRef.current);
    setDrawing(false);

    const wp = enemy.weakZone;
    const dist = Math.sqrt(Math.pow(aimX - wp.x, 2) + Math.pow(aimY - wp.y, 2));
    const isCrit = dist < 12 && glowWeak;
    const isHit = dist < 28;
    const drawBonus = 0.7 + (drawPct / 100) * 0.3;

    let dmg = 0;
    let resultMsg = "";
    let resultColor = C.bone;

    if (isCrit) {
      dmg = Math.floor((22 + Math.random()*15) * drawBonus * 1.8);
      resultMsg = `⚡ CRIT! ${dmg} dmg, Attunement!`;
      resultColor = C.goldLight;
      setHitResult({ x: wp.x, y: wp.y, crit: true, dmg });
    } else if (isHit) {
      dmg = Math.floor((14 + Math.random()*10) * drawBonus);
      resultMsg = `Hit: ${dmg} dmg`;
      resultColor = C.bone;
      setHitResult({ x: aimX, y: aimY, crit: false, dmg });
    } else {
      resultMsg = `Missed`;
      resultColor = C.boneDim;
      setHitResult({ x: aimX, y: aimY, crit: false, dmg: 0, miss: true });
    }

    addLog(resultMsg, resultColor);

    // Arrow animation
    setArrow({ fromX: 50, fromY: 90, toX: aimX, toY: aimY });
    setTimeout(() => { setArrow(null); setHitResult(null); }, 600);

    setEnemyHp(h => {
      const next = Math.max(0, h - dmg);
      if (next === 0) setTimeout(resetEnemy, 400);
      return next;
    });

    setDrawPct(0);
    setAimX(50);
    setAimY(50);
    setGlowWeak(true);
    setWeakPct(100);
  }

  if (phase === "zone") return (
    <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
      <div style={{ color:C.boneDim, fontSize:9, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:2, marginBottom:2 }}>
        ▸ Select Zone
      </div>
      {zones.map((z,i) => (
        <PixelBorder key={z.name} color={selectedZone===i?C.borderGold:C.border}
          bg={selectedZone===i?C.panelLight:C.panelMid}
          onClick={() => setSelectedZone(i)}
          style={{ padding:"10px 12px", cursor:"pointer" }}
        >
          <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center" }}>
            <span style={{ color:C.bone, fontSize:11, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:1 }}>{z.name}</span>
            <span style={{ background:C.goldDim, color:C.goldLight, fontSize:9, fontFamily:PX.fontFamily, padding:"2px 6px" }}>TIER {z.tier}</span>
          </div>
          <div style={{ color:C.boneDim, fontSize:9, fontFamily:PX.fontFamily, marginTop:4 }}>
            REQ LV {z.req} · {z.enemies.length} ENEMIES
          </div>
        </PixelBorder>
      ))}
      <PixelBorder color={C.green} bg={C.greenDim} style={{ padding:"10px", textAlign:"center", cursor:"pointer" }} onClick={() => setPhase("enemy")}>
        <span style={{ color:C.goldLight, fontSize:11, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:2 }}>▸ Select Enemy</span>
      </PixelBorder>
    </div>
  );

  if (phase === "enemy") return (
    <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
      <div style={{ display:"flex", alignItems:"center", gap:8 }}>
        <button onClick={() => setPhase("zone")} style={{ background:"transparent", border:`1px solid ${C.border}`, color:C.boneDim, padding:"4px 8px", fontSize:9, fontFamily:PX.fontFamily, cursor:"pointer" }}>◂ BACK</button>
        <span style={{ color:C.boneDim, fontSize:9, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:2 }}>{zone.name}</span>
      </div>
      {zone.enemies.map(e => {
        const known = ENEMIES[e];
        return (
          <PixelBorder key={e} color={selectedEnemy===e?C.borderGold:C.border} bg={selectedEnemy===e?C.panelLight:C.panelMid}
            onClick={() => setSelectedEnemy(e)} style={{ padding:"10px 12px", cursor:"pointer" }}
          >
            <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center" }}>
              <span style={{ color: e.includes("★")?C.goldLight:C.bone, fontSize:11, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:1 }}>{e}</span>
              {known && <span style={{ color:C.boneDim, fontSize:9, fontFamily:PX.fontFamily }}>[{known.tag}]</span>}
            </div>
            {known && (
              <div style={{ color:C.boneDim, fontSize:9, fontFamily:PX.fontFamily, marginTop:3 }}>
                WEAK: {known.weakLabel} · +{known.xp} XP
              </div>
            )}
          </PixelBorder>
        );
      })}
      <PixelBorder color={selectedEnemy?C.green:C.border} bg={selectedEnemy?C.greenDim:C.panelMid}
        style={{ padding:"10px", textAlign:"center", cursor:selectedEnemy?"pointer":"not-allowed" }}
        onClick={() => { if(selectedEnemy && ENEMIES[selectedEnemy]) { setEnemyHp(100); setPhase("combat"); setLog([]); }}}
      >
        <span style={{ color:selectedEnemy?C.goldLight:C.boneDim, fontSize:11, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:2 }}>
          {selectedEnemy ? `▸ Engage ${selectedEnemy}` : "SELECT AN ENEMY"}
        </span>
      </PixelBorder>
    </div>
  );

  // COMBAT SCREEN
  return (
    <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
      {/* HP bars */}
      <div style={{ display:"flex", gap:6 }}>
        <PixelBorder style={{ flex:1, padding:"6px 10px" }}>
          <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily, marginBottom:3 }}>PLAYER</div>
          <PixelBar pct={playerHp} color={C.greenLight} height={5} />
          <div style={{ color:C.bone, fontSize:9, fontFamily:PX.fontFamily, marginTop:2 }}>{playerHp}/100</div>
        </PixelBorder>
        <PixelBorder style={{ flex:1, padding:"6px 10px" }}>
          <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily, marginBottom:3 }}>{selectedEnemy?.toUpperCase()}</div>
          <PixelBar pct={enemyHp} color={C.redLight} height={5} />
          <div style={{ color:C.bone, fontSize:9, fontFamily:PX.fontFamily, marginTop:2 }}>{enemyHp}/100</div>
        </PixelBorder>
      </div>

      {/* COMBAT ARENA, over shoulder view */}
      <PixelBorder
        ref={combatRef}
        color={C.border}
        bg={C.void}
        style={{
          position:"relative",
          height:240,
          overflow:"hidden",
          userSelect:"none",
          touchAction:"none",
          cursor: drawing ? "crosshair" : "default",
        }}
        onMouseDown={handlePointerDown}
        onMouseMove={handlePointerMove}
        onMouseUp={handlePointerUp}
        onTouchStart={handlePointerDown}
        onTouchMove={handlePointerMove}
        onTouchEnd={handlePointerUp}
      >
        {/* Sky gradient, pixel dithered */}
        <div style={{ position:"absolute", inset:0, background:`linear-gradient(180deg, ${C.sky} 0%, ${C.skyMid} 50%, ${C.ground} 70%, ${C.groundMid} 100%)` }} />

        {/* Dither layer */}
        <div style={{
          position:"absolute", inset:0, opacity:0.08,
          backgroundImage:"url(\"data:image/svg+xml,%3Csvg width='2' height='2' viewBox='0 0 2 2' xmlns='http://www.w3.org/2000/svg'%3E%3Crect x='0' y='0' width='1' height='1' fill='%23fff'/%3E%3Crect x='1' y='1' width='1' height='1' fill='%23fff'/%3E%3C/svg%3E\")",
          backgroundSize:"2px 2px",
        }} />

        {/* Horizon ground line */}
        <div style={{ position:"absolute", top:"58%", left:0, right:0, height:2, background:C.border }} />
        <div style={{ position:"absolute", top:"59%", left:0, right:0, height:1, background:C.boneFaint, opacity:0.3 }} />

        {/* Trees bg */}
        {[8,18,70,82,92].map((x,i) => (
          <div key={i} style={{ position:"absolute", left:`${x}%`, top:"35%", width:8, height:"25%", background:"#0e1a0a" }} />
        ))}
        {[8,18,70,82,92].map((x,i) => (
          <div key={i} style={{ position:"absolute", left:`${x-1}%`, top:"24%", width:10, height:"16%", background:"#142010" }} />
        ))}

        {/* Enemy in distance */}
        <div style={{ position:"absolute", left:"44%", top:"30%", transform:"scale(0.7)", transformOrigin:"bottom center" }}>
          <PixelEnemy type={selectedEnemy} glowWeak={glowWeak} weakPct={weakPct} />
        </div>

        {/* Weak point indicator, subtle pixel glow */}
        {glowWeak && enemy.weakZone && (
          <div style={{
            position:"absolute",
            left:`${enemy.weakZone.x - 3}%`,
            top:`${enemy.weakZone.y + 2}%`,
            width:8, height:8,
            background:`radial-gradient(circle, #ffcc4488 0%, transparent 70%)`,
            border:`1px solid #ffcc4444`,
            borderRadius:"50%",
            opacity: weakPct/100,
            transition:"opacity 0.1s",
            pointerEvents:"none",
          }} />
        )}

        {/* Aim arc, fades into distance */}
        {drawing && (
          <svg style={{ position:"absolute", inset:0, width:"100%", height:"100%", pointerEvents:"none" }}>
            <defs>
              <linearGradient id="arcFade" x1="0" y1="1" x2="0" y2="0">
                <stop offset="0%" stopColor={C.goldLight} stopOpacity="0.8" />
                <stop offset="60%" stopColor={C.goldLight} stopOpacity="0.2" />
                <stop offset="100%" stopColor={C.goldLight} stopOpacity="0" />
              </linearGradient>
            </defs>
            <path
              d={`M 50% 88% Q ${aimX}% ${(aimY+90)/2}% ${aimX}% ${aimY}%`}
              fill="none"
              stroke="url(#arcFade)"
              strokeWidth="1.5"
              strokeDasharray="3 3"
            />
          </svg>
        )}

        {/* Arrow in flight */}
        {arrow && (
          <div style={{
            position:"absolute",
            left:`${arrow.fromX}%`,
            top:`${arrow.fromY}%`,
            width:2, height:2,
            background:C.goldLight,
            boxShadow:`0 0 4px ${C.gold}`,
            transition:"all 0.3s ease-out",
          }} />
        )}

        {/* Hit result flash */}
        {hitResult && (
          <div style={{
            position:"absolute",
            left:`${hitResult.x}%`,
            top:`${hitResult.y}%`,
            transform:"translate(-50%,-100%)",
            color: hitResult.crit ? C.goldLight : hitResult.miss ? C.boneDim : C.bone,
            fontSize: hitResult.crit ? 11 : 9,
            fontFamily: PX.fontFamily,
            fontWeight:700,
            textShadow:`0 0 4px ${C.bg}`,
            pointerEvents:"none",
            whiteSpace:"nowrap",
          }}>
            {hitResult.miss ? "MISS" : hitResult.crit ? `⚡${hitResult.dmg}!` : `-${hitResult.dmg}`}
          </div>
        )}

        {/* Draw power bar */}
        {drawing && (
          <div style={{ position:"absolute", bottom:8, left:8, right:8 }}>
            <PixelBar pct={drawPct} color={drawPct>80?C.goldLight:C.gold} height={4} />
          </div>
        )}

        {/* Archer silhouette, over shoulder */}
        <div style={{ position:"absolute", bottom:0, left:"50%", transform:"translateX(-50%)" }}>
          {/* Back of archer */}
          <div style={{ position:"relative", width:36, height:52, imageRendering:"pixelated" }}>
            {/* Hood/head from behind */}
            <div style={{ position:"absolute", left:8, top:0, width:20, height:18, background:"#2a3820", border:`2px solid #1a2418` }} />
            <div style={{ position:"absolute", left:4, top:4, width:28, height:14, background:"#223018", border:`1px solid #1a2418` }} />
            {/* Shoulders */}
            <div style={{ position:"absolute", left:0, top:16, width:12, height:10, background:"#2a3820" }} />
            <div style={{ position:"absolute", left:24, top:16, width:12, height:10, background:"#2a3820" }} />
            {/* Body / cloak */}
            <div style={{ position:"absolute", left:4, top:18, width:28, height:28, background:"#223018", border:`1px solid #1a2418` }} />
            {/* Quiver on back */}
            <div style={{ position:"absolute", left:24, top:10, width:8, height:22, background:"#5a3810", border:`1px solid #3a2408` }} />
            <div style={{ position:"absolute", left:25, top:8, width:2, height:8, background:C.goldDim }} />
            <div style={{ position:"absolute", left:28, top:6, width:2, height:10, background:C.goldDim }} />
            <div style={{ position:"absolute", left:31, top:8, width:2, height:8, background:C.goldDim }} />
            {/* Bow arm extended left */}
            <div style={{ position:"absolute", left:-8, top:20, width:14, height:6, background:"#2a3820", borderRadius:2 }} />
            {/* Bow */}
            <div style={{ position:"absolute", left:-14, top:8, width:4, height:32, background:"#5a3810", border:`1px solid #3a2408`, borderRadius:2 }} />
            {/* Bowstring */}
            <div style={{ position:"absolute", left:-12, top:10, width:2, height:28,
              background: drawing
                ? `linear-gradient(180deg, ${C.goldDim}, ${C.gold}, ${C.goldDim})`
                : "#3a2808",
              transform: drawing ? `scaleX(${1 + drawPct*0.008})` : "none",
            }} />
            {/* Draw hand */}
            {drawing && <div style={{ position:"absolute", left:2+drawPct*0.12, top:28, width:8, height:6, background:"#2a1e10" }} />}
          </div>
        </div>

        {/* HUD hint */}
        <div style={{
          position:"absolute", top:6, left:0, right:0,
          textAlign:"center",
          color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily,
          textShadow:`0 1px 2px ${C.bg}`,
          pointerEvents:"none",
        }}>
          {drawing
            ? drawPct > 80 ? "▸ FULL DRAW, RELEASE" : "▸ HOLD TO CHARGE"
            : "▸ PRESS & DRAG TO AIM, RELEASE TO FIRE"}
        </div>
      </PixelBorder>

      {/* Combat log */}
      <PixelBorder style={{ padding:"8px 10px" }}>
        <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:2, marginBottom:4 }}>Combat Log</div>
        {log.length === 0 && <div style={{ color:C.boneFaint, fontSize:9, fontFamily:PX.fontFamily }}>Combat engaged...</div>}
        {log.map((l,i) => (
          <div key={l.id} style={{ color:l.color, fontSize:9, fontFamily:PX.fontFamily, opacity:1-i*0.15, padding:"1px 0" }}>{l.msg}</div>
        ))}
      </PixelBorder>

      <button onClick={() => { setPhase("zone"); setLog([]); setDrawing(false); setDrawPct(0); }} style={{
        background:"transparent", border:`2px solid ${C.border}`,
        color:C.boneDim, padding:"6px", fontSize:9,
        fontFamily:PX.fontFamily, textTransform:"uppercase",
        letterSpacing:2, cursor:"pointer",
      }}>◂ RETREAT</button>
    </div>
  );
}

// ============================================================
// MARKET SCREEN
// ============================================================
const MARKET = [
  { name:"Iron Bar",           qty:240, price:"42 SM",    type:"store",   seller:"Aldric_Forge",  tier:"Rough"     },
  { name:"Wolf Pelt",          qty:18,  price:"380 SM",   type:"store",   seller:"TrappersGuild", tier:"Common"    },
  { name:"Crude Amber",        qty:3,   price:"1,200 SM", type:"auction", seller:"Felling_Co",    timeLeft:"6h 22m", tier:"Crude" },
  { name:"Refined Leather",    qty:12,  price:"2,800 SM", type:"store",   seller:"TannerMark",    tier:"Refined"   },
  { name:"Healing Draught",    qty:50,  price:"65 SM",    type:"store",   seller:"AlchemyRow",    tier:""          },
  { name:"Rough Gemstone",     qty:1,   price:"3,400 SM", type:"auction", seller:"DeepDelver",    timeLeft:"2d 1h", tier:"Rough" },
];

const TIER_COLORS = { Crude:"#7a7a7a", Rough:"#c8c8c8", Refined:C.greenLight, Pristine:"#6090e0", Masterwork:C.purpleLight, Legendary:C.goldLight };

function MarketScreen() {
  const [tab, setTab] = useState("browse");
  return (
    <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
      <div style={{ display:"flex", gap:2 }}>
        {["browse","sell","orders"].map(t => (
          <button key={t} onClick={() => setTab(t)} style={{
            flex:1, background:tab===t?C.goldDim:C.panelMid,
            color:tab===t?C.goldLight:C.boneDim,
            border:`2px solid ${tab===t?C.gold:C.border}`,
            padding:"6px 0", fontSize:9,
            fontFamily:PX.fontFamily, textTransform:"uppercase",
            letterSpacing:1, cursor:"pointer",
          }}>{t==="orders"?"ORDERS":t.toUpperCase()}</button>
        ))}
      </div>

      {tab==="browse" && (
        <div style={{ display:"flex", flexDirection:"column", gap:6 }}>
          {MARKET.map((item,i) => (
            <PixelBorder key={i} style={{ padding:"8px 10px" }}>
              <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start" }}>
                <div>
                  <div style={{ display:"flex", alignItems:"center", gap:6 }}>
                    <span style={{ color:C.bone, fontSize:11, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:1 }}>{item.name}</span>
                    {item.tier && <span style={{ color:TIER_COLORS[item.tier]||C.boneDim, fontSize:8, fontFamily:PX.fontFamily }}>[{item.tier.toUpperCase()}]</span>}
                  </div>
                  <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily, marginTop:3 }}>
                    {item.seller} · QTY {item.qty}
                  </div>
                </div>
                <div style={{ textAlign:"right" }}>
                  <div style={{ color:C.gold, fontSize:11, fontFamily:PX.fontFamily }}>{item.price}</div>
                  {item.timeLeft && <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily }}>⏱ {item.timeLeft}</div>}
                  <div style={{ color:item.type==="auction"?C.purpleLight:C.greenLight, fontSize:8, fontFamily:PX.fontFamily }}>
                    {item.type==="auction"?"AUCTION":"BUY NOW"}
                  </div>
                </div>
              </div>
            </PixelBorder>
          ))}
        </div>
      )}

      {tab==="sell" && (
        <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
          <div style={{ color:C.boneDim, fontSize:9, fontFamily:PX.fontFamily, textAlign:"center", padding:"16px 0" }}>
            SELECT ITEM FROM INVENTORY TO LIST
          </div>
          {["STORE LISTING, 2% FEE · PARTIAL FILLS","AUCTION, 3% FEE · 1/7/15 DAY DURATION"].map(t => (
            <PixelBorder key={t} style={{ padding:"10px 12px" }}>
              <div style={{ color:C.bone, fontSize:9, fontFamily:PX.fontFamily }}>{t}</div>
            </PixelBorder>
          ))}
        </div>
      )}

      {tab==="orders" && (
        <div style={{ display:"flex", flexDirection:"column", gap:6 }}>
          <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:1 }}>Active Buy Orders, Marks in Escrow</div>
          {[{name:"Wolf Pelt",qty:20,price:"320 SM",filled:8},{name:"Iron Bar",qty:100,price:"38 SM",filled:45}].map((o,i) => (
            <PixelBorder key={i} style={{ padding:"8px 10px" }}>
              <div style={{ display:"flex", justifyContent:"space-between" }}>
                <span style={{ color:C.bone, fontSize:11, fontFamily:PX.fontFamily, textTransform:"uppercase" }}>{o.name}</span>
                <span style={{ color:C.gold, fontSize:10, fontFamily:PX.fontFamily }}>{o.price}</span>
              </div>
              <div style={{ marginTop:6 }}>
                <PixelBar pct={(o.filled/o.qty)*100} color={C.greenLight} height={4} />
                <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily, marginTop:3 }}>{o.filled}/{o.qty} FILLED</div>
              </div>
            </PixelBorder>
          ))}
        </div>
      )}
    </div>
  );
}

// ============================================================
// GRIMOIRE SCREEN
// ============================================================
const GRIMS = [
  { name:"Sharpshot",  path:"Warden",   icon:"bow",   color:C.green,       equipped:true,  sig:"Steady Hand, Draw dmg +30%, speed -20%" },
  { name:"Runeweaver", path:"Arcanist", icon:"book",  color:C.purpleLight, equipped:false, sig:"Elemental Attunement, All elemental dmg +10%" },
  { name:"Warlord",    path:"Vanguard", icon:"sword", color:C.red,         equipped:false, sig:"Iron Resolve, Dmg taken -10%, Max HP +5%" },
];

function GrimoireScreen() {
  const [sel, setSel] = useState(0);
  return (
    <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
      <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:2 }}>
        Cooldown: ~24 hrs after swap
      </div>
      {GRIMS.map((g,i) => (
        <PixelBorder key={g.name} color={sel===i?g.color:C.border} bg={sel===i?C.panelLight:C.panelMid}
          onClick={() => setSel(i)} style={{ padding:"12px 14px", cursor:"pointer" }}
        >
          <div style={{ display:"flex", alignItems:"center", gap:12 }}>
            <PixelBorder color={g.color} bg={`${g.color}22`} style={{ padding:8 }}>
              <PixelIcon type={g.icon} size={20} />
            </PixelBorder>
            <div style={{ flex:1 }}>
              <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center" }}>
                <span style={{ color:C.bone, fontSize:12, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:1 }}>
                  {g.name}
                </span>
                {g.equipped && (
                  <span style={{ color:C.gold, fontSize:8, fontFamily:PX.fontFamily, border:`1px solid ${C.goldDim}`, padding:"1px 6px" }}>EQUIPPED</span>
                )}
              </div>
              <div style={{ color:g.color, fontSize:9, fontFamily:PX.fontFamily, marginTop:2, textTransform:"uppercase" }}>{g.path} Path</div>
            </div>
          </div>
          {sel===i && (
            <>
              <PixelDivider color={C.border} />
              <div style={{ color:C.boneDim, fontSize:9, fontFamily:PX.fontFamily, marginBottom:8 }}>
                ▸ {g.sig}
              </div>
              <PixelBorder
                color={g.equipped?C.border:g.color}
                bg={g.equipped?C.panelMid:`${g.color}22`}
                style={{ padding:"7px", textAlign:"center", cursor:g.equipped?"not-allowed":"pointer" }}
              >
                <span style={{ color:g.equipped?C.boneDim:C.goldLight, fontSize:9, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:2 }}>
                  {g.equipped?"Currently Equipped":"▸ Equip Grimoire"}
                </span>
              </PixelBorder>
            </>
          )}
        </PixelBorder>
      ))}
      <PixelBorder style={{ padding:"12px", textAlign:"center" }}>
        <div style={{ color:C.gold, fontSize:11, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:2 }}>+ Unlock Grimoires</div>
        <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily, marginTop:4 }}>500 GM · System Store</div>
      </PixelBorder>
    </div>
  );
}

// ============================================================
// ROOT
// ============================================================
export default function App() {
  const [screen, setScreen] = useState("combat");
  const [tick, setTick] = useState(0);

  useEffect(() => {
    const t = setInterval(() => setTick(x => x+1), 1000);
    return () => clearInterval(t);
  }, []);

  const tabs = [
    { id:"talents",  label:"Talents",  icon:"leaf"   },
    { id:"combat",   label:"Combat",   icon:"bow"    },
    { id:"market",   label:"Exchange", icon:"scales" },
    { id:"grimoire", label:"Grimoire", icon:"book"   },
  ];

  const now = new Date();
  const timeStr = now.toLocaleTimeString([],{hour:"2-digit",minute:"2-digit"});

  return (
    <div style={{
      background: C.bg,
      minHeight:"100vh",
      maxWidth:420,
      margin:"0 auto",
      display:"flex",
      flexDirection:"column",
      imageRendering:"pixelated",
      position:"relative",
    }}>
      {/* TOP BAR */}
      <div style={{
        background:C.panel,
        borderBottom:`2px solid ${C.borderGold}`,
        boxShadow:`0 2px 0 ${C.bg}`,
        padding:"8px 14px",
        display:"flex",
        justifyContent:"space-between",
        alignItems:"center",
        position:"sticky", top:0, zIndex:10,
      }}>
        <div>
          <div style={{ color:C.gold, fontSize:14, fontFamily:PX.fontDisplay, letterSpacing:2, textTransform:"uppercase" }}>
            Project Grimoire
          </div>
          <div style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily, marginTop:1, textTransform:"uppercase", letterSpacing:1 }}>
            Sharpshot · Lv 31 · Grimwood Fringe
          </div>
        </div>
        <div style={{ textAlign:"right" }}>
          <div style={{ color:C.gold, fontSize:11, fontFamily:PX.fontFamily }}>◈ 2,840 SM</div>
          <div style={{ color:C.boneDim, fontSize:9, fontFamily:PX.fontFamily }}>◇ 12 GM · {timeStr}</div>
        </div>
      </div>

      {/* IDLE STATUS */}
      <div style={{
        background:C.greenDim,
        borderBottom:`1px solid ${C.green}`,
        padding:"4px 14px",
        display:"flex",
        justifyContent:"space-between",
      }}>
        <span style={{ color:C.greenLight, fontSize:8, fontFamily:PX.fontFamily, textTransform:"uppercase", letterSpacing:1 }}>▶ 3 Talents Idle</span>
        <span style={{ color:C.boneDim, fontSize:8, fontFamily:PX.fontFamily }}>Marksmanship · Foraging · Felling</span>
      </div>

      {/* CONTENT */}
      <div style={{ flex:1, padding:"12px 12px 80px", overflowY:"auto" }}>
        {screen==="talents"  && <TalentsScreen />}
        {screen==="combat"   && <CombatScreen />}
        {screen==="market"   && <MarketScreen />}
        {screen==="grimoire" && <GrimoireScreen />}
      </div>

      {/* BOTTOM NAV */}
      <div style={{
        position:"fixed", bottom:0,
        left:"50%", transform:"translateX(-50%)",
        width:"100%", maxWidth:420,
        background:C.panel,
        borderTop:`2px solid ${C.borderGold}`,
        boxShadow:`0 -2px 0 ${C.bg}`,
        display:"flex",
        zIndex:10,
      }}>
        {tabs.map(tab => (
          <button key={tab.id} onClick={() => setScreen(tab.id)} style={{
            flex:1,
            background: screen===tab.id ? C.panelLight : "transparent",
            border:"none",
            borderTop:`2px solid ${screen===tab.id?C.gold:"transparent"}`,
            padding:"8px 0 10px",
            cursor:"pointer",
            display:"flex",
            flexDirection:"column",
            alignItems:"center",
            gap:4,
          }}>
            <PixelIcon type={tab.icon} size={14} />
            <span style={{
              color: screen===tab.id?C.gold:C.boneDim,
              fontSize:8,
              fontFamily:PX.fontFamily,
              textTransform:"uppercase",
              letterSpacing:1,
            }}>{tab.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
