-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

Cool = Cool or {}
Cool.Settings = {}

local WM = WINDOW_MANAGER
local LAM = LibAddonMenu2
local scaleBase = Cool.UI.scaleBase

local panelData = {
    type        = "panel",
    name        = "Cooldowns",
    displayName = "Cooldowns",
    author      = "g4rr3t (NA)",
    version     = Cool.version,
    registerForRefresh  = true,
}


-- ============================================================================
-- Global Options
-- ============================================================================

-- Grid Options
local function GetSnapToGrid()
    return Cool.preferences.snapToGrid
end

local function SetSnapToGrid(snap)
    Cool.preferences.snapToGrid = snap
end

local function GetGridSize()
    return Cool.preferences.gridSize
end

local function SetGridSize(gridSize)
    Cool.preferences.gridSize = gridSize
end

-- Locked State
local function ToggleLocked(control)
    Cool.preferences.unlocked = not Cool.preferences.unlocked
    for key, set in pairs(Cool.Data.Sets) do
        local context = WM:GetControlByName(key .. "_Container")
        if context ~= nil then
            context:SetMovable(Cool.preferences.unlocked)
            if Cool.preferences.unlocked then
                control:SetText("Lock All")
            else
                control:SetText("Unlock All")
            end
        end
    end
end

-- Force Showing
local function ForceShow(control)
    Cool.ForceShow = not Cool.ForceShow

    if Cool.ForceShow then
        control:SetText("Hide All Enabled")
        Cool.HUDHidden = false
        Cool.UI.ShowIcon(true)
    else
        control:SetText("Show All Enabled")
        Cool.HUDHidden = true
        Cool.UI.ShowIcon(false)
    end

end

-- Combat State Display
local function GetShowOutOfCombat()
    return Cool.preferences.showOutsideCombat
end

local function SetShowOutOfCombat(value)
    Cool.preferences.showOutsideCombat = value
    Cool.UI:SetCombatStateDisplay()

    if value then
        Cool.Tracking.UnregisterCombatEvent()
    else
        Cool.Tracking.RegisterCombatEvent()
    end
end

-- Lag Compensation
local function GetLagCompensation()
    return Cool.preferences.lagCompensation
end

local function SetLagCompensation(value)
    Cool.preferences.lagCompensation = value
end

-- Audio Notifications
local function GetAudioNotifications()
    return Cool.preferences.audioNotifications
end

local function SetAudioNotifications(value)
    Cool.preferences.audioNotifications = value
end

-- Sizing
local function SetSize(setKey, size)
    local context = WM:GetControlByName(setKey .. "_Container")

    Cool.preferences.sets[setKey].size = size

    if context ~= nil then
        context:SetScale(size / scaleBase)
    end
end

local function SetTimerSize(setKey, size)
    local context = WM:GetControlByName(setKey .. "_Label")

    Cool.preferences.sets[setKey].timerSize = size

    if context ~= nil then
        context:SetFont("$(MEDIUM_FONT)|" .. size .. "|soft-shadow-thick")
    end
end


-- ============================================================================
-- Sets
-- ============================================================================

-- Selection
local default = {
    set = "-- Select a Set --",
    synergy = "-- Select a Synergy --",
    passive = "-- Select a Passive --",
}

local selected = {
    set = 0,
    synergy = 0,
    passive = 0,
}

-- Selection
local function GetSelected(procType)
    return selected[procType]
end

local function SetSelected(procType, selection)
    selected[procType] = selection
end

local function HasSelected(procType)
    if selected[procType] ~= 0 then
        return true
    else
        return false
    end
end

-- Enabled
local function GetSelectedEnabled(procType)
    if HasSelected(procType) then
        return Cool.character[procType][selected[procType]]
    else
        return false
    end
end

local function SetSelectedEnabled(procType, state)
    if procType == "set" then
        if Cool.character[procType][selected[procType]] == false and state == true then
            -- A set was forced disable, now it's on
            -- Notify player to re-equip
            Cool:Trace(0, 'Re-enabling <<1>>. You may need to take off and re-equip this set to resume tracking.', selected[procType])
            Cool.character[procType][selected[procType]] = true
            return
        elseif state == false then
            Cool:Trace(0, 'Forcing tracking off for <<1>>. It will not be tracked until you enable it again.', selected[procType])
        else
            Cool:Trace(1, 'Setting <<1>> to <<2>>', selected[procType], tostring(state))
        end
    end

    Cool.character[procType][selected[procType]] = state
    Cool.Tracking.EnableTrackingForSet(selected[procType], state, selected[procType])
