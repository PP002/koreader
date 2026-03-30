---------------------------------
-- RIME-style Cangjie IME --
---------------------------------
local logger = require("logger")
local util = require("util")

local CangjieIME = {
    code_map = nil,
    key_map = nil,
    show_candidates = true,
    auto_confirm = false,
    max_candidates = 9,
}

function CangjieIME:new(config)
    local o = config or {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    return o
end

function CangjieIME:init()
    self.stack = { {code="", candidates={}, index=1, confirmed=false} }
    self.current_code = ""
    self.candidates = {}
    self.candidate_index = 1
    self.hint_chars = ""
    self.hint_char_count = 0
end

function CangjieIME:clear_stack()
    self.stack = { {code="", candidates={}, index=1, confirmed=false} }
    self.current_code = ""
    self.candidates = {}
    self.candidate_index = 1
    self.hint_chars = ""
    self.hint_char_count = 0
end

function CangjieIME:get_candidates(code)
    if not self.code_map then return {} end
    local cand = self.code_map[code]
    if type(cand) == "string" then
        return { cand }
    end
    return cand or {}
end

function CangjieIME:update_candidates()
    local imex = self.stack[#self.stack]
    self.candidates = self:get_candidates(imex.code)
    self.candidate_index = 1
end

function CangjieIME:get_hint_chars()
    self.hint_char_count = 0
    local hint_chars = ""
    
    -- 添加已確認的字符
    for i=1, #self.stack do
        if self.stack[i].confirmed and self.stack[i].char then
            hint_chars = hint_chars .. self.stack[i].char
        end
    end
    
    local imex = self.stack[#self.stack]
    
    -- 顯示當前輸入的編碼
    if not imex.confirmed and imex.code ~= "" then
        hint_chars = hint_chars .. "[" .. imex.code .. "]"
        self.hint_char_count = #imex.code + 2
    end
    
    -- 顯示候選字（帶數字標籤）
    if self.show_candidates and #self.candidates > 0 then
        hint_chars = hint_chars .. "["
        local max_cand = math.min(#self.candidates, self.max_candidates)
        for i=1, max_cand do
            if i > 1 then
                hint_chars = hint_chars .. " "
            end
            hint_chars = hint_chars .. tostring(i) .. "." .. self.candidates[i]
            self.hint_char_count = self.hint_char_count + #self.candidates[i] + 2
        end
        if #self.candidates > self.max_candidates then
            hint_chars = hint_chars .. " …"
            self.hint_char_count = self.hint_char_count + 2
        end
        hint_chars = hint_chars .. "]"
        self.hint_char_count = self.hint_char_count + 2
    end
    
    return hint_chars
end

function CangjieIME:refresh_hint_chars(inputbox)
    -- 刪除之前的提示字符
    for i=1, self.hint_char_count do
        inputbox.delChar:raw_method_call()
    end
    -- 添加新的提示字符
    self.hint_chars = self:get_hint_chars()
    inputbox.addChars:raw_method_call(self.hint_chars)
    self.hint_char_count = #self.hint_chars
end

function CangjieIME:handle_input(inputbox, char, orig_char)
    local imex = self.stack[#self.stack]
    
    -- 數字鍵選擇候選字
    if char >= "1" and char <= "9" and #self.candidates > 0 then
        local idx = tonumber(char)
        if idx <= #self.candidates then
            imex.char = self.candidates[idx]
            imex.confirmed = true
            inputbox.addChars:raw_method_call(imex.char)
            self:clear_stack()
            return true
        end
    end
    
    -- 空格確認
    if char == " " then
        if #self.candidates > 0 then
            imex.char = self.candidates[self.candidate_index]
            imex.confirmed = true
            inputbox.addChars:raw_method_call(imex.char)
            self:clear_stack()
        else
            inputbox.addChars:raw_method_call(" ")
        end
        return true
    end
    
    -- 刪除鍵
    if char == "" then  -- local_del
        if #imex.code > 0 then
            imex.code = imex.code:sub(1, -2)
            self:update_candidates()
            self:refresh_hint_chars(inputbox)
        else
            inputbox.delChar:raw_method_call()
        end
        return true
    end
    
    -- 箭頭鍵切換候選字
    if char == "→" then
        if #self.candidates > 0 then
            self.candidate_index = (self.candidate_index % #self.candidates) + 1
            self:refresh_hint_chars(inputbox)
        end
        return true
    end
    
    if char == "←" then
        if #self.candidates > 0 then
            self.candidate_index = self.candidate_index - 1
            if self.candidate_index < 1 then
                self.candidate_index = #self.candidates
            end
            self:refresh_hint_chars(inputbox)
        end
        return true
    end
    
    -- 倉頡碼輸入
    local key = self.key_map[char]
    if key then
        imex.code = imex.code .. key
        self:update_candidates()
        self:refresh_hint_chars(inputbox)
        
        -- 如果只有一個候選字且啟用自動確認
        if self.auto_confirm and #self.candidates == 1 then
            imex.char = self.candidates[1]
            imex.confirmed = true
            inputbox.addChars:raw_method_call(imex.char)
            self:clear_stack()
        end
        return true
    end
    
    -- 其他字符：確認當前輸入並插入字符
    if imex.code ~= "" then
        if #self.candidates > 0 then
            imex.char = self.candidates[self.candidate_index]
            imex.confirmed = true
            inputbox.addChars:raw_method_call(imex.char)
        end
        self:clear_stack()
    end
    inputbox.addChars:raw_method_call(orig_char or char)
    return true
end

function CangjieIME:has_candidates()
    return #self.candidates > 0
end

function CangjieIME:separate(inputbox)
    local imex = self.stack[#self.stack]
    if #self.candidates > 0 and imex.code ~= "" then
        imex.char = self.candidates[self.candidate_index]
        imex.confirmed = true
        inputbox.addChars:raw_method_call(imex.char)
    end
    self:clear_stack()
end

return CangjieIME
