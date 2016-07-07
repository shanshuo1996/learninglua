local json = require("json")
local http = require("socket.http")
local gzio = require("gzio")
local utf8togbk = require("utf8togbk").utf8togbk

local tmpFileName = "index-icon.json.gz"
local data_compressed = http.request("http://www.bilibili.com/index/index-icon.json") 	--get compressed json file

local tmpgzfile = assert(io.open(tmpFileName, "wb"))
tmpgzfile:write(data_compressed)
tmpgzfile:close()																		--save as temp file

tmpgzfile = assert(gzio.open(tmpFileName, "r"), "gzio.open failed!")					--reread and uncompress
json_content = tmpgzfile:read("*a")

json_content_fix = json.decode(json_content).fix							--get the 'fix' field of the json file

for i, v in pairs(json_content_fix) do
	data,ret = http.request(v.icon)											--get the picture
	if(data ~= nil) then													--download success
		local file_name = utf8togbk(v.title)								--use the title as filename
		local f																--temporary val to save pictures
		if( file_name ~= nil and file_name ~= "") then
			f = assert(io.open("pictures\\" .. file_name .. ".gif","wb"))
		else
			print("con't convert filename" .. v.title)
			f = assert(io.open("pictures\\" .. v.title .. ".gif","wb"))		--use origin utf-8 coded filename
		end
		f:write(data)
		f:close()
	end
end

