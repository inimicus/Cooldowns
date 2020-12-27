-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

Cool = Cool or {}
Cool.UI = {}
Cool.UI.scaleBase = 100

local scaleBase = Cool.UI.scaleBase
local WM = WINDOW_MANAGER

local function SnapToGrid(position, gridSize)
    -- Round down
    position = math.floor(position)

    -- Return value to closest grid point
    if (position % gridSize >= gridSize / 2) then
        return position + (gridSize - (position % gridSize))
    else
        return position - (position % gridSize)
    end
end

local function SetPosition(key, left, top)
    Cool:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
    local context = WM:GetControlByName(key .. "_Container")
    context:ClearAnchors()
    context:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function SavePosition(key)
    local context = WM:GetControlByName(key .. "_Container")
    local top   = context:GetTop()
    local left  = context:GetLeft()

    if Cool.preferences.snapToGrid then
        local gridSize = Cool.preferences.gridSize
        top = SnapToGrid(top, gridSize)
        left = SnapToGrid(left, gridSize)
        SetPosition(key, left, top)
    end

    Cool:Trace(2, "Saving position for <<1>> - Left: <<2>> Top: <<3>>", key, left, top)

    Cool.preferences.sets[key].x = left
    Cool.preferences.sets[key].y = top
end

function Cool.UI.Draw(key)

    local set = Cool.Data.Sets[key];
    local container = WM:GetControlByName(key .. "_Container")

    -- Enable display
    if set.enabled then

        local saved = Cool.preferences.sets[key]

        -- Draw UI and create context if it doesn't exist
        if container == nil then
            Cool:Trace(2, "Drawing: <<1>>", key)

            local c = WM:CreateTopLevelWindow(key .. "_Container")
            c:SetClampedToScreen(true)
            c:SetDimensions(scaleBase, scaleBase)
            c:ClearAnchors()
            c:SetMouseEnabled(true)
            c:SetAlpha(1)
            c:SetMovable(Cool.preferences.unlocked)
            if Cool.HUDHidden then
                c:SetHidden(true)
            else
                c:SetHidden(false)
            end
            c:SetScale(saved.size / scaleBase)
            c:SetHandler("OnMoveStop", function(...) SavePosition(key) end)

            local r = WM:CreateControl(key .. "_Texture", c, CT_TEXTURE)
            r:SetTexture(set.texture)
            r:SetDimensions(scaleBase, scaleBase)
            r:SetAnchor(CENTER, c, CENTER, 0, 0)

            if set.showFrame then
                local f = WM:CreateControl(key .. "_Frame", c, CT_TEXTURE)
                if set.procType == "passive" then
                    -- Gamepad frame is pretty, but looks bad scaled up
                    --f:SetTexture("/esoui/art/miscellaneous/gamepad/gp_passiveframe_128.dds")
                    f:SetTexture("/esoui/art/actionbar/passiveabilityframe_round_up.dds")

                    -- Add 5 to make the frame sit where it should.
                    f:SetDimensions(scaleBase + 5, scaleBase + 5)
                else
                    f:SetTexture("/esoui/art/actionbar/gamepad/gp_abilityframe64.dds")
                    f:SetDimensions(scaleBase, scaleBase)
                end
                f:SetAnchor(CENTER, c, CENTER, 0, 0)
            end

            local l = WM:CreateControl(key .. "_Label", c, CT_LABEL)
            l:SetAnchor(CENTER, c, CENTER, 0, 0)
            l:SetColor(1, 1, 1, 1)
            l:SetFont("$(MEDIUM_FONT)|" .. saved.timerSize .. "|soft-shadow-thick")
            l:SetVerticalAlignment(TOP)
            l:SetHorizontalAlignment(RIGHT)
            l:SetPixelRoundingEnabled(true)

            SetPosition(key, saved.x, saved.y)

        -- Reuse context
        else
            if not Cool.HUDHidden then
                container:SetHidden(false)
            end
        end

    -- Disable display
    else
        if container ~= nil then
            container:SetHidden(true)
        end
    end

    Cool:Trace(2, "Finished DrawUI()")
end

function Cool.UI:SetCombatStateDisplay()
    Cool:Trace(3, "Setting combat state display, in combat: <<1>>", tostring(Cool.isInCombat))

    if Cool.isInCombat or Cool.preferences.showOutsideCombat and not Cool.isDead then
        Cool.UI.ShowIcon(true)
    else
        Cool.UI.ShowIcon(false)
    end
end

function Cool.UI.PlaySound(sound)
    if sound.enabled then
        PlaySound(SOUNDS[sound.sound])
    end
end

function Cool.UI.Update(setKey)

    local set = Cool.Data.Sets[setKey]
    local container = WM:GetControlByName(setKey .. "_Container")
    local texture = WM:GetControlByName(setKey .. "_Texture")
    local label = WM:GetControlByName(setKey .. "_Label")

    local countdown = (set.timeOfProc + set.cooldownDurationMs - GetGameTimeMilliseconds()) / 1000

    --Cool:Trace(3, "Countdown: " .. countdown)
    texture:SetColor(0.5, 0.5, 0.5, 1)

    if (countdown <= 0) then
        EVENT_MANAGER:UnregisterForUpdate(Cool.name .. setKey .. "Count")
        set.onCooldown = false
        label:SetText("")
        texture:SetColor(1, 1, 1, 1)
        if Cool.preferences.audioNotifications then Cool.UI.PlaySound(Cool.preferences.sets[setKey].sounds.onReady) end
    elseif (countdown < 10) then
        label:SetText(zo_strformat("<<1>>", string.format("%.1f", countdown)))
    else
        label:SetText(zo_strformat("<<1>>", string.format("%.0f", countdown)))
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
            Cool.UI:SetCombatStateDisplay()
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            Cool:Trace(3, "Showing HUD")
            Cool.HUDHidden = false
            Cool.UI:SetCombatStateDisplay()
        end
    end)

    Cool:Trace(2, "Finished ToggleHUD()")
end

function Cool.UI.ShowIcon(shouldShow)

    for key, set in pairs(Cool.Data.Sets) do
        local context = WM:GetControlByName(key .. "_Container")
        if context ~= nil then
            if Cool.ForceShow and set.enabled then
                context:SetHidden(false)
            elseif (shouldShow and set.enabled and not Cool.HUDHidden) then
                context:SetHidden(false)
            else
                context:SetHidden(true)
            end
        end
    end

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

    -- Unfiltered Events
    elseif command == "all on" then
        d(Cool.prefix .. "Registering unfiltered events, setting debug mode to 1")
        Cool.debugMode = 1
        Cool.preferences.debugMode = 1
        Cool.Tracking.RegisterUnfiltered()
    elseif command == "all off" then
        d(Cool.prefix .. "Unregistering unfiltered events, setting debug mode to 0")
        Cool.Tracking.UnregisterUnfiltered()
        Cool.debugMode = 0
        Cool.preferences.debugMode = 0

    -- Language Helper
    elseif string.sub(command, 0, 4) == "lang" then
        local lang = string.sub(command, 6)
        Cool:Trace(0, "Setting language to <<1>>", lang)
        SetCVar("language.2", lang)

    -- Default ----------------------------------------------------------------
    else
        d(Cool.prefix .. "Command not recognized!")
    end
end
