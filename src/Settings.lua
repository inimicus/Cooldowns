-- -----------------------------------------------------------------------------
-- Earthgore Cooldown
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

EGC.Settings = {}

local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type        = "panel",
    name        = "Earthgore Cooldown",
    displayName = "Earthgore Cooldown",
    author      = "g4rr3t",
    version     = EGC.version,
    registerForRefresh  = true,
}

local optionsTable = {
    [1] = {
        type = "header",
        name = "Options",
        width = "full",
    },
}

function EGC.Settings.Init()
    LAM:RegisterAddonPanel(EGC.name, panelData)
    LAM:RegisterOptionControls(EGC.name, optionsTable)

    EGC:Trace(2, "Finished InitSettings()")
end
