--[[
	example usage
--]]

function love.load()
	love.graphics.setBackgroundColor(100,100,100)
	
	filebrowser = require("lfb")
	
	filebrowser.callback = function(path) 
		print (path) 
	end
	
end

function love.update(dt)
	filebrowser.update(dt)
end

function love.draw()
	love.graphics.print("Press [space] to open file browser",10,love.graphics.getHeight()-20)
	filebrowser.draw(20,20)
end


function love.keypressed(key)
	if key == "space" then
		filebrowser.show(true)
	end

	if key == "escape" then
		love.event.quit()
	end

	filebrowser.keypressed(key)

end
