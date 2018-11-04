-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

Cool.Settings = {}

local WM = WINDOW_MANAGER
local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type        = "panel",
    name        = "Cooldowns",
    displayName = "Cooldowns",
    author      = "g4rr3t (NA)",
    version     = Cool.version,
    registerForRefresh  = true,
}

-- Set Submenu
local function GetSetName(setKey)
    local color = Cool.Data.Sets[setKey].settingsColor
    return zo_strformat("|c<<1>><<2>>|r", color, setKey)
end

-- Description
local function GetDescription(setKey)
    return Cool.Data.Sets[setKey].description
end

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

-- Enabled State
local function GetEnabledState(setKey)
    return Cool.Data.Sets[setKey].enabled
end

local function SetEnabledState(setKey, state)
    Cool.synergyPrefs[setKey] = state
    Cool.Tracking.EnableTrackingForSet(setKey, state)
end

-- Enabled Status
local function GetIsEnabled(setKey)
    return Cool.Data.Sets[setKey].enabled
end

-- Display Size
local function GetSize(setKey)
    return Cool.preferences.sets[setKey].size
end

local function SetSize(setKey, size)
    local context = WM:GetControlByName(setKey .. "_Container")

    Cool.preferences.sets[setKey].size = size

    if context ~= nil then
        context:SetScale(size / Cool.UI.scaleBase)
    end
end

-- OnProc Sound Settings
local function GetOnProcEnabled(setKey)
    return Cool.preferences.sets[setKey].sounds.onProc.enabled
end

local function SetOnProcEnabled(setKey, enabled)
    Cool.preferences.sets[setKey].sounds.onProc.enabled = enabled
end

-- OnReady Sound Settings
local function GetOnReadyEnabled(setKey)
    return Cool.preferences.sets[setKey].sounds.onReady.enabled
end

local function SetOnReadyEnabled(setKey, enabled)
    Cool.preferences.sets[setKey].sounds.onReady.enabled = enabled
end

-- Test Sound
local function PlayTestSound(setKey, condition)
    local sound = Cool.preferences.sets[setKey].sounds[condition].sound

    Cool:Trace(2, "Testing sound <<1>>", sound)

    Cool.UI.PlaySound(sound)
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