end

-- Size
local function GetSelectedSize(procType)
    if HasSelected(procType) then
        return Cool.preferences.sets[selected[procType]].size
    else
        return Cool.preferences.size
    end
end
local function GetSelectedTimerSize(procType)
    if HasSelected(procType) then
        return Cool.preferences.sets[selected[procType]].timerSize
    else
        return Cool.preferences.timerSize
    end
end

local function SetSelectedSize(procType, size)
    Cool.preferences.sets[selected[procType]].size = size
    SetSize(selected[procType], size)
end

local function SetSelectedTimerSize(procType, size)
    Cool.preferences.sets[selected[procType]].timerSize = size
    SetTimerSize(selected[procType], size)
end

-- Sounds
local function GetSelectedSoundOnProcEnabled(procType)
    if HasSelected(procType) then
        return Cool.preferences.sets[selected[procType]].sounds.onProc.enabled
    else
        return Cool.preferences.sounds.onProc.enabled
    end
end

local function SetSelectedSoundOnProcEnabled(procType, enabled)
    Cool.preferences.sets[selected[procType]].sounds.onProc.enabled = enabled
end

local function GetSelectedSoundOnReadyEnabled(procType)
    if HasSelected(procType) then
        return Cool.preferences.sets[selected[procType]].sounds.onReady.enabled
    else
        return Cool.preferences.sounds.onReady.enabled
    end
end

local function SetSelectedSoundOnReadyEnabled(procType, enabled)
    Cool.preferences.sets[selected[procType]].sounds.onReady.enabled = enabled
end

local function GetSelectedSoundOnProc(procType)
    if HasSelected(procType) then
        return Cool.preferences.sets[selected[procType]].sounds.onProc.sound
    else
        return Cool.preferences.sounds.onProc.sound
    end
end

local function SetSelectedSoundOnProc(procType, sound)
    Cool.preferences.sets[selected[procType]].sounds.onProc.sound = sound
end

local function GetSelectedSoundOnReady(procType)
    if HasSelected(procType) then
        return Cool.preferences.sets[selected[procType]].sounds.onReady.sound
    else
        return Cool.preferences.sounds.onReady.sound
    end
end

local function SetSelectedSoundOnReady(procType, sound)
    Cool.preferences.sets[selected[procType]].sounds.onReady.sound = sound
end

-- Test Sound
local function PlaySelectedTestSound(procType, condition)
    local sound = Cool.preferences.sets[selected[procType]].sounds[condition]

    Cool:Trace(2, "Testing sound <<1>>", sound)

    Cool.UI.PlaySound(sound)
end

-- Disabled Controls
local function ShouldOptionBeDisabled(procType, consider)

    -- Nothing selected, always disable
    if not HasSelected(procType) then
        return true

    -- Something selected
    else

        -- If disabled, disable all fields
        if not GetSelectedEnabled(procType) then
            return true
        end

        -- If our other consideration says to disable, do it
        if consider ~= nil and not consider then
            return true
        end

    end

end

-- ============================================================================
-- Create Menu
-- ============================================================================

