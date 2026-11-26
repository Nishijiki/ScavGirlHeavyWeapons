# Changelog

## 1.3.0

- Added automatic monitoring of all 13 configured weapon compatibility entries.
- Added detection of missing Scav Girl (`Pawn.Player.Girl`) tags in `WeaponsDetailsData`.
- Added automatic reapplication of missing permissions without rewriting entries that are already correct.
- Added DataTable reacquisition on each monitoring cycle to handle temporary object unavailability or reloads.
- Added post-recovery verification and clearer recovery status logging.
- Preserved existing character tags and retained rollback behavior when a write cannot be verified.
- Confirmed in-game that the automatic monitoring/recovery update works during character switching.
- Painless (HMG01) remains experimental; character positioning and camera clipping issues are not fixed.

## 1.2.0

- Added Scav Girl compatibility for HMG01 (Painless).
- Painless unlock was tested in-game; the weapon can be equipped by Scav Girl.
- Marked Painless as experimental due to character positioning and camera clipping issues.
- No animation or camera fix is included in this version.

## 1.1.0

- Added Scav Girl compatibility for GRL01 and GRL02.
- Preserved all existing character tags and restrictions for other characters.
- Verified successful runtime patching of all 12 configured weapon rows with UE4SS 4.0.0 (12/12, 0 failures).

## 1.0.0

- Initial documented release of ScavGirlHeavyWeapons.
- Added Scav Girl compatibility for LMG01, LMG02, LMG03, LMG04, and LMG06.
- Added Scav Girl compatibility for HRF01, HRF02, HRF03, HRF04, and HRF05 (AT-43 MASS).
- Preserved existing character tags.
- Added duplicate-tag detection, post-write verification, and rollback attempt on verification failure.
- Confirmed successful processing of all 10 rows with UE4SS 4.0.0 (10/10, 0 failures).
