--[[
 * Copyright (C) 2017 Ricky K. Thomson
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * u should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 --]]

fb = {}

fb.icons = {
	["folder"] = love.graphics.newImage("lfb/icons/folder.png"),
	["file"] = love.graphics.newImage("lfb/icons/file.png"),
}

fb.title = "Select a file"
fb.callback = function(path) return path end
fb.limit = 10
fb.w = 500
fb.keydelay = 0.09
fb.min = 1
fb.scrollwidth = 20
fb.cwd = ""
fb.index = 0
fb.keycycle = 0	
fb.scrollbar = true
fb.padding = 10
fb.itemspacing = 5 
fb.itemheight = 25
fb.itemwidth = fb.w - fb.padding
fb.h = (fb.itemheight+fb.itemspacing) * fb.limit + (fb.padding*2) - fb.itemspacing + fb.itemheight
fb.canvas = love.graphics.newCanvas(fb.w, fb.h)
fb.debug = false

function fb.show(bool)
	--get folder/file list
	fb.list = fb:get_dir_items(fb.cwd)

	--set item limit
	fb.max = math.min(#fb.list,fb.limit)

	--reset position
	fb.index = 1

	if bool then 
		fb.active = true
	else
		fb.active = false
	end
end


function fb:table_concat(t1,t2)
	--concatenate two tables
	for i=1,#t2 do
		t1[#t1+1] = t2[i]    
	end
	return t1
end


function fb:get_dir_items(dir)
	--[[
		get contents of given path to directory
		return as table ordered with directorys 
		followed by files.
	--]]
	local list = love.filesystem.getDirectoryItems(dir)
	local dirs,files = {}, {}
	
	if not (fb.cwd == "") then
		table.insert(dirs,1,"..")
	end
	
	for i,f in ipairs(list) do
		if love.filesystem.isDirectory(f) then
			table.insert(dirs,f)
		else
			table.insert(files,f)
		end
	end
	
	return fb:table_concat(dirs,files)
	
end


function fb.draw(x,y)
	--draw the browser

	if not fb.active then return end
	local font = love.graphics.getFont()
	local color = love.graphics.getColor()

	love.graphics.setCanvas(fb.canvas)
	love.graphics.setColor(20,20,20,255)
	love.graphics.rectangle("fill",0,0,fb.w,fb.h,10)
	
	--title
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(love.graphics.newFont(16))
	love.graphics.printf(fb.title,fb.padding,fb.padding,fb.w,"center")

	--show the items
	local ix = 0
	local iy = fb.padding+fb.itemheight

	for i=fb.min,fb.max do
		local item = fb.list[i] or "nil"

		if i == fb.index then
			love.graphics.setColor(100,100,100,255)
		else
			if (i % 2 == 0) then 
				love.graphics.setColor(60,60,60,255)
			else
				love.graphics.setColor(40,40,40,255)                 
			end
		end

		--item
		love.graphics.rectangle(
			"fill",
			ix+fb.icons["folder"]:getWidth(), 
			iy,
			fb.itemwidth -fb.icons["folder"]:getWidth() -(fb.scrollbar and fb.scrollwidth or 0), 
			fb.itemheight,
			5
		)

		local path = fb.cwd .."/".. item

		love.graphics.setColor(255,255,255,255)
		if love.filesystem.isFile(path) then
			love.graphics.draw(fb.icons["file"],fb.padding,iy,0,fb.itemheight/fb.icons["file"]:getHeight())
		elseif love.filesystem.isDirectory(path) then
			love.graphics.draw(fb.icons["folder"],fb.padding,iy,0,fb.itemheight/fb.icons["folder"]:getHeight())
		end
		love.graphics.setFont(love.graphics.newFont(20))
		love.graphics.print(item .."\t", ix+fb.padding+fb.icons["folder"]:getWidth(),iy)

		iy = iy + fb.itemheight+fb.itemspacing

	end

	if fb.scrollbar then
		fb.drawscrollbar()
	end

	love.graphics.setCanvas()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(fb.canvas,x,y)

	if fb.debug then
		love.graphics.print("fb.index\t\t"..fb.index,10,10)
		love.graphics.print("fb.cwd\t\t"..fb.cwd,10,30)
	end

	love.graphics.setFont(font)

end

function fb.drawscrollbar()
	love.graphics.setColor(70,70,70,255)

	local sbarx = fb.w-fb.padding*2
	local sbary = fb.padding+fb.itemheight
	local sbarh = (fb.h-fb.padding*2)-fb.itemheight
	local sbarw = 10	

	if #fb.list > fb.limit then
		--scrollbar container
		love.graphics.rectangle("line", sbarx, sbary, sbarw, sbarh,5)

		local sbarsizew = 10
		local sbarsizeh = sbarh/#fb.list
		local sbarpos = sbary + (sbarsizeh*fb.index) - sbarsizeh

		--scrollbar position
		love.graphics.rectangle("fill", sbarx, sbarpos, sbarsizew, sbarsizeh, 5)

	else
		love.graphics.rectangle("fill", sbarx, sbary, sbarw, sbarh,5)
	end
end

function fb.update(dt)

	if not fb.active then return end
	
	--keypress delays / process input
	fb.keycycle = math.max(0, fb.keycycle - dt)

	if fb.keycycle <= 0 then				
		if love.keyboard.isDown("up") then
			fb.index = math.max(fb.index -1,1)
			fb.keycycle = fb.keydelay 
		end
	
		if love.keyboard.isDown("down") then
			fb.index = math.min(fb.index +1,#fb.list)
			fb.keycycle = fb.keydelay 
		end
		
		if love.keyboard.isDown("pageup") then
			fb.index = math.max(1,fb.index - fb.limit/2)
			fb.keycycle = fb.keydelay 
		end
	
		if love.keyboard.isDown("pagedown") then
			fb.index = math.min(#fb.list,fb.index + fb.limit/2)
			fb.keycycle = fb.keydelay 
		end
	end
	
	if #fb.list > fb.limit then
		fb.scrollbar = true
	else
		fb.scrollbar = false
	end

	-- scroll through the folder contents
	if fb.index > fb.max then 
	  fb.min = fb.min + 1
	  fb.max = fb.max + 1
	elseif fb.index < fb.min then 
	  fb.min = fb.min - 1
	  fb.max = fb.max - 1
	end
end


function fb.keypressed(key)

	if not fb.active then return end

	--selecting a file/folder

	if key == "return" then

		local path = fb.cwd .. "/" .. fb.list[fb.index] 
		
		if love.filesystem.isDirectory(path) then
		
			if not (fb.cwd == "") then
				if fb.index == 1 then
					fb.cwd =  fb.cwd:match("(.*)/")
				else
					fb.cwd = path
				end
			else
				fb.cwd = path
			end

			fb.list = fb:get_dir_items(fb.cwd)
			fb.index = 1
			fb.min = 1
			fb.max = math.min(#fb.list,fb.limit)
		else
		
			-- execute callback if this is a file
			fb.callback(path)

			--close file browser
			fb.show(false)
		end

	end
	
	if key == "home" then
		fb.index = 1
	end


end

return fb