-- Initialize
function Cool.Settings.Init()

    -- Copy key/value table to index/value table
    local settingsBreakout = {
        set = {
            name = "|cCD5031Sets|r",
            data = {0},
            values = {default.set},
            description = {"Select a set to customize."},
        },
        synergy = {
            name = "|c92C843Synergies|r",
            data = {0},
            values = {default.synergy},
            description = {"Select a synergy to customize."},
        },
        passive = {
            name = "|c3A97CFPassives|r",
            data = {0},
            values = {default.passive},
            description = {"Select a passive to customize."},
        },
    }

    for key, set in pairs(Cool.Data.Sets) do
        if set.procType == "set" then
            table.insert(settingsBreakout.set.data, key)
            table.insert(settingsBreakout.set.values, set.name)
            table.insert(settingsBreakout.set.description, set.description)
        elseif set.procType == "synergy" then
            table.insert(settingsBreakout.synergy.data, key)
            table.insert(settingsBreakout.synergy.values, key)
            table.insert(settingsBreakout.synergy.description, set.description)
        elseif set.procType == "passive" then
            -- Only show options for current player class
            if GetUnitClassId("player") == set.classId or set.classId == 0 then
                table.insert(settingsBreakout.passive.data, key)
                table.insert(settingsBreakout.passive.values, key)
                table.insert(settingsBreakout.passive.description, set.description)
            end
        else
            Cool:Trace(1, "Invalid procType: <<1>>", set.procType)
        end
    end

    optionsTable = {
        {
            type = "header",
            name = "Global Settings",
            width = "full",
        },
        {
            type = "button",
            name = function() if Cool.ForceShow then return "Hide All Enabled" else return "Show All Enabled" end end,
            tooltip = "Force all equipped sets for positioning or previewing display settings.",
            func = function(control) ForceShow(control) end,
            width = "half",
        },
        {
            type = "button",
            name = function() if Cool.preferences.unlocked then return "Lock All" else return "Unlock All" end end,
            tooltip = "Toggle locked/unlocked state.",
            func = function(control) ToggleLocked(control) end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Lag Compensation",
            tooltip = "Attempt to adjust proc timing based on lag conditions. Set to ON if you are falsely seeing back-to-back procs and set to OFF if procs in close proximity to being ready are being missed.",
            getFunc = function() return GetLagCompensation() end,
            setFunc = function(value) SetLagCompensation(value) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable Audio Notifications",
            tooltip = "Disable audio notifications globally.",
            getFunc = function() return GetAudioNotifications() end,
            setFunc = function(value) SetAudioNotifications(value) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Outside of Combat",
            tooltip = "Set to ON to show while out of combat and OFF to only show while in combat.",
            getFunc = function() return GetShowOutOfCombat() end,
            setFunc = function(value) SetShowOutOfCombat(value) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Snap to Grid",
            tooltip = "Set to ON to snap position to the specified grid.",
            getFunc = function() return GetSnapToGrid() end,
            setFunc = function(value) SetSnapToGrid(value) end,
            width = "full",
        },
        {
            type = "slider",
            name = "Grid Size",
            tooltip = "Grid dimensions to snap positioning of display elements to.",
            getFunc = function() return GetGridSize() end,
            setFunc = function(size) SetGridSize(size) end,
            min = 1,
            max = 100,
            step = 1,
            clampInput = true,
            decimals = 0,
            width = "full",
            disabled = function() return not GetSnapToGrid() end,
        },
        {
            type = "divider",
            width = "full",
            height = 16,
            alpha = 0.25,
        }
    }

    for procType, options in pairs(settingsBreakout) do
        table.insert(optionsTable, {
                type = "submenu",
                name = options.name,
                controls = {
                    {
                        type = "dropdown",
                        name = "Option",
                        choices = options.values,
                        choicesValues = options.data,
                        getFunc = function() return GetSelected(procType) end,
                        setFunc = function(set) SetSelected(procType, set) end,
                        choicesTooltips = options.description,
                        sort = "name-up",
                        width = "full",
                        scrollable = true,
                    },
                    {
                        type = "checkbox",
                        name = "Enable Tracking",
                        tooltip = "Set to ON to enable tracking. Note: Sets will still disable automatically when not worn.",
                        getFunc = function() return GetSelectedEnabled(procType) end,
                        setFunc = function(value) SetSelectedEnabled(procType, value) end,
                        width = "full",
                        disabled = function() return not HasSelected(procType) end,
                    },
                    {
                        type = "description",
                        text = "Setting ON or OFF is per-character. All other settings (such as size, sounds, and position) apply account-wide.",
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Size",
                        getFunc = function() return GetSelectedSize(procType) end,
                        setFunc = function(size) SetSelectedSize(procType, size) end,
                        min = 32,
                        max = 150,
                        step = 1,
                        clampInput = true,
                        decimals = 0,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType) end,
                    },
                    {
                        type = "slider",
                        name = "Timer Size",
                        getFunc = function() return GetSelectedTimerSize(procType) end,
                        setFunc = function(size) SetSelectedTimerSize(procType, size) end,
                        min = 32,
                        max = 150,
                        step = 1,
                        clampInput = true,
                        decimals = 0,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType) end,
                    },
                    {
                        type = "checkbox",
                        name = "Play Sound On Proc",
                        tooltip = "Set to ON to play a sound when the set procs.",
                        getFunc = function() return GetSelectedSoundOnProcEnabled(procType) end,
                        setFunc = function(value) SetSelectedSoundOnProcEnabled(procType, value) end,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType) end,
                    },
                    {
                        type = "dropdown",
                        name = "Sound On Proc",
                        choices = Cool.Sounds.names,
                        choicesValues = Cool.Sounds.options,
                        getFunc = function() return GetSelectedSoundOnProc(procType) end,
                        setFunc = function(value) SetSelectedSoundOnProc(procType, value) end,
                        tooltip = "Sound volume based on Interface volume setting.",
                        sort = "name-up",
                        width = "full",
                        scrollable = true,
                        disabled = function() return ShouldOptionBeDisabled(procType, GetSelectedSoundOnProcEnabled(procType)) end,
                    },
                    {
                        type = "button",
                        name = "Test Sound",
                        func = function() return end,
                        func = function() PlaySelectedTestSound(procType, "onProc") end,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType, GetSelectedSoundOnProcEnabled(procType)) end,
                    },
                    {
                        type = "checkbox",
                        name = "Play Sound On Ready",
                        tooltip = "Set to ON to play a sound when the set is off cooldown and ready to proc again.",
                        getFunc = function() return GetSelectedSoundOnReadyEnabled(procType) end,
                        setFunc = function(value) SetSelectedSoundOnReadyEnabled(procType, value) end,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType) end,
                    },
                    {
                        type = "dropdown",
                        name = "Sound On Ready",
                        choices = Cool.Sounds.names,
                        choicesValues = Cool.Sounds.options,
                        getFunc = function() return GetSelectedSoundOnReady(procType) end,
                        setFunc = function(value) SetSelectedSoundOnReady(procType, value) end,
                        tooltip = "Sound volume based on game interface volume setting.",
                        sort = "name-up",
                        width = "full",
                        scrollable = true,
                        disabled = function() return ShouldOptionBeDisabled(procType, GetSelectedSoundOnReadyEnabled(procType)) end,
                    },
                    {
                        type = "button",
                        name = "Test Sound",
                        func = function() PlaySelectedTestSound(procType, "onReady") end,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType, GetSelectedSoundOnReadyEnabled(procType)) end,
                    },
                },
        })
    end

    LAM:RegisterAddonPanel(Cool.name, panelData)
    LAM:RegisterOptionControls(Cool.name, optionsTable)

    Cool:Trace(2, "Finished InitSettings()")
