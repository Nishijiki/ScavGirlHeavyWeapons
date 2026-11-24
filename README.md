# ScavGirlHeavyWeapons

**Standalone UE4SS Lua mod for The Forever Winter.** Adds Scav Girl to the allowed-character tags for selected LMG, HRF, GRL and HMG weapons.

- **Current version:** 1.2.0
- **Target character:** Scav Girl — `Pawn.Player.Girl`
- **Required framework:** UE4SS 4.0.0
- **Game engine observed during development:** Unreal Engine 5.4
- **TFWWorkbench:** not required
- **Scope:** weapon compatibility tags only

> **Experimental:** HMG01 (Painless) is unlocked for Scav Girl, but currently causes character positioning and camera clipping issues. This mod does not include an animation or camera fix.

## Weapons unlocked for Scav Girl

The mod adds Scav Girl to the allowed-character list for **13 weapon entries** in the game's `WeaponsDetailsData` DataTable:

### Light machine guns — LMG (5)

- `LMG01` — **MG34**
- `LMG02` — **SAW (M249)**
- `LMG03` — **M60**
- `LMG04` — **RPD**
- `LMG06` — **LMG-P**

### Heavy rifles — HRF (5)

- `HRF01` — **SCAR**
- `HRF02` — **36M AntiTank**
- `HRF03` — **NTW-20**
- `HRF04` — **GM6**
- `HRF05` — **AT-43 MASS**

### Grenade launchers — GRL (2)

- `GRL01` — **Grenade Launcher**
- `GRL02` — **XM25**

### Heavy machine gun — HMG (1)

- `HMG01` — **Painless** *(experimental; known character positioning and camera clipping issue)*

**Total: 13 weapon entries — 5 LMG + 5 HRF + 2 GRL + 1 HMG.**

The identifiers (such as `LMG01` and `HRF05`) are the internal DataTable row names. The names beside them are the corresponding in-game weapon names. The mod only changes character compatibility; it does not rename weapons or alter their stats.

`LMG05` is intentionally not included.

## Requirements

- The Forever Winter
- **UE4SS 4.0.0**

No additional mods or DLC are required. TFWWorkbench is not required.

## Installation

1. Install and configure **UE4SS 4.0.0** for The Forever Winter.
2. Download this repository or the mod archive.
3. Copy the `ScavGirlHeavyWeapons` folder into the game's UE4SS `Mods` directory. Keep the folder structure and capitalization:

   ```text
   The Forever Winter/
   └── Windows/
       └── ForeverWinter/
           └── Binaries/
               └── Win64/
                   └── Mods/
                       └── ScavGirlHeavyWeapons/
                           └── Scripts/
                               └── main.lua
   ```

4. Open `Win64/Mods/mods.txt`.
5. Add this line if it is not already present:

   ```text
   ScavGirlHeavyWeapons : 1
   ```

   Do not add the line twice. Keep the existing entries for your other mods.

6. Fully restart the game. UE4SS loads the Lua script when the mod starts.

## Confirming that it loaded

Open the UE4SS log and search for `[SGHW]`. A successful run should finish with a summary similar to:

```text
[SGHW] ScavGirlHeavyWeapons v1.2.0
[SGHW] Starting weapon compatibility patch
...
[SGHW] PATCH FINISHED
[SGHW] Successful: 13/13
[SGHW] Failed: 0/13
```

The summary above is the expected result when all 13 rows are found and patched or already contain the Scav Girl tag. It is an example, not a claim that a 13/13 runtime log has been independently verified.

Rows that already contain `Pawn.Player.Girl` are reported as `SKIP: Girl tag already exists`. This is expected and prevents duplicate tags.

## What the mod changes

For each listed row in:

```text
/Game/Blueprints/Data/WeaponsDetailsData.WeaponsDetailsData
```

the script reads `AllowTags.GameplayTags`, preserves the existing tags, and adds:

```text
Pawn.Player.Girl
```

It then reads the array again to verify the change. If verification fails, it attempts to restore the original tag list.

### Scope and limitations

- Only the 13 explicitly listed weapon rows are modified.
- Existing allowed-character tags are preserved.
- No other playable character is intentionally changed.
- The patch changes character compatibility tags; it does **not** grant weapon items to the inventory.
- Separate weapon-skill, progression, animation, IK, or camera systems are not modified.
- The change is applied in memory when the mod loads. It is reapplied on each game launch and does not permanently edit the game's asset files or save data.
- Painless (HMG01) is experimental: it can be equipped by Scav Girl, but causes character positioning and camera clipping problems.
- This mod has been developed and tested with UE4SS 4.0.0. Other UE4SS versions are not covered by the test results.

## Testing status

- **v1.1.0:** runtime patching of the 12 configured LMG, HRF and GRL rows was confirmed: 12/12 successful, 0 failures. GRL weapons were also confirmed usable in the loadout.
- **v1.2.0:** Painless (HMG01) was added and confirmed equippable by Scav Girl. Its positioning and camera issue remains unresolved.
- A full 13/13 runtime verification log for v1.2.0 has not yet been documented.

## Troubleshooting

### The mod does not appear in the log

- Confirm UE4SS 4.0.0 is installed and working.
- Confirm the mod folder is named exactly `ScavGirlHeavyWeapons`.
- Confirm the script path is exactly `Scripts/main.lua` (capital **S**).
- Confirm `ScavGirlHeavyWeapons : 1` is present in `Win64/Mods/mods.txt`.
- Fully restart the game after changing the script or mod configuration.

### The log reports that WeaponsDetailsData was not found

The DataTable may not be available when the script runs, or the game build may have changed its asset path. Check the UE4SS log and report the game version and the complete `[SGHW]` output before changing the asset path.

### One or more rows fail

Search the log for `ERROR:` and provide the complete `[SGHW]` section. Do not manually replace other DataTable fields; the script is designed to change only the selected tag arrays.

### Painless causes character or camera positioning problems

This is a known issue in v1.2.0. The compatibility tag allows Scav Girl to equip Painless, but the weapon's character positioning/animation setup is not fixed by this mod yet. If this issue is unacceptable, avoid equipping HMG01 until a fix is released.

## Development notes

The implementation uses UE4SS Lua reflection:

- `StaticFindObject` to locate the DataTable.
- `FindRow` to access each row.
- `TArray:ForEach` to enumerate GameplayTags.
- `FName` values to build the replacement tag list.
- Post-write verification and a rollback attempt if verification fails.

The project is intentionally standalone and does not use TFWWorkbench.

## Credits

Game assets and trademarks belong to their respective owners. This project is an unofficial community mod and is not affiliated with or endorsed by the developers or publishers of The Forever Winter.
