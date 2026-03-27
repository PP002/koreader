--[[--

Cangjie (倉頡) input method for Lua/KOReader.

Uses standard QWERTY keyboard layout with Cangjie radical labels.
25 Cangjie radicals are mapped to keys A-Y following standard Cangjie layout.
Supports both simplified and traditional Chinese.
In-place candidates can be turned off in keyboard settings.
Arrow keys are used to iterate candidates (→ next, ← previous).
Space acts as separator to finish inputting a character.

rf. https://en.wikipedia.org/wiki/Cangjie_input_method

--]]

local IME = require("ui/data/keyboardlayouts/generic_ime")
local util = require("util")
local _ = require("gettext")

-- Start with the english keyboard layout
local cj_keyboard = dofile("frontend/ui/data/keyboardlayouts/en_keyboard.lua")
local SETTING_NAME = "keyboard_cangjie_settings"

local code_map = dofile("frontend/ui/data/keyboardlayouts/cj_data.lua")
local settings = G_reader_settings:readSetting(SETTING_NAME, {show_candi=true})
local ime = IME:new{
    code_map = code_map,
    key_map = {
        ["A"] = "A", ["B"] = "B", ["C"] = "C", ["D"] = "D", ["E"] = "E",
        ["F"] = "F", ["G"] = "G", ["H"] = "H", ["I"] = "I", ["J"] = "J",
        ["K"] = "K", ["L"] = "L", ["M"] = "M", ["N"] = "N", ["O"] = "O",
        ["P"] = "P", ["Q"] = "Q", ["R"] = "R", ["S"] = "S", ["T"] = "T",
        ["U"] = "U", ["V"] = "V", ["W"] = "W", ["X"] = "X", ["Y"] = "Y",
    },
    partial_separators = {" "},
    show_candi_callback = function()
        return settings.show_candi
    end,
    switch_char = "→",
    switch_char_prev = "←",
    separator = " ",
    exact_match = true,
}

-- Cangjie radical labels for QWERTY keys (standard Cangjie mapping)
-- Row 2: Q=手 W=田 E=水 R=口 T=廿 Y=卜 U=山 I=戈 O=人 P=心
-- Row 3: A=日 S=尸 D=木 F=火 G=土 H=竹 J=十 K=大 L=中
-- Row 4: Z=重 X=難 C=金 V=女 B=月 N=弓 M=一

-- Override layer 2 (lowercase) keys with Cangjie radical labels
-- Row 2 (keys[2]): Q W E R T Y U I O P
cj_keyboard.keys[2][1][2] = { label = "手", "Q", alt_label = "Q" }
cj_keyboard.keys[2][2][2] = { label = "田", "W", alt_label = "W" }
cj_keyboard.keys[2][3][2] = { label = "水", "E", alt_label = "E" }
cj_keyboard.keys[2][4][2] = { label = "口", "R", alt_label = "R" }
cj_keyboard.keys[2][5][2] = { label = "廿", "T", alt_label = "T" }
cj_keyboard.keys[2][6][2] = { label = "卜", "Y", alt_label = "Y" }
cj_keyboard.keys[2][7][2] = { label = "山", "U", alt_label = "U" }
cj_keyboard.keys[2][8][2] = { label = "戈", "I", alt_label = "I" }
cj_keyboard.keys[2][9][2] = { label = "人", "O", alt_label = "O" }
cj_keyboard.keys[2][10][2] = { label = "心", "P", alt_label = "P" }

-- Row 3 (keys[3]): A S D F G H J K L
cj_keyboard.keys[3][1][2] = { label = "日", "A", alt_label = "A" }
cj_keyboard.keys[3][2][2] = { label = "尸", "S", alt_label = "S" }
cj_keyboard.keys[3][3][2] = { label = "木", "D", alt_label = "D" }
cj_keyboard.keys[3][4][2] = { label = "火", "F", alt_label = "F" }
cj_keyboard.keys[3][5][2] = { label = "土", "G", alt_label = "G" }
cj_keyboard.keys[3][6][2] = { label = "竹", "H", alt_label = "H" }
cj_keyboard.keys[3][7][2] = { label = "十", "J", alt_label = "J" }
cj_keyboard.keys[3][8][2] = { label = "大", "K", alt_label = "K" }
cj_keyboard.keys[3][9][2] = { label = "中", "L", alt_label = "L" }

