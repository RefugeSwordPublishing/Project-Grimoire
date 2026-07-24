---
type: implementation-brief
spec: combat-engagement-spec.md (v0.2), warden-combat-spec.md (v0.1)
updated: 2026-07-11
purpose: Convert ZoneCombatView from 2D to a true HD-2D 3D scene before the sprite
         pass begins. Do this FIRST, retrofitting after sprites are placed is costly.
---

# Combat Scene, 3D Architecture Brief

## Why Now

The Bowstring weak point system requires knowing WHERE on an enemy's body an arrow
hit. In a flat 2D scene, vertical aim has no meaning, the arrow always hits the
front face of the sprite. In a 3D scene the arrow travels along the Z axis; the
intersection point on the enemy's sprite plane maps to a UV coordinate that can
be checked against a weak point mask.

This also delivers the front-to-back depth feel that defines the HD-2D art direction.
Do this before the sprite pass, not after.

---

## Scene Architecture

### Camera
```
Change: Orthographic → Perspective
FOV: 60°
Near clip: 0.1
Far clip: 100
Position: (0, 1.5, -10), slightly elevated, looking forward into scene
```

### Z-Depth Planes (all in world space)

```
Z = -10   Camera position
Z =   0   Player sprite plane
Z =   5   Foreground debris / particles
Z =  10   Enemy sprite plane  ← primary combat plane
Z =  20   Near background layer
Z =  35   Mid background layer
Z =  50   Far background / skybox
```

All sprites are **quads** (flat planes) placed at their Z position, facing the camera.
Unity's `Billboard` or simply `transform.LookAt(camera)` keeps sprites camera-facing.

### Player Sprite
```csharp
// Player quad at Z=0, always faces camera
playerQuad.transform.position = new Vector3(0, 0, 0);
playerQuad.GetComponent<SpriteRenderer>().sprite = playerSprite;
// Point filter, PPU 100, same as all sprites
```

### Enemy Sprite
```csharp
// Enemy quad at Z=10
enemyQuad.transform.position = new Vector3(0, 0, 10);
enemyQuad.GetComponent<SpriteRenderer>().sprite = enemyData.icon;
// Add BoxCollider for ray intersection (see below)
```

### Background Layers
Each parallax layer is a quad at increasing Z depth.
The camera's depth-of-field blurs layers beyond the enemy plane.
```csharp
// Parallax layers
backgroundLayers[0].transform.position = new Vector3(0, 0, 20); // near
backgroundLayers[1].transform.position = new Vector3(0, 0, 35); // mid
backgroundLayers[2].transform.position = new Vector3(0, 0, 50); // far/sky
```

---

## Bowstring, 3D Ray on Release

Replace 2D aim with a 3D ray cast from camera through the aim point:

```csharp
void OnBowRelease(Vector2 screenAimPosition) {
    // Cast ray from camera through screen aim position into world
    Ray aimRay = Camera.main.ScreenPointToRay(screenAimPosition);

    // Check intersection with enemy sprite plane
    if (Physics.Raycast(aimRay, out RaycastHit hit, 100f,
                        LayerMask.GetMask("Enemy"))) {

        // Get UV coordinate of hit point on enemy quad
        Vector2 hitUV = hit.textureCoord;

        // Check against weak point mask
        bool isWeakPoint = enemyData.weakPointMask.GetPixel(
            Mathf.RoundToInt(hitUV.x * maskWidth),
            Mathf.RoundToInt(hitUV.y * maskHeight)).a > 0.5f;

        float multiplier = isWeakPoint
            ? enemyData.weakPointMultiplier  // 2.0f
            : 1.0f;

        OnAttackFired(baseDamage * drawPower * multiplier);

        // Trigger weak point glow if hit
        if (isWeakPoint) TriggerWeakPointGlow(hit.point);
    }
    else {
        // Miss, arrow passes by enemy
        OnAttackFired(0);
        PlayMissEffect();
    }
}
```

**Enemy quad needs:**
- `MeshCollider` with `convex = false` (allows `textureCoord` from `RaycastHit`)
- Layer: "Enemy"
- `Read/Write Enabled` on the weak point mask texture

---

## Arrow Visual, 3D Projectile

Arrow is a simple 3D object traveling from player to enemy along the Z axis:

```csharp
void FireArrowVisual(Vector3 targetPoint, bool isHit) {
    GameObject arrow = Instantiate(arrowPrefab,
        playerQuad.transform.position, Quaternion.identity);

    Vector3 direction = (targetPoint - arrow.transform.position).normalized;
    arrow.transform.rotation = Quaternion.LookRotation(direction);

    // Travel time: 0.15s, fast enough to feel instant, visible enough to read
    StartCoroutine(MoveArrow(arrow, targetPoint, 0.15f, isHit));
}

IEnumerator MoveArrow(GameObject arrow, Vector3 target,
                       float duration, bool isHit) {
    float elapsed = 0;
    Vector3 start = arrow.transform.position;

    while (elapsed < duration) {
        arrow.transform.position = Vector3.Lerp(start, target,
            elapsed / duration);
        elapsed += Time.deltaTime;
        yield return null;
    }

    // On arrival: hit effect or miss effect
    if (isHit) PlayHitEffect(target);
    else PlayMissEffect();
    Destroy(arrow);
}
```

