-- ScavGirlHeavyWeapons v1.3.0
-- The Forever Winter | UE4SS 4.0.0
--
-- Adds Scav Girl (Pawn.Player.Girl) to the AllowTags list for the
-- selected LMG, HRF, GRL and HMG weapon rows in WeaponsDetailsData.
-- Existing character tags are preserved. No other character is modified.
--
-- v1.3.0:
-- - Periodically checks all configured weapon rows.
-- - Detects missing Scav Girl compatibility tags.
-- - Reapplies only missing permissions automatically.
-- - Reacquires the DataTable on every monitoring cycle.
-- - Verifies recovery and avoids routine log spam.
--
-- HMG01 (Painless) remains an experimental unlock.
-- Character animation/positioning/camera issues are not fixed.

local PREFIX = "[SGHW] "
local GIRL_TAG = "Pawn.Player.Girl"
local MONITOR_INTERVAL = 3000

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
    "HRF05",

    -- GRL weapons
    "GRL01",
    "GRL02",

    -- Heavy machine gun (experimental)
    "HMG01"
}

local monitoringStarted = false
local lastRecoveryState = nil

local function log(message)
    print(PREFIX .. tostring(message))
end

local function getDataTable()
    local ok, dataTable = pcall(function()
        return StaticFindObject(
            "/Game/Blueprints/Data/WeaponsDetailsData.WeaponsDetailsData"
        )
    end)

    if not ok or not dataTable then
        return nil
    end

    local validOK, isValid = pcall(function()
        return dataTable:IsValid()
    end)

    if not validOK or not isValid then
        return nil
    end

    return dataTable
end

local function readTags(row)
    local tags = row.AllowTags.GameplayTags
    local result = {}
    local foundGirl = false

    tags:ForEach(function(index, element)
        local tag = element:get()
        local name = tag.TagName:ToString()

        result[#result + 1] = {
            TagName = FName(name)
        }

        if name == GIRL_TAG then
            foundGirl = true
        end
    end)

    return result, foundGirl
end

local function verifyWeapon(dataTable, weaponCode)
    local ok, row = pcall(function()
        return dataTable:FindRow(weaponCode)
    end)

    if not ok or not row then
        return false
    end

    local readOK, _, foundGirl = pcall(function()
        return readTags(row)
    end)

    return readOK and foundGirl
end

local function patchWeapon(dataTable, weaponCode, quiet)
    local function report(message)
        if not quiet then
            log(weaponCode .. ": " .. message)
        end
    end

    local okRow, row = pcall(function()
        return dataTable:FindRow(weaponCode)
    end)

    if not okRow or not row then
        report("ERROR - Row not found")
        return false
    end

    local okRead, original, foundGirl = pcall(function()
        return readTags(row)
    end)

    if not okRead or not original then
        report("ERROR - Failed to read GameplayTags")
        return false
    end

    if foundGirl then
        report("Already unlocked")
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
        report("ERROR - Write failed: " .. tostring(writeError))
        return false
    end

    -- Verify the patched row.
    local verifyOK, _, verifyGirl = pcall(function()
        return readTags(row)
    end)

    if verifyOK and verifyGirl then
        report("PATCH SUCCESS")
        return true
    end

    -- Restore the original tag list if verification fails.
    local rollbackOK, rollbackError = pcall(function()
        row.AllowTags.GameplayTags = original
    end)

    report("Verification failed; rollback: " .. tostring(rollbackOK))

    if not rollbackOK then
        log("WARNING - Rollback failed for " .. weaponCode ..
            ": " .. tostring(rollbackError))
    end

    return false
end

local function applyInitialPatch(dataTable)
    log("Applying initial weapon patch...")

    local successful = 0
    local failed = 0

    for _, weaponCode in ipairs(WEAPONS) do
        if patchWeapon(dataTable, weaponCode, false) then
            successful = successful + 1
        else
            failed = failed + 1
        end
    end

    log("Initial patch result: " .. successful .. "/" .. #WEAPONS)
    log("Initial failures: " .. failed)

    return successful, failed
end

local function monitorAndRecover()
    -- Reacquire the DataTable in case the game reloads its object.
    local dataTable = getDataTable()

    if not dataTable then
        if lastRecoveryState ~= "datatable_missing" then
            log("DataTable temporarily unavailable; waiting...")
            lastRecoveryState = "datatable_missing"
        end
        return
    end

    local missing = {}

    for _, weaponCode in ipairs(WEAPONS) do
        if not verifyWeapon(dataTable, weaponCode) then
            missing[#missing + 1] = weaponCode
        end
    end

    if #missing == 0 then
        if lastRecoveryState ~= "healthy" then
            log("Monitor: all " .. #WEAPONS ..
                " weapon permissions verified")
            lastRecoveryState = "healthy"
        end
        return
    end

    local stateKey = table.concat(missing, ",")

    if lastRecoveryState ~= stateKey then
        log("Permission loss detected!")
        log("Missing: " .. table.concat(missing, ", "))
        log("Starting automatic recovery...")
    end

    local recovered = 0

    for _, weaponCode in ipairs(missing) do
        if patchWeapon(dataTable, weaponCode, true) then
            recovered = recovered + 1
        end
    end

    local verified = 0

    for _, weaponCode in ipairs(missing) do
        if verifyWeapon(dataTable, weaponCode) then
            verified = verified + 1
        end
    end

    if verified == #missing then
        log("AUTO-RECOVERY SUCCESS: " .. verified ..
            "/" .. #missing .. " permissions restored")
        lastRecoveryState = "healthy"
    else
        log("AUTO-RECOVERY INCOMPLETE: " .. verified ..
            "/" .. #missing .. " verified (" .. recovered .. " writes succeeded)")
        lastRecoveryState = stateKey
    end
end

-- Startup
log("================================")
log("ScavGirlHeavyWeapons v1.3.0")
log("Target: " .. GIRL_TAG)
log("Weapons configured: " .. #WEAPONS)
log("================================")

local dataTable = getDataTable()

if not dataTable then
    log("FATAL: WeaponsDetailsData not found")
    return
end

applyInitialPatch(dataTable)

if not monitoringStarted then
    monitoringStarted = true

    log("Starting automatic monitor...")
    log("Monitor interval: " .. MONITOR_INTERVAL .. " ms")

    LoopAsync(MONITOR_INTERVAL, function()
        monitorAndRecover()
    end)

    log("Auto-monitor enabled")
end

log("================================")
log("Initialization complete")
log("================================")
