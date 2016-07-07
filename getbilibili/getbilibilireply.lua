local json = require("json")
local http = require("socket.http")
local gzio = require("gzio")

local avnumber
print("Please enter the av number")
avnumber = io.read("*line")
assert("number" ~= type(avnumber))

function getPage(pn)
	local tmpFileName = "reply.json.gz"
	local data_compressed = http.request("http://api.bilibili.com/x/reply?sort=0&type=1&oid=".. avnumber .."&pn=" .. pn) 	--get compressed json file

	local tmpgzfile = assert(io.open(tmpFileName, "wb"))
	tmpgzfile:write(data_compressed)
	tmpgzfile:close()																		--save as temp file

	tmpgzfile = assert(gzio.open(tmpFileName, "r"), "gzio.open failed!")					--reread and uncompress
	local json_content = tmpgzfile:read("*a")

	local json_content_data = json.decode(json_content).data.replies
	local floor_lut = {}

	if(next(json_content_data) == nil ) then
		return nil,0,0;
	end
	--print("succeed in getting page ".. pn)
	for k, v in pairs(json_content_data) do
		floor_lut[v.floor] = v.member.uname
	end

	return floor_lut,
	json_content_data[1].floor,
	json_content_data[table.maxn(json_content_data)].floor;
end

function getFloor(fl)
	assert(fl >0)
	local pn = fl/20
	if(pn < 1) then
		pn = 1.1
	end
	if(getPage(math.floor(pn)) == nil) then
		pn = pn/2
	end

	local page_current,floor_max,floor_min = getPage(math.floor(pn))
	local delta = (fl -(floor_max+floor_min)/2)/20

	repeat
		if(delta <1 and delta >-1) then
			page_current,floor_max,floor_min = getPage(math.floor(pn))
		end
		delta = (fl -(floor_max+floor_min)/2)/20

		if(pn < 2 and fl > floor_max) then
			return nil
		end
		if(fl < floor_min or fl > floor_max) then
			pn = pn - delta
		end
	until (fl >= floor_min and fl <= floor_max)
	return  math.floor(pn)
end

math.randomseed (os.time())

for i = 1,10,1 do
	local random_num = math.floor(math.random() * 5000)
	print("floor ".. random_num )
	local random_page = getFloor(random_num)
	if(random_page == nil) then
		print(" doesn't exist")
	else
		print(" is in page "..random_page)
	end
end
