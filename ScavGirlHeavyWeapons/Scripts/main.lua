-- ScavGirlHeavyWeapons v1.0.0
-- The Forever Winter | UE4SS 4.0.0
--
-- Adds Scav Girl (Pawn.Player.Girl) to the AllowTags list for the
-- selected LMG and HRF weapon rows in WeaponsDetailsData.
-- Existing character tags are preserved. No other character is modified.

local PREFIX = "[SGHW] "
local GIRL_TAG = "Pawn.Player.Girl"

local WEAPONS = {
    -- Light machine guns
    "LMG01",
    "LMG02",
    "LMG03",
    "LMG04",
    "LMG06",

    -- Heavy rifle / HRF weapons
    "HRF01",
    "HRF02",
    "HRF03",
    "HRF04",
    "HRF05"
}

local function log(message)
    print(PREFIX .. tostring(message))
end

local function patchWeapon(dataTable, weaponCode)
    log("--------------------------------")
    log("Processing: " .. weaponCode)

    local okRow, row = pcall(function()
        return dataTable:FindRow(weaponCode)
    end)

    if not okRow or not row then
        log("ERROR: Row not found: " .. weaponCode)
        return false
    end

    local okTags, tags = pcall(function()
        return row.AllowTags.GameplayTags
    end)

    if not okTags or not tags then
        log("ERROR: Cannot access GameplayTags: " .. weaponCode)
        return false
    end

    local original = {}
    local foundGirl = false

    local readOK, readError = pcall(function()
        tags:ForEach(function(index, element)
            local tag = element:get()
            local name = tag.TagName:ToString()

            original[#original + 1] = {
                TagName = FName(name)
            }

            if name == GIRL_TAG then
                foundGirl = true
            end
        end)
    end)

    if not readOK then
        log("ERROR: Cannot read tags: " .. tostring(readError))
        return false
    end

    if foundGirl then
        log("SKIP: Girl tag already exists")
        return true
    end

    -- Preserve all existing allowed-character tags and append Scav Girl.
    local replacement = {}

    for _, entry in ipairs(original) do
        replacement[#replacement + 1] = entry
    end

    replacement[#replacement + 1] = {
        TagName = FName(GIRL_TAG)
    }

    local writeOK, writeError = pcall(function()
        row.AllowTags.GameplayTags = replacement
    end)

    if not writeOK then
        log("ERROR: Write failed: " .. tostring(writeError))
        return false
    end

    -- Verify the updated array before reporting success.
    local verifyFound = false
    local verifyCount = 0

    local verifyOK, verifyError = pcall(function()
        local updated = row.AllowTags.GameplayTags

        updated:ForEach(function(index, element)
            local tag = element:get()
            local name = tag.TagName:ToString()

            verifyCount = verifyCount + 1

            if name == GIRL_TAG then
                verifyFound = true
            end
        end)
    end)

    if verifyOK and verifyFound and verifyCount == (#original + 1) then
        log("SUCCESS: " .. weaponCode .. " unlocked for Scav Girl")
        log("Total allowed characters: " .. verifyCount)
        return true
    end

    log("ERROR: Verification failed: " .. tostring(verifyError))

    -- Restore the original tag list if verification fails.
    local rollbackOK, rollbackError = pcall(function()
        row.AllowTags.GameplayTags = original
    end)

    log("ROLLBACK: " .. tostring(rollbackOK))

    if not rollbackOK then
        log("ROLLBACK ERROR: " .. tostring(rollbackError))
    end

    return false
end

log("================================")
log("ScavGirlHeavyWeapons v1.0.0")
log("Starting weapon compatibility patch")
log("Target: " .. GIRL_TAG)
log("================================")

local okDT, dataTable = pcall(function()
    return StaticFindObject(
        "/Game/Blueprints/Data/WeaponsDetailsData.WeaponsDetailsData"
    )
end)

if not okDT or not dataTable or not dataTable:IsValid() then
    log("FATAL: WeaponsDetailsData not found")
    return
end

local successCount = 0
local failureCount = 0

for _, weaponCode in ipairs(WEAPONS) do
    if patchWeapon(dataTable, weaponCode) then
        successCount = successCount + 1
    else
        failureCount = failureCount + 1
    end
end

log("================================")
log("PATCH FINISHED")
log("Successful: " .. successCount .. "/" .. #WEAPONS)
log("Failed: " .. failureCount .. "/" .. #WEAPONS)
log("================================")