-- Initialize
function Cool.Settings.Init()

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
            type = "header",
            name = "Sets",
            width = "full",
        },
    }

    -- Copy key/value table to index/value table
    settingsSetTable = {}
    settingsSynergyTable = {}
    for key, set in pairs(Cool.Data.Sets) do
        if set.isSynergy then
            table.insert(settingsSynergyTable, {
                name = key,
            })
        else
            table.insert(settingsSetTable, {
                name = key,
            })
        end
    end

    -- Sort settings tables alphabetically
    table.sort(settingsSetTable, function(x, y)
        return x.name < y.name
    end)

    table.sort(settingsSynergyTable, function(x, y)
        return x.name < y.name
    end)

    for index, set in ipairs(settingsSetTable) do
        table.insert(optionsTable, {
            type = "submenu",
            name = function() return GetSetName(set.name) end,
            controls = {
                {
                    type = "description",
                    text = function() return GetDescription(set.name) end,
                    width = "full",
                },
                --[[ {
                    type = "button",
                    name = function() return GetEnabledState(set.name) end,
                    func = function() return end,
                    width = "full",
                    disabled = true,
                }, ]]
                {
                    type = "slider",
                    name = "Size",
                    getFunc = function() return GetSize(set.name) end,
                    setFunc = function(size) SetSize(set.name, size) end,
                    min = 32,
                    max = 150,
                    step = 1,
                    clampInput = true,
                    decimals = 0,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Play Sound On Proc",
                    tooltip = "Set to ON to play a sound when the set procs.",
                    getFunc = function() return GetOnProcEnabled(set.name) end,
                    setFunc = function(value) SetOnProcEnabled(set.name, value) end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Sound On Proc",
                    choices = Cool.Sounds.names,
                    choicesValues = Cool.Sounds.options,
                    getFunc = function() return Cool.preferences.sets[set.name].sounds.onProc.sound end,
                    setFunc = function(value) Cool.preferences.sets[set.name].sounds.onProc.sound = value end,
                    tooltip = "Sound volume based on Interface volume setting.",
                    sort = "name-up",
                    width = "full",
                    scrollable = true,
                    disabled = function() return not GetOnProcEnabled(set.name) end,
                },
                {
                    type = "button",
                    name = "Test Sound",
                    func = function() PlayTestSound(set.name, 'onProc') end,
                    width = "full",
                    disabled = function() return not GetOnProcEnabled(set.name) end,
                },
                {
                    type = "checkbox",
                    name = "Play Sound On Ready",
                    tooltip = "Set to ON to play a sound when the set is off cooldown and ready to proc again.",
                    getFunc = function() return GetOnReadyEnabled(set.name) end,
                    setFunc = function(value) SetOnReadyEnabled(set.name, value) end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Sound On Ready",
                    choices = Cool.Sounds.names,
                    choicesValues = Cool.Sounds.options,
                    getFunc = function() return Cool.preferences.sets[set.name].sounds.onReady.sound end,
                    setFunc = function(value) Cool.preferences.sets[set.name].sounds.onReady.sound = value end,
                    tooltip = "Sound volume based on game interface volume setting.",
                    sort = "name-up",
                    width = "full",
                    scrollable = true,
                    disabled = function() return not GetOnReadyEnabled(set.name) end,
                },
                {
                    type = "button",
                    name = "Test Sound",
                    func = function() PlayTestSound(set.name, 'onReady') end,
                    width = "full",
                    disabled = function() return not GetOnReadyEnabled(set.name) end,
                },
            },
        })
    end

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        height = 16,
        alpha = 0,
    })
    table.insert(optionsTable, {
        type = "header",
        name = "Synergies",
        width = "full",
    })

    for index, set in ipairs(settingsSynergyTable) do
        table.insert(optionsTable, {
            type = "submenu",
            name = function() return GetSetName(set.name) end,
            controls = {
                {
                    type = "description",
                    text = function() return GetDescription(set.name) end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Tracking",
                    tooltip = "Set to ON to enable tracking for this synergy.",
                    getFunc = function() return GetEnabledState(set.name) end,
                    setFunc = function(value) SetEnabledState(set.name, value) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Size",
                    getFunc = function() return GetSize(set.name) end,
                    setFunc = function(size) SetSize(set.name, size) end,
                    min = 32,
                    max = 150,
                    step = 1,
                    clampInput = true,
                    decimals = 0,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Play Sound On Use",
                    tooltip = "Set to ON to play a sound when the synergy is used.",
                    getFunc = function() return GetOnProcEnabled(set.name) end,
                    setFunc = function(value) SetOnProcEnabled(set.name, value) end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Sound On Use",
                    choices = Cool.Sounds.names,
                    choicesValues = Cool.Sounds.options,
                    getFunc = function() return Cool.preferences.sets[set.name].sounds.onProc.sound end,
                    setFunc = function(value) Cool.preferences.sets[set.name].sounds.onProc.sound = value end,
                    tooltip = "Sound volume based on Interface volume setting.",
                    sort = "name-up",
                    width = "full",
                    scrollable = true,
                    disabled = function() return not GetOnProcEnabled(set.name) end,
                },
                {
                    type = "button",
                    name = "Test Sound",
                    func = function() PlayTestSound(set.name, 'onProc') end,
                    width = "full",
                    disabled = function() return not GetOnProcEnabled(set.name) end,
                },
                {
                    type = "checkbox",
                    name = "Play Sound On Ready",
                    tooltip = "Set to ON to play a sound when the synergy is off cooldown and ready to be used again.",
                    getFunc = function() return GetOnReadyEnabled(set.name) end,
                    setFunc = function(value) SetOnReadyEnabled(set.name, value) end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Sound On Ready",
                    choices = Cool.Sounds.names,
                    choicesValues = Cool.Sounds.options,
                    getFunc = function() return Cool.preferences.sets[set.name].sounds.onReady.sound end,
                    setFunc = function(value) Cool.preferences.sets[set.name].sounds.onReady.sound = value end,
                    tooltip = "Sound volume based on game interface volume setting.",
                    sort = "name-up",
                    width = "full",
                    scrollable = true,
                    disabled = function() return not GetOnReadyEnabled(set.name) end,
                },
                {
                    type = "button",
                    name = "Test Sound",
                    func = function() PlayTestSound(set.name, 'onReady') end,
                    width = "full",
                    disabled = function() return not GetOnReadyEnabled(set.name) end,
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
end

