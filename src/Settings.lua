-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

Cool.Settings = {}

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
function Cool.Settings.GetSetName(setKey)
    local set = Cool.Tracking.Sets[setKey]
    local name = set.name
    local color = set.settingsColor

    return zo_strformat("|c<<1>><<2>>|r", color, name)
end

-- Enabled Status
function Cool.Settings.GetIsEnabled(setKey)
    return Cool.Tracking.Sets[setKey].enabled
end

-- Display Size
function Cool.Settings.GetSize(setKey)
    return Cool.preferences.sets[setKey].size
end

function Cool.Settings.SetSize(setKey, size)
    Cool.preferences.sets[setKey].size = size
end

-- OnProc Sound Settings
function Cool.Settings.GetOnProcEnabled(setKey)
    return Cool.preferences.sets[setKey].sounds.onProc.enabled
end

function Cool.Settings.SetOnProcEnabled(setKey, enabled)
    Cool.preferences.sets[setKey].sounds.onProc.enabled = enabled
end

function Cool.Settings.GetOnProcVolume(setKey)
    return Cool.preferences.sets[setKey].sounds.onProc.volume
end

function Cool.Settings.SetOnProcVolume(setKey, volume)
    Cool.preferences.sets[setKey].sounds.onProc.volume = volume
end

-- Test Sound
function Cool.Settings.PlayTestSound(setKey, condition)
    local sound = Cool.preferences.sets[setKey].sounds[condition].sound
    local volume = Cool.preferences.sets[setKey].sounds[condition].volume

    Cool:Trace(2, zo_strformat("Testing sound <<1>> at volume <<2>>", sound, volume))

    Cool.UI.PlaySound(sound, volume)
end

-- Initialize
function Cool.Settings.Init()

    soundOptions = {
        "AVA_GATE_OPENED",
    }
    soundNames = {
        "Alliance War Gate Opened",
    }
    --for soundId, soundName in pairs(SOUNDS) do
    --    table.insert(soundOptions, soundId)
    --    table.insert(soundNames, soundName)
    --end

    optionsTable = {
        [1] = {
            type = "header",
            name = "Options",
            width = "full",
        },
    }

    -- TODO: Maintain displayed order
    for key, set in pairs(Cool.Tracking.Sets) do
        table.insert(optionsTable, {
            type = "submenu",
            name = function() return Cool.Settings.GetSetName(key) end,
            controls = {
                [1] = {
                    type = "slider",
                    name = "Size",
                    getFunc = function() return Cool.Settings.GetSize(key) end,
                    setFunc = function(size) Cool.Settings.SetSize(key, size) end,
                    min = 25,
                    max = 256,
                    step = 1,
                    clampInput = true,
                    decimals = 0,
                    width = "full",
                },
                [2] = {
                    type = "checkbox",
                    name = "Play Sound On Proc",
                    getFunc = function() return Cool.Settings.GetOnProcEnabled(key) end,
                    setFunc = function(value) Cool.Settings.SetOnProcEnabled(key, value) end,
                    width = "full",
                },
                [3] = {
                    type = "slider",
                    name = "Sound On Proc Volume",
                    getFunc = function() return Cool.Settings.GetOnProcVolume(key) end,
                    setFunc = function(value) Cool.Settings.SetOnProcVolume(key, value) end,
                    min = 1,
                    max = 100,
                    step = 1,
                    clampInput = true,
                    decimals = 0,
                    --tooltip = "Slider's tooltip text.",
                    width = "full",
                    disabled = function() return not Cool.Settings.GetOnProcEnabled(key) end,
                },
                [4] = {
                    type = "dropdown",
                    name = "Sound On Proc", -- or string id or function returning a string
                    choices = soundNames,
                    choicesValues = soundOptions,
                    getFunc = function() return Cool.preferences.sets[key].sounds.onProc.sound end,
                    setFunc = function(value) Cool.preferences.sets[key].sounds.onProc.sound = value end,
                    --tooltip = "Dropdown's tooltip text.", -- or string id or function returning a string (optional)
                    --choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
                    sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
                    width = "full", --or "half" (optional)
                    scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
                    disabled = function() return not Cool.Settings.GetOnProcEnabled(key) end,
                },
                [5] = {
                    type = "button",
                    name = "Test Sound", -- string id or function returning a string
                    func = function() Cool.Settings.PlayTestSound(key, 'onProc') end,
                    width = "full", --or "half" (optional)
                    disabled = function() return not Cool.Settings.GetOnProcEnabled(key) end,
                },
                [6] = {
                    type = "checkbox",
                    name = "Play Sound On Ready",
                    getFunc = function() return end,
                    setFunc = function(value) return end,
                    --tooltip = "Checkbox's tooltip text.", -- or string id or function returning a string (optional)
                    width = "full", -- or "half" (optional)
                    --disabled = function() return db.someBooleanSetting end, --or boolean (optional)
                },
                [7] = {
                    type = "slider",
                    name = "Sound On Ready Volume",
                    getFunc = function() return Cool.preferences.sets[key].sounds.onReady.volume end,
                    setFunc = function(value) Cool.preferences.sets[key].sounds.onReady.volume = value end,
                    min = 1,
                    max = 100,
                    step = 1,
                    clampInput = true,
                    decimals = 0,
                    --tooltip = "Slider's tooltip text.",
                    width = "full",
                    --disabled = function() return false end,
                },
                [8] = {
                    type = "dropdown",
                    name = "Sound On Ready", -- or string id or function returning a string
                    choices = {"table", "of", "choices"},
                    choicesValues = {"foo", 2, "three"}, -- if specified, these values will get passed to setFunc instead (optional)
                    getFunc = function() return end,
                    setFunc = function(var) return end,
                    --tooltip = "Dropdown's tooltip text.", -- or string id or function returning a string (optional)
                    --choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
                    sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
                    width = "full", --or "half" (optional)
                    scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
                    --disabled = function() return db.someBooleanSetting end, --or boolean (optional)
                },
                [9] = {
                    type = "button",
                    name = "Test Sound", -- string id or function returning a string
                    func = function() end,
                    --tooltip = "Button's tooltip text.", -- string id or function returning a string (optional)
                    width = "full", --or "half" (optional)
                    --disabled = function() return db.someBooleanSetting end, --or boolean (optional)
                },
            },
        })
    end

    LAM:RegisterAddonPanel(Cool.name, panelData)
    LAM:RegisterOptionControls(Cool.name, optionsTable)

    Cool:Trace(2, "Finished InitSettings()")
end
