local moduleName = "utf8togbk"

local M = {}
_G[moduleName] = M
complex = M


local string_char = require("string").char
local floor = require("math").floor

local unicode2gbk_lut = {}

for line in assert(io.open("GBK.TXT","r")):lines()
do
	for k,v in string.gmatch(line,"0x(%x+)%s+0x(%x+)") do
		unicode2gbk_lut[v] = k
	end
end

function M.utf8togbk(str)
	--print(string.format('%x%x%x%x%x%x',str:byte(1,-1)))
	local result =''

	while true do
		local unicode
		if(str ~= "" and str ~= nil) then
			local code1 = str:byte(1)
			if(code1< 0x80) then
				result = result .. string_char(code1)
				str = str:sub(2)
			else
				local code2 = str:byte(2)
				local code3 = str:byte(3)
				unicode = string_char((code1-0xe0)*16+floor((code2-0x80)/4),
				(code2%4)*64+(code3-0x80))
				--print(string.format('%x%x',unicode:byte(1,-1)))
				local gbk_code = unicode2gbk_lut[string.format('%02X%02X',unicode:byte(1,-1))]
				--print(gbk_code)
				--(string_char(tonumber(gbk_code:sub(1,2),16),tonumber(gbk_code:sub(3,4),16)))
				if(gbk_code ~= nil) then
					result = result .. string_char(tonumber(gbk_code:sub(1,2),16),tonumber(gbk_code:sub(3,4),16))
					str = str:sub(4)
					--print(result)
				else
					str = str:sub(2)
				end
			end
		else
			return result
		end
	end
end

return complex