Arrow prefab: a thin elongated quad sprite (the arrow sprite), no physics,
no Rigidbody, purely visual. Hit detection already resolved at release via raycast.

---

## Weak Point Mask System

### Mask Texture per Enemy

Each enemy has a corresponding mask texture:
- Same dimensions as the enemy sprite
- Greyscale, white pixels = weak point zone, black = body
- `Read/Write Enabled` in Unity import settings
- Stored as `EnemyData.weakPointMask` (Texture2D reference)

```csharp
// In EnemyData ScriptableObject, add:
public Texture2D weakPointMask;       // white = weak point region
public float weakPointMultiplier = 2.0f; // fixed ×2.0 across all enemies
public WeakPointTier weakPointTier;   // visibility tier (see below)
```

### Mask Authoring

For each enemy sprite, author a corresponding mask texture:
- Can be created in any image editor, paint white over the weak point region
- Save as a separate PNG alongside the enemy sprite
- Example: wolf sprite → wolf head is top ~20% of sprite → white region in top 20%

Claude Code can include a Unity Editor tool `Tools > Grimoire > Create Weak Point Mask`
that opens a simple paint tool over the enemy sprite for quick mask authoring.

### Weak Point Multiplier
Fixed at **×2.0** for all enemies. No per-enemy variation in base game.
DLC may introduce enemies with ×1.5 (armored) or ×2.5 (exposed vital) variations.

---

## Weak Point Visibility Tiers

```csharp
public enum WeakPointTier {
    Obvious,   // Always visible, glowing core, exposed crystal etc.
    Subtle,    // Brief pulse/shimmer on attack or damage, observant players notice
    Hidden     // No tell, pure pattern recognition. Lone Wolf's Eye reveals these.
}
```

### Tier 1, Obvious
Weak point glow is always rendered as a subtle pulse on the mask region.
Enemy sprites for these types should have a natural glowing element (core, crystal).

### Tier 2, Subtle
Glow fires briefly (0.5s pulse) when:
- Enemy attacks
- Enemy takes any damage

Otherwise invisible. Players who watch the enemy learn the pattern over time.

### Tier 3, Hidden
No glow at all unless the player has Lone Wolf's Eye (Lone Wanderer level 38)
or Deadeye (Sharpshot level 59) unlocked. With those talents active,
a subtle glow appears, same as Tier 2 behaviour.

```csharp
void UpdateWeakPointGlow() {
    bool shouldGlow = weakPointTier switch {
        WeakPointTier.Obvious => true,
        WeakPointTier.Subtle  => _enemyJustAttacked || _enemyJustTookDamage,
        WeakPointTier.Hidden  => playerHasRevealTalent,
        _ => false
    };
    weakPointGlowRenderer.enabled = shouldGlow;
}
```

---

## Post-Processing, Unchanged

URP post-processing works in 3D, no changes needed.
Bloom, depth-of-field, color grading, atmospheric particles all continue
to apply via Volume components placed in the 3D scene.

Depth-of-field should be configured to focus on the enemy plane (Z=10):
```
Focus Distance: 10
Focal Length: 50mm
Aperture: f/2.8
```
This naturally blurs foreground elements slightly and background layers more
aggressively, the front-to-back depth feel.

---

## Migration Steps from Current 2D Scene

1. Change Camera from Orthographic → Perspective (FOV 60°)
2. Move player sprite to Z=0 quad
3. Move enemy placeholder to Z=10 quad, add MeshCollider
4. Move background placeholder to Z=20 quad
5. Update `WardenBowstringMechanic.OnRelease` to use `Physics.Raycast`
6. Add `weakPointMask` and `weakPointMultiplier` fields to `EnemyData`
7. Add `WeakPointTier` enum and visibility logic to `ZoneCombatView`
8. Add arrow prefab traveling Z axis visually
9. Update depth-of-field Volume to focus at Z=10
10. Verify all existing combat events still fire correctly
    (HP bars, attack cadence bars, hit markers, all UI, unaffected by 3D change)

---

## What Stays the Same

- All combat events: `OnPlayerAttack`, `OnEnemyAttack`, `OnPlayerHit`, `OnCombatLog`
- HP bars, attack cadence bars, hotbar, all UI overlay, unaffected
- `CombatManager` loop, no changes, still drives damage/XP/loot
- `ActiveCombatMechanic` seam, Constellation and Vanguard Combo unaffected
- Idle auto-attack, fires without raycast, just applies base damage

---

*Path: `docs/combat-scene-3d-brief.md`*
