--[[--

RIME-style Cangjie (倉頡) input method for Lua/KOReader.

Features:
1. Shows Cangjie code after cursor while typing
2. No auto-commit, space key to confirm current candidate
3. Candidates displayed below cursor with number labels (1-9)
4. Number keys 1-9 to select candidates
5. Allows continuous input (no need to finish one character before starting next)

--]]

local NewCangjieIME = require("ui/data/keyboardlayouts/new_cangjie_ime")
local util = require("util")
local _ = require("gettext")

-- Start with the english keyboard layout
local cj_keyboard = dofile("frontend/ui/data/keyboardlayouts/en_keyboard.lua")
local SETTING_NAME = "keyboard_cangjie_settings"

local code_map = dofile("frontend/ui/data/keyboardlayouts/cj_data.lua")
local settings = G_reader_settings:readSetting(SETTING_NAME, {show_candi=true})

local ime = NewCangjieIME:new{
    code_map = code_map,
    key_map = {
        ["A"] = "A", ["B"] = "B", ["C"] = "C", ["D"] = "D", ["E"] = "E",
        ["F"] = "F", ["G"] = "G", ["H"] = "H", ["I"] = "I", ["J"] = "J",
        ["K"] = "K", ["L"] = "L", ["M"] = "M", ["N"] = "N", ["O"] = "O",
        ["P"] = "P", ["Q"] = "Q", ["R"] = "R", ["S"] = "S", ["T"] = "T",
        ["U"] = "U", ["V"] = "V", ["W"] = "W", ["X"] = "X", ["Y"] = "Y",
    },
    show_candidates = settings.show_candi,
    auto_confirm = false,
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
    southeast = "「",
    south = "、",
    southwest = "」",
    west = "》",
}
cj_keyboard.keys[3][10][3] = {
    "。",
    north = "：",
    alt_label = "：",
    northeast = "）",
    northwest = "\u{201d}",
    east = "〉",
    southeast = "『",
    south = "·",
    southwest = "』",
    west = "〈",
}

-- Override the Enter key with Cangjie-specific behavior
if cj_keyboard.keys[4][10] then
    cj_keyboard.keys[4][10][2] = {
        "\n",
        north = "\n",
        alt_label = _("Confirm"),
    }
end

-- Override the Space key for candidate confirmation
if cj_keyboard.keys[4][4] then
    cj_keyboard.keys[4][4][3] = {
        " ",
        alt_label = _("Confirm"),
    }
end

-- The main wrapper function that replaces inputbox.addChars
local wrappedAddChars = function(inputbox, char, orig_char)
    return ime:handle_input(inputbox, char, orig_char)
end

local wrappedDelChar = function(inputbox)
    -- Handle delete with IME
    ime:handle_input(inputbox, "") -- local_del character
end

local wrappedRightChar = function(inputbox)
    -- Right arrow for next candidate
    ime:handle_input(inputbox, "→")
end

local wrappedLeftChar = function(inputbox)
    -- Left arrow for previous candidate
    ime:handle_input(inputbox, "←")
end

-- Clear IME state on certain operations
local function clear_stack()
    ime:clear_stack()
end

-- Keyboard activation: wrap input methods
local wrappers = {}
function cj_keyboard.activate(inputbox)
    -- Clear IME state when activating keyboard
    clear_stack()
    
    -- Wrap input methods
    table.insert(wrappers, util.wrapMethod(inputbox, "addChars", wrappedAddChars, nil))
    table.insert(wrappers, util.wrapMethod(inputbox, "delChar", nil, wrappedDelChar))
    table.insert(wrappers, util.wrapMethod(inputbox, "rightChar", nil, wrappedRightChar))
    table.insert(wrappers, util.wrapMethod(inputbox, "leftChar", nil, wrappedLeftChar))
    table.insert(wrappers, util.wrapMethod(inputbox, "delToStartOfLine", nil, clear_stack))
    table.insert(wrappers, util.wrapMethod(inputbox, "clear", nil, clear_stack))
end

-- Keyboard deactivation: remove wrappers
function cj_keyboard.deactivate()
    for _, wrapper in ipairs(wrappers) do
        wrapper:remove()
    end
    wrappers = {}
    clear_stack()
end

-- Return the keyboard layout
return cj_keyboard
