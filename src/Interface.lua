-- -----------------------------------------------------------------------------
-- Earthgore Cooldown
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

function EGC.DrawUI()
    local c = WINDOW_MANAGER:CreateTopLevelWindow("EGCContainer")
    c:SetClampedToScreen(true)
    c:SetDimensions(100, 100)
    c:ClearAnchors()
    c:SetMouseEnabled(true)
    c:SetAlpha(1)
    c:SetMovable(EGC.preferences.unlocked)
    c:SetHidden(true)
    c:SetHandler("OnMoveStop", function(...) EGC.SavePosition() end)

    local t = WINDOW_MANAGER:CreateControl("EGCText", c, CT_CONTROL)
    t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

    local l = WINDOW_MANAGER:CreateControl("EGCLabel", t, CT_LABEL)
    l:SetAnchor(TOPLEFT, t, TOPLEFT, 0, 0)
    l:SetColor(255, 255, 255, 1)
    l:SetFont("$(MEDIUM_FONT)|50|soft-shadow-thick")
    l:SetVerticalAlignment(TOP)
    l:SetHorizontalAlignment(RIGHT)
    l:SetPixelRoundingEnabled(true)

    EGC.EGCContainer = c
    EGC.EGCText = t
    EGC.EGCLabel = l

    EGC.SetPosition(EGC.preferences.positionLeft, EGC.preferences.positionTop)

    EGC:Trace(2, "Finished DrawUI()")
end

function EGC.ToggleShow()
    if (EGC.onCooldown and not EGC.HUDHidden) then
        EGC.EGCContainer:SetHidden(false)
    else
        EGC.EGCContainer:SetHidden(true)
    end
end

function EGC.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if EGC.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            EGC:Trace(3, "Hiding HUD")
            EGC.HUDHidden = true
            EGC.ToggleShow()
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            EGC:Trace(3, "Showing HUD")
            EGC.HUDHidden = false
            EGC.ToggleShow()
        end
    end)

    EGC:Trace(2, "Finished ToggleHUD()")
end

function EGC.SavePosition()
    local top   = EGC.EGCContainer:GetTop()
    local left  = EGC.EGCContainer:GetLeft()

    EGC:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    EGC.preferences.positionLeft = left
    EGC.preferences.positionTop  = top
end

function EGC.SetPosition(left, top)
    EGC:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
    EGC.EGCContainer:ClearAnchors()
    EGC.EGCContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function EGC.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(EGC.prefix .. "Setting debug level to 0 (Off)")
        EGC.debugMode = 0
        EGC.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(EGC.prefix .. "Setting debug level to 1 (Low)")
        EGC.debugMode = 1
        EGC.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(EGC.prefix .. "Setting debug level to 2 (Medium)")
        EGC.debugMode = 2
        EGC.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(EGC.prefix .. "Setting debug level to 3 (High)")
        EGC.debugMode = 3
        EGC.preferences.debugMode = 3


    -- Default ----------------------------------------------------------------
    else
        d(EGC.prefix .. "Command not recognized!")
    end
end
