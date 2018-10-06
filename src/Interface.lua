-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

Cool.UI = {}
Cool.UI.Controls = {}

function Cool.UI.Draw(key)

    local set = Cool.Tracking.Sets[key];
    local container = WINDOW_MANAGER:GetControlByName(key .. "_Container")

    -- Enable display
    if set.enabled then

        local saved = Cool.preferences.sets[key]

        -- Draw UI and create context if it doesn't exist
        if container == nil then
            Cool:Trace(1, zo_strformat("Drawing: <<1>>", set.name))

            local c = WINDOW_MANAGER:CreateTopLevelWindow(key .. "_Container")
            c:SetClampedToScreen(true)
            c:SetDimensions(saved.size, saved.size)
            c:ClearAnchors()
            c:SetMouseEnabled(true)
            c:SetAlpha(1)
            c:SetMovable(Cool.preferences.unlocked)
            c:SetHidden(false)
            c:SetHandler("OnMoveStop", function(...) Cool.UI.Position.Save(key) end)

            local r = WINDOW_MANAGER:CreateControl(key .. "_Texture", c, CT_TEXTURE)
            r:SetTexture(set.texture)
            r:SetDimensions(saved.size, saved.size)
            r:SetAnchor(CENTER, c, CENTER, 0, 0)

            local l = WINDOW_MANAGER:CreateControl(key .. "_Label", c, CT_LABEL)
            l:SetAnchor(CENTER, c, CENTER, 0, 0)
            l:SetColor(1, 1, 1, 1)
            l:SetFont("$(MEDIUM_FONT)|36|soft-shadow-thick")
            l:SetVerticalAlignment(TOP)
            l:SetHorizontalAlignment(RIGHT)
            l:SetPixelRoundingEnabled(true)

            Cool.UI.Position.Set(key, saved.x, saved.y)

        -- Reuse context
        else 
            container:SetHidden(false)
        end

    -- Disable display
    else
        if container ~= nil then
            container:SetHidden(true)
        end
    end

    Cool:Trace(2, "Finished DrawUI()")
end

function Cool.UI.PlaySound(sound)
    PlaySound(SOUNDS[sound])
end

function Cool.UI.Update(setKey)

    local set = Cool.Tracking.Sets[setKey]
    local container = WINDOW_MANAGER:GetControlByName(setKey .. "_Container")
    local texture = WINDOW_MANAGER:GetControlByName(setKey .. "_Texture")
    local label = WINDOW_MANAGER:GetControlByName(setKey .. "_Label")

    local countdown = (set.timeOfProc + set.cooldownDurationMs - GetGameTimeMilliseconds()) / 1000

    Cool:Trace(3, "Countdown: " .. countdown)
    texture:SetColor(0.5, 0.5, 0.5, 1)

    if (countdown <= 0) then
        EVENT_MANAGER:UnregisterForUpdate(Cool.name .. setKey .. "Count")
        set.onCooldown = false
        label:SetText("")
        texture:SetColor(1, 1, 1, 1)
        Cool.UI.PlaySound(Cool.preferences.sets[setKey].sounds.onReady.sound)
    elseif (countdown < 10) then
        label:SetText(string.format("%.1f", countdown))
    else
        label:SetText(string.format("%.0f", countdown))
    end

end

function Cool.UI.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if Cool.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            Cool:Trace(3, "Hiding HUD")
            Cool.HUDHidden = true
            Cool.UI.ShowIcon(false)
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            Cool:Trace(3, "Showing HUD")
            Cool.HUDHidden = false
            Cool.UI.ShowIcon(true)
        end
    end)

    Cool:Trace(2, "Finished ToggleHUD()")
end

function Cool.UI.ShowIcon(shouldShow)
    -- TODO: Setup visibility
    if (shouldShow and Cool.enabled and not Cool.HUDHidden) then
        --Cool.CoolContainer:SetHidden(false)
    else
        --Cool.CoolContainer:SetHidden(true)
    end
end

Cool.UI.Position = {}

function Cool.UI.Position.Save(key)
    local context = WINDOW_MANAGER:GetControlByName(key .. "_Container")
    local top   = context:GetTop()
    local left  = context:GetLeft()

    Cool:Trace(2, zo_strformat("Saving position for <<1>> - Left: <<2>> Top: <<2>>", key, left, top))

    Cool.preferences.sets[key].x = left
    Cool.preferences.sets[key].y = top
end

function Cool.UI.Position.Set(key, left, top)
    Cool:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
    local context = WINDOW_MANAGER:GetControlByName(key .. "_Container")
    context:ClearAnchors()
    context:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function Cool.UI.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(Cool.prefix .. "Setting debug level to 0 (Off)")
        Cool.debugMode = 0
        Cool.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(Cool.prefix .. "Setting debug level to 1 (Low)")
        Cool.debugMode = 1
        Cool.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(Cool.prefix .. "Setting debug level to 2 (Medium)")
        Cool.debugMode = 2
        Cool.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(Cool.prefix .. "Setting debug level to 3 (High)")
        Cool.debugMode = 3
        Cool.preferences.debugMode = 3

    -- Default ----------------------------------------------------------------
    else
        d(Cool.prefix .. "Command not recognized!")
    end
end
