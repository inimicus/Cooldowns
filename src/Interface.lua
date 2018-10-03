-- -----------------------------------------------------------------------------
-- Earthgore Cooldown
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

EGC.UI = {}
EGC.UI.Controls = {}

function EGC.UI.Draw(key)

    local set = EGC.Tracking.Sets[key];

    -- Enable display
    if set.enabled then

        local container = WINDOW_MANAGER:GetControlByName(key .. "_Container")

        -- Draw UI and create context if it doesn't exist
        if container == nil then
            EGC:Trace(1, zo_strformat("Drawing: <<1>>", set.name))

            local c = WINDOW_MANAGER:CreateTopLevelWindow(key .. "_Container")
            c:SetClampedToScreen(true)
            c:SetDimensions(100, 100)
            c:ClearAnchors()
            c:SetMouseEnabled(true)
            c:SetAlpha(1)
            c:SetMovable(EGC.preferences.unlocked)
            c:SetHidden(false)
            c:SetHandler("OnMoveStop", function(...) EGC.UI.Position.Save(key) end)

            local r = WINDOW_MANAGER:CreateControl(key .. "_Texture", c, CT_TEXTURE)
            r:SetTexture(set.texture)
            r:SetDimensions(100, 100)
            r:SetAnchor(CENTER, c, CENTER, 0, 0)

            local l = WINDOW_MANAGER:CreateControl(key .. "Label", c, CT_LABEL)
            l:SetAnchor(CENTER, c, CENTER, 0, 0)
            l:SetColor(255, 255, 255, 1)
            l:SetFont("$(MEDIUM_FONT)|36|soft-shadow-thick")
            l:SetVerticalAlignment(TOP)
            l:SetHorizontalAlignment(RIGHT)
            l:SetPixelRoundingEnabled(true)

            set.context = c
            set.label = l

            EGC.UI.Position.Set(key, EGC.preferences.sets[key].x, EGC.preferences.sets[key].y)

        -- Reuse context
        else 
            container:SetHidden(false)
            set.context = container
        end

    -- Disable display
    else
        if set.context ~= nil and WINDOW_MANAGER:GetControlByName(key .. "_Container") ~= nil then
            set.context:SetHidden(true)
            set.context = nil
        end
    end

    EGC:Trace(2, "Finished DrawUI()")
end

function EGC.UI.Update()
    EGC.onCooldown = true

    local countdown = (EGC.Tracking.timeOfProc + EGC.Tracking.cooldownDurationMs - GetGameTimeMilliseconds()) / 1000

    EGC:Trace(3, "Countdown: " .. countdown)

    if (countdown <= 0) then
        EVENT_MANAGER:UnregisterForUpdate(EGC.name .. "Count")
        EGC.onCooldown = false
        EGC.EGCLabel:SetText("")
        EGC.EGCTexture:SetColor(1, 1, 1, 1)
        PlaySound(SOUNDS.TELVAR_GAINED)
    elseif (countdown < 10) then
        EGC.EGCLabel:SetText(string.format("%.1f", countdown))
    else
        EGC.EGCLabel:SetText(string.format("%.0f", countdown))
    end

end

function EGC.UI.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if EGC.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            EGC:Trace(3, "Hiding HUD")
            EGC.HUDHidden = true
            EGC.UI.ShowIcon(false)
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            EGC:Trace(3, "Showing HUD")
            EGC.HUDHidden = false
            EGC.UI.ShowIcon(true)
        end
    end)

    EGC:Trace(2, "Finished ToggleHUD()")
end

function EGC.UI.ShowIcon(shouldShow)
    if (shouldShow and EGC.enabled and not EGC.HUDHidden) then
        --EGC.EGCContainer:SetHidden(false)
    else
        --EGC.EGCContainer:SetHidden(true)
    end
end

EGC.UI.Position = {}

function EGC.UI.Position.Save(key)
    local context = EGC.Tracking.Sets[key].context
    local top   = context:GetTop()
    local left  = context:GetLeft()

    EGC:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    EGC.preferences.sets[key].x = left
    EGC.preferences.sets[key].y = top
end

function EGC.UI.Position.Set(key, left, top)
    EGC:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
    local context = EGC.Tracking.Sets[key].context
    context:ClearAnchors()
    context:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function EGC.UI.SlashCommand(command)
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
