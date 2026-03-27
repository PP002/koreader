--[[--

Cangjie (倉頡) input method for Lua/KOReader.

Uses 25 Cangjie radicals (A-Y) to input Chinese characters.
Supports both simplified and traditional Chinese.
In-place candidates can be turned off in keyboard settings.
A Separation key 分隔 is used to finish inputting a character.
A Switch key 下一字 is used to iterate candidates.
Stroke-wise deletion (input not finished) mapped to the default Del key.
Character-wise deletion mapped to north of Separation key.

rf. https://en.wikipedia.org/wiki/Cangjie_input_method

--]]

local IME = require("ui/data/keyboardlayouts/generic_ime")
local util = require("util")
local _ = require("gettext")

local SHOW_CANDI_KEY = "keyboard_cangjie_show_candidates"

local genMenuItems = function(self)
    return {
        {
            text = _("Show character candidates"),
            checked_func = function()
                return G_reader_settings:nilOrTrue(SHOW_CANDI_KEY)
            end,
            callback = function()
                G_reader_settings:flipNilOrTrue(SHOW_CANDI_KEY)
            end,
        },
    }
end

local code_map = dofile("frontend/ui/data/keyboardlayouts/cj_data.lua")
local ime = IME:new{
    code_map = code_map,
    key_map = {
        ["A"] = "A", ["B"] = "B", ["C"] = "C", ["D"] = "D", ["E"] = "E",
        ["F"] = "F", ["G"] = "G", ["H"] = "H", ["I"] = "I", ["J"] = "J",
        ["K"] = "K", ["L"] = "L", ["M"] = "M", ["N"] = "N", ["O"] = "O",
        ["P"] = "P", ["Q"] = "Q", ["R"] = "R", ["S"] = "S", ["T"] = "T",
        ["U"] = "U", ["V"] = "V", ["W"] = "W", ["X"] = "X", ["Y"] = "Y",
    },
    show_candi_callback = function()
        return G_reader_settings:nilOrTrue(SHOW_CANDI_KEY)
    end,
    separator = "分隔",
    switch_char = "下一字",
    exact_match = true,
}

local wrappedAddChars = function(inputbox, char)
    ime:wrappedAddChars(inputbox, char)
end

local function separate(inputbox)
    ime:separate(inputbox)
end

local function wrappedDelChar(inputbox)
    ime:wrappedDelChar(inputbox)
end

local function clear_stack()
    ime:clear_stack()
end

local wrapInputBox = function(inputbox)
    if inputbox._cj_wrapped == nil then
        inputbox._cj_wrapped = true
        local wrappers = {}

        -- Wrap all of the navigation and non-single-character-input keys with
        -- a callback to clear the tap window, but pass through to the
        -- original function.

        -- -- Delete text.
        table.insert(wrappers, util.wrapMethod(inputbox, "delChar",          wrappedDelChar,   nil))
        table.insert(wrappers, util.wrapMethod(inputbox, "delToStartOfLine", nil, clear_stack))
        table.insert(wrappers, util.wrapMethod(inputbox, "clear",            nil, clear_stack))
        -- -- Navigation.
        table.insert(wrappers, util.wrapMethod(inputbox, "leftChar",  nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "rightChar", nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "upLine",    nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "downLine",  nil, separate))
        -- -- Move to other input box.
        table.insert(wrappers, util.wrapMethod(inputbox, "unfocus",         nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "onCloseKeyboard", nil, separate))
        -- -- Gestures to move cursor.
        table.insert(wrappers, util.wrapMethod(inputbox, "onTapTextBox",    nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "onHoldTextBox",   nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "onSwipeTextBox",  nil, separate))
        -- -- Others
        table.insert(wrappers, util.wrapMethod(inputbox, "onSwitchingKeyboardLayout", nil, separate))

        -- addChars is the only method we need a more complicated wrapper for.
        table.insert(wrappers, util.wrapMethod(inputbox, "addChars", wrappedAddChars, nil))

        return function()
            if inputbox._cj_wrapped then
                for _, wrapper in ipairs(wrappers) do
                    wrapper:revert()
                end
                inputbox._cj_wrapped = nil
            end
        end
    end
end

