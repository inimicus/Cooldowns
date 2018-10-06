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

-- OnReady Sound Settings
function Cool.Settings.GetOnReadyEnabled(setKey)
    return Cool.preferences.sets[setKey].sounds.onReady.enabled
end

function Cool.Settings.SetOnReadyEnabled(setKey, enabled)
    Cool.preferences.sets[setKey].sounds.onReady.enabled = enabled
end

-- Test Sound
function Cool.Settings.PlayTestSound(setKey, condition)
    local sound = Cool.preferences.sets[setKey].sounds[condition].sound

    Cool:Trace(2, zo_strformat("Testing sound <<1>>", sound))

    Cool.UI.PlaySound(sound)
end

-- Locked State
function Cool.Settings.ToggleLocked(control)
    Cool.preferences.unlocked = not Cool.preferences.unlocked
    for key, set in pairs(Cool.Tracking.Sets) do
        local context = WINDOW_MANAGER:GetControlByName(key .. "_Container")
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
function Cool.Settings.ForceShow(control)
    Cool.ForceShow = not Cool.ForceShow

    for key, set in pairs(Cool.Tracking.Sets) do
        local context = WINDOW_MANAGER:GetControlByName(key .. "_Container")
        if context ~= nil then
            if Cool.ForceShow then
                control:SetText("Hide All")
                Cool.HUDHidden = false
                context:SetHidden(false)
            else
                control:SetText("Show All")
                Cool.HUDHidden = true
                context:SetHidden(true)
            end
        end
    end

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
            name = "Global Settings",
            width = "full",
        },
        [2] = {
            type = "button",
            name = function() if Cool.ForceShow then return "Hide All" else return "Show All" end end,
            tooltip = "Force show all enabled for position or previewing display settings.",
            func = function(control) Cool.Settings.ForceShow(control) end,
            width = "half",
        },
        [3] = {
            type = "button",
            name = function() if Cool.preferences.unlocked then return "Lock All" else return "Unlock All" end end,
            tooltip = "Toggle lock/unlock display for repositioning.",
            func = function(control) Cool.Settings.ToggleLocked(control) end,
            width = "half",
        },
        [4] = {
            type = "header",
            name = "Sets",
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
                    tooltip = "Set to ON to play a sound when the set procs.",
                    getFunc = function() return Cool.Settings.GetOnProcEnabled(key) end,
                    setFunc = function(value) Cool.Settings.SetOnProcEnabled(key, value) end,
                    width = "full",
                },
                [3] = {
                    type = "dropdown",
                    name = "Sound On Proc",
                    choices = soundNames,
                    choicesValues = soundOptions,
                    getFunc = function() return Cool.preferences.sets[key].sounds.onProc.sound end,
                    setFunc = function(value) Cool.preferences.sets[key].sounds.onProc.sound = value end,
                    tooltip = "Sound volume based on Interface volume setting.",
                    sort = "name-down",
                    width = "full",
                    scrollable = true,
                    disabled = function() return not Cool.Settings.GetOnProcEnabled(key) end,
                },
                [4] = {
                    type = "button",
                    name = "Test Sound",
                    func = function() Cool.Settings.PlayTestSound(key, 'onProc') end,
                    width = "full",
                    disabled = function() return not Cool.Settings.GetOnProcEnabled(key) end,
                },
                [5] = {
                    type = "checkbox",
                    name = "Play Sound On Ready",
                    tooltip = "Set to ON to play a sound when the set is off cooldown and ready to proc again.",
                    getFunc = function() return Cool.Settings.GetOnReadyEnabled(key) end,
                    setFunc = function(value) Cool.Settings.SetOnReadyEnabled(key, value) end,
                    width = "full",
                },
                [6] = {
                    type = "dropdown",
                    name = "Sound On Ready",
                    choices = {"table", "of", "choices"},
                    choicesValues = {"foo", 2, "three"},
                    getFunc = function() return Cool.preferences.sets[key].sounds.onReady.sound end,
                    setFunc = function(value) Cool.preferences.sets[key].sounds.onReady.sound = value end,
                    tooltip = "Sound volume based on game interface volume setting.",
                    sort = "name-down",
                    width = "full",
                    scrollable = true,
                    disabled = function() return not Cool.Settings.GetOnReadyEnabled(key) end,
                },
                [7] = {
                    type = "button",
                    name = "Test Sound",
                    func = function() Cool.Settings.PlayTestSound(key, 'onReady') end,
                    width = "full",
                    disabled = function() return not Cool.Settings.GetOnReadyEnabled(key) end,
                },
            },
        })
    end

    LAM:RegisterAddonPanel(Cool.name, panelData)
    LAM:RegisterOptionControls(Cool.name, optionsTable)

    Cool:Trace(2, "Finished InitSettings()")
end
