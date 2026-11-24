# ScavGirlHeavyWeapons

**Standalone UE4SS Lua mod for The Forever Winter.** Adds Scav Girl to the allowed-character tags for selected LMG and HRF weapons.

- **Target character:** Scav Girl — `Pawn.Player.Girl`
- **UE4SS:** 4.0.0
- **Game engine observed during development:** Unreal Engine 5.4
- **Dependency:** UE4SS only
- **TFWWorkbench:** not required

## Supported weapons

The mod patches these ten rows in `WeaponsDetailsData`:

| Category | DataTable row |
|---|---|
| LMG | `LMG01` |
| LMG | `LMG02` |
| LMG | `LMG03` |
| LMG | `LMG04` |
| LMG | `LMG06` |
| HRF | `HRF01` |
| HRF | `HRF02` |
| HRF | `HRF03` |
| HRF | `HRF04` |
| HRF | `HRF05` — AT-43 MASS |

`LMG05` is intentionally not included.

## Installation

1. Install and run **UE4SS 4.0.0** for The Forever Winter.
2. Download this repository (or clone it).
3. Copy the `ScavGirlHeavyWeapons` folder into the game's UE4SS `Mods` directory, keeping the folder structure and capitalization:

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

Open the UE4SS log and search for `[SGHW]`. A successful run ends with a summary similar to:

```text
[SGHW] ScavGirlHeavyWeapons v1.0.0
[SGHW] Starting weapon compatibility patch
...
[SGHW] PATCH FINISHED
[SGHW] Successful: 10/10
[SGHW] Failed: 0/10
```

On later launches, rows that already contain `Pawn.Player.Girl` are reported as `SKIP: Girl tag already exists`. This is expected and prevents duplicate tags.

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

- Only the ten explicitly listed weapon rows are modified.
- Existing allowed-character tags are preserved.
- No other playable character is intentionally changed.
- The patch changes character compatibility tags; it does **not** grant weapon items to the inventory.
- Separate weapon-skill, progression, or other gameplay checks are not modified by this version.
- The change is applied in memory when the mod loads. It is reapplied on each game launch and does not permanently edit the game's asset files or save data.
- This mod was tested with UE4SS 4.0.0. Other UE4SS versions are not covered by the test results.

## Troubleshooting

### The mod does not appear in the log

- Confirm UE4SS is installed and working.
- Confirm the mod folder is named exactly `ScavGirlHeavyWeapons`.
- Confirm the script path is exactly `Scripts/main.lua` (capital **S**).
- Confirm `ScavGirlHeavyWeapons : 1` is present in `Win64/Mods/mods.txt`.
- Fully restart the game after changing the script or mod configuration.

### The log reports that WeaponsDetailsData was not found

The DataTable may not be available when the script runs, or the game build may have changed its asset path. Check the UE4SS log and report the game version and the complete `[SGHW]` output before changing the asset path.

### One or more rows fail

Search the log for `ERROR:` and provide the complete `[SGHW]` section. Do not manually replace other DataTable fields; the script is designed to change only the selected tag arrays.

## Development notes

The implementation uses UE4SS Lua reflection:

- `StaticFindObject` to locate the DataTable.
- `FindRow` to access each row.
- `TArray:ForEach` to enumerate GameplayTags.
- `FName` values to build the replacement tag list.

The project is intentionally standalone and does not use TFWWorkbench.

## Credits


Game assets and trademarks belong to their respective owners. This project is an unofficial community mod and is not affiliated with or endorsed by the developers or publishers of The Forever Winter.