-- Cangjie radicals and their corresponding keys:
-- 日(A) 月(B) 金(C) 木(D) 水(E) 火(F) 土(G) 竹(H) 戈(I) 十(J)
-- 大(K) 中(L) 一(M) 弓(N) 人(O) 心(P) 手(Q) 口(R) 尸(S) 廿(T)
-- 山(U) 女(V) 田(W) 難(X) 卜(Y)

local comma_popup = { "，",
    north = "；",
    alt_label = "；",
    northeast = "（",
    northwest = "“",
    east = "《",
    west = "？",
    south = ",",
    southeast = "【",
    southwest = "「",
    "{",
    "[",
    ";",
}
local period_popup = { "。",
    north = "：",
    alt_label = "：",
    northeast = "）",
    northwest = "”",
    east = "…",
    west = "！",
    south = ".",
    southeast = "】",
    southwest = "」",
    "}",
    "]",
    ":",
}

return {
    min_layer = 1,
    max_layer = 4,
    symbolmode_keys = {["123"] = true},
    utf8mode_keys = {["🌐"] = true},
    keys = {
        -- first row [A-E]
        {
            { label = "123" },
            { "", { label = "日", "A" }, "", "1" },
            { "", { label = "月", "B" }, "", "2" },
            { "", { label = "金", "C" }, "", "3" },
            { "", { label = "木", "D" }, "", "4" },
            { "", { label = "水", "E" }, "", "5" },
            { label = "", bold = false }, -- backspace
        },
        -- second row [F-J]
        {
            { label = "←" },
            { "", { label = "火", "F" }, "", "6" },
            { "", { label = "土", "G" }, "", "7" },
            { "", { label = "竹", "H" }, "", "8" },
            { "", { label = "戈", "I" }, "", "9" },
            { "", { label = "十", "J" }, "", "0" },
            { label = "→" },
        },
        -- third row [K-O]
        {
            { label = "↑" },
            { "", { label = "大", "K" }, "", { alt_label = "%°#", ".", west = "%", north = "°", east = "#" } },
            { "", { label = "中", "L" }, "", { alt_label = "&-/", ",", west = "&", north = "-", east = "/" } },
            { "", { label = "一", "M" }, "", { alt_label = "~+=", "?", west = "~", north = "+", east = "=" } },
            { "", { label = "弓", "N" }, "", { alt_label = "'\":", "!", west = "'", north = "\"", east = ":" } },
            { "", { label = "人", "O" }, "", { alt_label = "@$\\", ";", west = "@", north = "$", east = "\\" } },
            { label = "↓" },
        },
        -- fourth row [P-T]
        {
            { "", { label = "心", "P" }, "", comma_popup },
            { "", { label = "手", "Q" }, "", period_popup },
            { "", { label = "口", "R" }, "", { alt_label = "「」", "—", west = "「", north = "」" } },
            { "", { label = "尸", "S" }, "", { alt_label = "《》", "…", west = "《", north = "》" } },
            { "", { label = "廿", "T" }, "", { alt_label = "【】", "·", west = "【", north = "】" } },
        },
        -- fifth row [U-Y + separator/switch]
        {
            { "", { label = "山", "U" }, "", { alt_label = "（）", "(", west = "（", north = "）" } },
            { "", { label = "女", "V" }, "", { alt_label = "{}|", ")", west = "{", north = "}", east = "|" } },
            { "", { label = "田", "W" }, "", { alt_label = "「」", "[", west = "「", north = "」" } },
            { "", { label = "難", "X" }, "", { alt_label = "『』", "]", west = "『", north = "』" } },
            { "", { label = "卜", "Y" }, "", { alt_label = "<>^", "_", west = "<", north = ">", east = "^" } },
        },
        -- sixth row
        {
            { label = "🌐" },
            { "", { ime.separator, north=ime.local_del, alt_label=ime.local_del }, "", " " },
            { label = "空格", " ", " ", " ", " ", width = 2.0 },
            { "", ime.switch_char, "", " " },
            { label = "⮠", "\n", "\n", "\n", "\n", bold = true }, -- return
        },
    },

    wrapInputBox = wrapInputBox,
    genMenuItems = genMenuItems,
}
