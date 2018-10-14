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
    local color = Cool.Data.Sets[setKey].settingsColor
    return zo_strformat("|c<<1>><<2>>|r", color, setKey)
end

-- Description
function Cool.Settings.GetDescription(setKey)
    return Cool.Data.Sets[setKey].description
end

-- Enabled State
function Cool.Settings.GetEnabledState(setKey)
    local enabled =  Cool.Data.Sets[setKey].enabled
    if enabled then
        return "|c92C843Equipped!|r"
    else
        return "|cCD5031Not Equipped!|r"
    end
end

-- Enabled Status
function Cool.Settings.GetIsEnabled(setKey)
    return Cool.Data.Sets[setKey].enabled
end

-- Display Size
function Cool.Settings.GetSize(setKey)
    return Cool.preferences.sets[setKey].size
end

function Cool.Settings.SetSize(setKey, size)
    local context = WINDOW_MANAGER:GetControlByName(setKey .. "_Container")

    Cool.preferences.sets[setKey].size = size

    if context ~= nil then
        context:SetScale(size / Cool.UI.scaleBase)
    end
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
    for key, set in pairs(Cool.Data.Sets) do
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

    if Cool.ForceShow then
        control:SetText("Hide All Equipped")
        Cool.HUDHidden = false
        Cool.UI.ShowIcon(true)
    else
        control:SetText("Show All Equipped")
        Cool.HUDHidden = true
        Cool.UI.ShowIcon(false)
    end

end

-- Combat State Display
function Cool.Settings.GetShowOutOfCombat()
    return Cool.preferences.showOutsideCombat
end

function Cool.Settings.SetShowOutOfCombat(value)
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
        [1] = {
            type = "header",
            name = "Global Settings",
            width = "full",
        },
        [2] = {
            type = "button",
            name = function() if Cool.ForceShow then return "Hide All Equipped" else return "Show All Equipped" end end,
            tooltip = "Force all equipped sets for positioning or previewing display settings.",
            func = function(control) Cool.Settings.ForceShow(control) end,
            width = "half",
        },
        [3] = {
            type = "button",
            name = function() if Cool.preferences.unlocked then return "Lock All" else return "Unlock All" end end,
            tooltip = "Toggle locked/unlocked state.",
            func = function(control) Cool.Settings.ToggleLocked(control) end,
            width = "half",
        },
        [4] = {
            type = "checkbox",
            name = "Show Outside of Combat",
            tooltip = "Set to ON to show while out of combat and OFF to only show while in combat.",
            getFunc = function() return Cool.Settings.GetShowOutOfCombat() end,
            setFunc = function(value) Cool.Settings.SetShowOutOfCombat(value) end,
            width = "full",
        },
        [5] = {
            type = "header",
            name = "Sets",
            width = "full",
        },
    }

    -- Copy key/value table to index/value table
    settingsTable = {}
    for key, set in pairs(Cool.Data.Sets) do
        table.insert(settingsTable, {
            name = key,
        })
    end

    -- Sort settings table alphabetically
    table.sort(settingsTable, function(x, y)
        return x.name < y.name
    end)

    for index, set in ipairs(settingsTable) do
        table.insert(optionsTable, {
            type = "submenu",
            name = function() return Cool.Settings.GetSetName(set.name) end,
            controls = {
                {
                    type = "description",
                    text = function() return Cool.Settings.GetDescription(set.name) end,
                    width = "full",
                },
                --[[ {
                    type = "button",
                    name = function() return Cool.Settings.GetEnabledState(set.name) end,
                    func = function() return end,
                    width = "full",
                    disabled = true,
                }, ]]
                {
                    type = "slider",
                    name = "Size",
                    getFunc = function() return Cool.Settings.GetSize(set.name) end,
                    setFunc = function(size) Cool.Settings.SetSize(set.name, size) end,
                    min = 64,
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
                    getFunc = function() return Cool.Settings.GetOnProcEnabled(set.name) end,
                    setFunc = function(value) Cool.Settings.SetOnProcEnabled(set.name, value) end,
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
                    disabled = function() return not Cool.Settings.GetOnProcEnabled(set.name) end,
                },
                {
                    type = "button",
                    name = "Test Sound",
                    func = function() Cool.Settings.PlayTestSound(set.name, 'onProc') end,
                    width = "full",
                    disabled = function() return not Cool.Settings.GetOnProcEnabled(set.name) end,
                },
                {
                    type = "checkbox",
                    name = "Play Sound On Ready",
                    tooltip = "Set to ON to play a sound when the set is off cooldown and ready to proc again.",
                    getFunc = function() return Cool.Settings.GetOnReadyEnabled(set.name) end,
                    setFunc = function(value) Cool.Settings.SetOnReadyEnabled(set.name, value) end,
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
                    disabled = function() return not Cool.Settings.GetOnReadyEnabled(set.name) end,
                },
                {
                    type = "button",
                    name = "Test Sound",
                    func = function() Cool.Settings.PlayTestSound(set.name, 'onReady') end,
                    width = "full",
                    disabled = function() return not Cool.Settings.GetOnReadyEnabled(set.name) end,
                },
            },
        })
    end

    LAM:RegisterAddonPanel(Cool.name, panelData)
    LAM:RegisterOptionControls(Cool.name, optionsTable)

    Cool:Trace(2, "Finished InitSettings()")
end