end

function Cool.Settings.Upgrade()
    -- v1.1.0 changes setKey names, restore previous user settings
    if Cool.preferences.upgradedv110 == nil or not Cool.preferences.upgradedv110 then
        local previousSetKeys = {
            ["Lich"] = "Shroud of the Lich",
            ["Olorime"] = "Vestment of Olorime",
            ["Trappings"] = "Trappings of Invigoration",
            ["Warlock"] = "Vestments of the Warlock",
            ["Wyrd"] = "Wyrd Tree's Blessing",
        }

        for previous, new in pairs(previousSetKeys) do
            if Cool.preferences.sets[previous] ~= nil then
                Cool.preferences.sets[new] = Cool.preferences.sets[previous]
                Cool.preferences.sets[previous] = nil
            end
        end

        d("[Cooldowns] Upgraded settings to v1.1.0")
        Cool.preferences.upgradedv110 = true
    end

    -- v1.6.0 changes character settings, migrate
    if Cool.character.upgradedv154 == nil or not Cool.character.upgradedv154 then

        for key, set in pairs(Cool.Data.Sets) do
            if Cool.character[key] ~= nil then

                if set.procType == "synergy" then
                    Cool.character.synergy[key] = Cool.character[key]
                elseif set.procType == "passive" then
                    Cool.character.passive[key] = Cool.character[key]
                elseif set.procType == "set" then
                    Cool.character.set[key] = true
                else
                    -- Unsupported procType
                end

                Cool.character[key] = nil
            end
        end

        Cool:Trace(0, "Upgraded character settings to v1.6.0")
        Cool.character.upgradedv154 = true
    end
end
