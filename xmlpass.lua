local function passXml(path)
	local f = io.open(path,"r")
	local xml = {
		getChildByTag=function(self,tag)
			local elements = {}
			for _,v in ipairs(self) do
				if type(v) == "table" and v.__name == tag then
					table.insert(elements,v)
				end
			end
			return elements
		end,
		getText = function(self)
			local text = ""
			for _,v in ipairs(self) do
				if type(v) == "string" then
					text = text..v
				end
			end
			return text
		end
	}
	local root = nil
	local stack = {}
	local data = f:read("*all")
	local info = "(<%?.-%?>)"
	local infostart,infoend,infotext = data:find(info)
	local tag = "<(/?)(.-)(/?)>"
	local s,e = infostart,infoend
	local function passTag(tag)
		local _,e,tagname = tag:find("(%S+)")
		local result = {__name = tagname}
		setmetatable(result,{__index = xml})
		tag:gsub("(%S+)%s*=%s*(%S+)",function(k,v) 
			result[k] = loadstring("return "..v)()
			return k,v
		end)
		return result
	end
	local function trim(str)
		local _,_,s = str:find("^%s*(.-)%s*$")
		if s:len() ~= 0 then
			return s
		else
			return nil
		end
	end
	while e do
		local tagtext,tmpend,h,f
		s,tmpend,h,tagtext,f = data:find(tag,e)
		if tagtext then
			if table.maxn(stack) ~= 0 then
				table.insert(stack[table.maxn(stack)],trim(data:sub(e+1, s-1)))
			end
			if h:len() == 0 then
				local element = passTag(tagtext)
				if not root then
					root = element
					table.insert(stack,element)
				else
					table.insert(stack[table.maxn(stack)],element)
					table.insert(stack,element)
				end
			end
			if h:len() == 1 or f:len() == 1 then
				table.remove(stack)
			end
		end
		e = tmpend
	end
	return root
end
local function main()
	local xml = passXml("books.xml")
	print(xml[2].id)
end
main()
