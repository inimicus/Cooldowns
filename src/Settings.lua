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
local LAM = LibStub("LibAddonMenu-2.0")
local scaleBase = Cool.UI.scaleBase

local panelData = {
    type        = "panel",
    name        = "Cooldowns",
    displayName = "Cooldowns",
    author      = "g4rr3t (NA)",
    version     = Cool.version,
    registerForRefresh  = true,
    website     = "",
}

-- Set Submenu
local function GetSetName(setKey, setName, isSynergy)
    isSynergy = isSynergy or false
    local color = Cool.Data.Sets[setKey].settingsColor
    --Synergy? Use localized name
    if isSynergy == true then
        local setData = Cool.Data.Sets
        local setNameSynergy = setData[setKey].name[Cool.clientLang] or setName
        if setNameSynergy ~= nil and setNameSynergy ~= "" and setNameSynergy ~= setName then
            setName = setNameSynergy
        end
    end
    return zo_strformat("|c<<1>><<2>>|r", color, setName)
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
        context:SetScale(size / scaleBase)
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

    --Addon panels were loaded
    local function updateSliderLabelText(setKey, type)
        local setSoundOnProcSlider = WINDOW_MANAGER:GetControlByName("Cooldowns_Settings_PlaySound" .. tostring(type) .. "_" .. tostring(setKey), "")
        if setSoundOnProcSlider then
            setSoundOnProcSlider.label:SetText("Selected: " .. tostring(Cool.Sounds[Cool.preferences.sets[setKey].sounds[type].sound]))
        end
    end
    local function addonMenuOnLoadCallback(panel)
        if panel == Cool.LAMpanel then
            for index, set in ipairs(Cool.settingsSetTable) do
                updateSliderLabelText(set.key, "onProc")
            end
            for index, set in ipairs(Cool.settingsSynergyTable) do
                updateSliderLabelText(set.key, "onReady")
            end
            CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)
        end
    end

    local optionsTable = {
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
    Cool.settingsSetTable = {}
    Cool.settingsSynergyTable = {}
    for key, set in pairs(Cool.Data.Sets) do
        if set.isSynergy then
            table.insert(Cool.settingsSynergyTable, {
                name = key,
                key = key,
            })
        else
            table.insert(Cool.settingsSetTable, {
                name = set.name,
                key = key,
            })
        end
    end

    -- Sort settings tables alphabetically
    table.sort(Cool.settingsSetTable, function(x, y)
        return x.name < y.name
    end)

    table.sort(Cool.settingsSynergyTable, function(x, y)
        return x.name < y.name
    end)

    for index, set in ipairs(Cool.settingsSetTable) do
        table.insert(optionsTable, {
            type = "submenu",
            name = function() return GetSetName(set.key, set.name) end,
            controls = {
                {
                    type = "description",
                    text = function() return GetDescription(set.key) end,
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
                    getFunc = function() return GetSize(set.key) end,
                    setFunc = function(size) SetSize(set.key, size) end,
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
                    getFunc = function() return GetOnProcEnabled(set.key) end,
                    setFunc = function(value) SetOnProcEnabled(set.key, value) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Sound On Proc",
                    min = 1,
                    max = #Cool.Sounds,
                    step = 1,
                    getFunc = function() return Cool.preferences.sets[set.key].sounds.onProc.sound end,
                    setFunc = function(value)
                        Cool.preferences.sets[set.key].sounds.onProc.sound = value
                        updateSliderLabelText(set.key, "onProc")
                        if value ~= 1 and SOUNDS ~= nil and SOUNDS[Cool.Sounds[value]] ~= nil then
                            Cool.UI.PlaySound(Cool.Sounds[value])
                        end
                    end,
                    tooltip = "Sound volume based on Interface volume setting.",
                    width = "full",
                    disabled = function() return not GetOnProcEnabled(set.key) end,
                    reference = "Cooldowns_Settings_PlaySoundonProc_" .. tostring(set.key),
                },
                {
                    type = "checkbox",
                    name = "Play Sound On Ready",
                    tooltip = "Set to ON to play a sound when the set is off cooldown and ready to proc again.",
                    getFunc = function() return GetOnReadyEnabled(set.key) end,
                    setFunc = function(value) SetOnReadyEnabled(set.key, value) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Sound On Ready",
                    min = 1,
                    max = #Cool.Sounds,
                    step = 1,
                    getFunc = function() return Cool.preferences.sets[set.key].sounds.onReady.sound end,
                    setFunc = function(value)
                        Cool.preferences.sets[set.key].sounds.onReady.sound = value
                        updateSliderLabelText(set.key, "onReady")
                        if value ~= 1 and SOUNDS ~= nil and SOUNDS[Cool.Sounds[value]] ~= nil then
                            Cool.UI.PlaySound(Cool.Sounds[value])
                        end
                    end,
                    tooltip = "Sound volume based on game interface volume setting.",
                    width = "full",
                    disabled = function() return not GetOnReadyEnabled(set.key) end,
                    reference = "Cooldowns_Settings_PlaySoundonReady_" .. tostring(set.key),
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

    for index, set in ipairs(Cool.settingsSynergyTable) do
        table.insert(optionsTable, {
            type = "submenu",
            name = function() return GetSetName(set.key, set.name, set.isSynergy) end,
            controls = {
                {
                    type = "description",
                    text = function() return GetDescription(set.key) end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Tracking",
                    tooltip = "Set to ON to enable tracking for this synergy.",
                    getFunc = function() return GetEnabledState(set.key) end,
                    setFunc = function(value) SetEnabledState(set.key, value) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Size",
                    getFunc = function() return GetSize(set.key) end,
                    setFunc = function(size) SetSize(set.key, size) end,
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
                    getFunc = function() return GetOnProcEnabled(set.key) end,
                    setFunc = function(value) SetOnProcEnabled(set.key, value) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Sound On Use",
                    min = 1,
                    max = #Cool.Sounds,
                    step = 1,
                    getFunc = function() return Cool.preferences.sets[set.key].sounds.onProc.sound end,
                    setFunc = function(value)
                        Cool.preferences.sets[set.key].sounds.onProc.sound = value
                        updateSliderLabelText(set.key, "onProc")
                        if value ~= 1 and SOUNDS ~= nil and SOUNDS[Cool.Sounds[value]] ~= nil then
                            Cool.UI.PlaySound(Cool.Sounds[value])
                        end
                    end,
                    tooltip = "Sound volume based on Interface volume setting.",
                    width = "full",
                    disabled = function() return not GetOnProcEnabled(set.key) end,
                    reference = "Cooldowns_Settings_PlaySoundonProc_" .. tostring(set.key),
                },
                {
                    type = "checkbox",
                    name = "Play Sound On Ready",
                    tooltip = "Set to ON to play a sound when the synergy is off cooldown and ready to be used again.",
                    getFunc = function() return GetOnReadyEnabled(set.key) end,
                    setFunc = function(value) SetOnReadyEnabled(set.key, value) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Sound On Ready",
                    min = 1,
                    max = #Cool.Sounds,
                    step = 1,
                    getFunc = function() return Cool.preferences.sets[set.key].sounds.onReady.sound end,
                    setFunc = function(value)
                        Cool.preferences.sets[set.key].sounds.onReady.sound = value
                        updateSliderLabelText(set.key, "onReady")
                        if value ~= 1 and SOUNDS ~= nil and SOUNDS[Cool.Sounds[value]] ~= nil then
                            Cool.UI.PlaySound(Cool.Sounds[value])
                        end
                    end,
                    tooltip = "Sound volume based on game interface volume setting.",
                    width = "full",
                    disabled = function() return not GetOnReadyEnabled(set.key) end,
                    reference = "Cooldowns_Settings_PlaySoundonReady_" .. tostring(set.key),
                },
            },
        })
    end

    Cool.LAMpanel = LAM:RegisterAddonPanel(Cool.name, panelData)
    LAM:RegisterOptionControls(Cool.name, optionsTable)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)

    Cool:Trace(2, "Finished InitSettings()")
end

function Cool.Settings.Upgrade()
    -- v1.1.0 changes setKey names, restore previous user settings
    if Cool.preferences.upgradedv110 == nil or not Cool.preferences.upgradedv110 then
        local previousStringSetKeys2NewSetIds = {
            ["Lich"]        = 134,
            ["Olorime"]     = 391,
            ["Trappings"]   = 344,
            ["Warlock"]     = 19,
            ["Wyrd"]        = 344,
        }
        for previous, new in pairs(previousStringSetKeys2NewSetIds) do
            if Cool.preferences.sets[previous] ~= nil then
                Cool.preferences.sets[new] = Cool.preferences.sets[previous]
                Cool.preferences.sets[previous] = nil
            end
        end
        d("[Cooldowns] Upgraded settings to v" .. tostring(Cool.version))
        Cool.preferences.upgradedv110 = true
    end
end