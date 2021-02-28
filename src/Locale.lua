-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: Feb 27, 2021
--
-- Locale.lua
-- -----------------------------------------------------------------------------

Cool = Cool or {}
Cool.Locale = {}

-- Prefix for unique string IDs
local stringPrefix = "COOLDOWNS_ADDON_"

-- Set client language
Cool.clientLang = GetCVar("language.2")

--- Get the string ID for the translation
-- @param s String key of the translation as defined in [locale].lua
-- @return Numeric ID of the string constant
local function getLocaleStringId(s)
    return stringPrefix .. string.upper(s)
end

--- Initialize the locale
-- @param strings Table of translation strings
function Cool.Locale.registerStrings(strings)
    for key, value in pairs(strings) do
        local stringId = stringPrefix .. string.upper(key)
        ZO_CreateStringId(stringId, value)
    end
end

--- Get the translation
-- @param s String key of the translation as defined in [locale].lua
-- @return Translated string
function Cool.Locale.Get(s)
    -- Global hax
    local a = _G[getLocaleStringId(s)]

    if (a == nil) then
        return "[Missing Translation]"
    end

    return GetString(a)
end