-- Row 4 (keys[4]): Z X C V B N M
cj_keyboard.keys[4][2][2] = { label = "重", "Z", alt_label = "Z" }
cj_keyboard.keys[4][3][2] = { label = "難", "X", alt_label = "X" }
cj_keyboard.keys[4][4][2] = { label = "金", "C", alt_label = "C" }
cj_keyboard.keys[4][5][2] = { label = "女", "V", alt_label = "V" }
cj_keyboard.keys[4][6][2] = { label = "月", "B", alt_label = "B" }
cj_keyboard.keys[4][7][2] = { label = "弓", "N", alt_label = "N" }
cj_keyboard.keys[4][8][2] = { label = "一", "M", alt_label = "M" }

-- Chinese punctuation overrides (same approach as zh_CN_keyboard)
cj_keyboard.keys[3][10][2] = {
    "，",
    north = "；",
    alt_label = "；",
    northeast = "（",
    northwest = "\u{201c}",
    east = "《",
    west = "？",
    south = ",",
    southeast = "【",
    southwest = "「",
    "{",
    "[",
    ";"
}

cj_keyboard.keys[5][3][2] = {
    "。",
    north = "：",
    alt_label = "：",
    northeast = "）",
    northwest = "\u{201d}",
    east = "…",
    west = "！",
    south = ".",
    southeast = "】",
    southwest = "」",
    "}",
    "]",
    ":"
}
cj_keyboard.keys[1][2][3] = { alt_label = "「", north = "「", "'" }
cj_keyboard.keys[1][3][3] = { alt_label = "」", north = "」", "'" }
cj_keyboard.keys[1][1][4] = { alt_label = "!", north = "!", "！"}
cj_keyboard.keys[2][1][4] = { alt_label = "?", north = "?", "？"}
cj_keyboard.keys[1][2][4] = "、"
cj_keyboard.keys[2][2][4] = "——"
cj_keyboard.keys[1][4][3] = { alt_label = "『", north = "『", "\u{201c}" }
cj_keyboard.keys[1][5][3] = { alt_label = "』", north = "』", "\u{201d}" }
cj_keyboard.keys[1][4][4] = { alt_label = "¥", north = "¥", "_" }
cj_keyboard.keys[3][3][4] = "（"
cj_keyboard.keys[3][4][4] = "）"
cj_keyboard.keys[4][4][3] = "《"
cj_keyboard.keys[4][5][3] = "》"

local genMenuItems = function(self)
    return {
        {
            text = _("Show character candidates"),
            checked_func = function()
                return settings.show_candi
            end,
            callback = function()
                settings.show_candi = not settings.show_candi
                G_reader_settings:saveSetting(SETTING_NAME, settings)
            end
        }
    }
end

local wrappedAddChars = function(inputbox, char)
    ime:wrappedAddChars(inputbox, char)
end

local wrappedRightChar = function(inputbox)
    if ime:hasCandidates() then
        ime:wrappedAddChars(inputbox, "→")
    else
        ime:separate(inputbox)
        inputbox.rightChar:raw_method_call()
    end
end

local wrappedLeftChar = function(inputbox)
    if ime:hasCandidates() then
        ime:wrappedAddChars(inputbox, "←")
    else
        ime:separate(inputbox)
        inputbox.leftChar:raw_method_call()
    end
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
        -- a callback to finish (separate) the input status, but pass through to the
        -- original function.

        -- -- Delete text.
        table.insert(wrappers, util.wrapMethod(inputbox, "delChar", wrappedDelChar, nil))
        table.insert(wrappers, util.wrapMethod(inputbox, "delToStartOfLine", nil, clear_stack))
        table.insert(wrappers, util.wrapMethod(inputbox, "clear", nil, clear_stack))
        -- -- Navigation.
        table.insert(wrappers, util.wrapMethod(inputbox, "upLine", nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "downLine", nil, separate))
        -- -- Move to other input box.
        table.insert(wrappers, util.wrapMethod(inputbox, "unfocus", nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "onCloseKeyboard", nil, separate))
        -- -- Gestures to move cursor.
        table.insert(wrappers, util.wrapMethod(inputbox, "onTapTextBox", nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "onHoldTextBox", nil, separate))
        table.insert(wrappers, util.wrapMethod(inputbox, "onSwipeTextBox", nil, separate))

        table.insert(wrappers, util.wrapMethod(inputbox, "addChars", wrappedAddChars, nil))
        table.insert(wrappers, util.wrapMethod(inputbox, "leftChar", wrappedLeftChar, nil))
        table.insert(wrappers, util.wrapMethod(inputbox, "rightChar", wrappedRightChar, nil))

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

cj_keyboard.wrapInputBox = wrapInputBox
cj_keyboard.genMenuItems = genMenuItems
cj_keyboard.keys[5][4].label = "空格"
return cj_keyboard
