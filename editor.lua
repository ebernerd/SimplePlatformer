local tileset = love.graphics.newImage( "resources/tilemap.png" )
tileset:setFilter( "nearest", "nearest" )

editor = {
	mx = 0,
	my = 0,
	tilesize = 50,	
	layer = 1,
	selected = 2,
	debug = true,
	filename = "Untitled",
	saved = false,
	camspeed = 1,
	scrolltimer = 0,
	showscroll = false,
}

local layers = {"fg", "mg", "bg"}
local tiles = {}
local chunk = love.filesystem.load( "resources/tiles.lua" )()
for k, v in pairs( chunk ) do
	table.insert( tiles, v )
end

function editor.update( dt )

	if Game.State == "Editor" then
		if editor.showscroll then
			editor.scrolltimer = editor.scrolltimer + dt
			if editor.scrolltimer > 0.7 then
				editor.showscroll = false
				editor.scrolltimer = 0
			end
		end
	
		if love.keyboard.isDown("w") then
			camera.y = camera.y - editor.camspeed
		elseif love.keyboard.isDown("s") then
			camera.y = camera.y + editor.camspeed
		end
		if love.keyboard.isDown("a") then
			camera.x = camera.x - editor.camspeed
		elseif love.keyboard.isDown("d") then
			camera.x = camera.x + editor.camspeed
		end

		editor.mx = math.ceil( ( love.mouse.getX() + camera.x ) / editor.tilesize ) * editor.tilesize - editor.tilesize
		editor.my = math.ceil( ( love.mouse.getY() + camera.y ) / editor.tilesize ) * editor.tilesize - editor.tilesize

		if love.mouse.isDown( 1 ) then
			if not map.checkPos( editor.mx, editor.my, layers[editor.layer] ) then
				editor.saved = false
				map.placeTile( editor.mx, editor.my, layers[editor.layer], copy3(tiles[editor.selected]) )
			end
		elseif love.mouse.isDown( 2 ) then
			if map.checkPos( editor.mx, editor.my, layers[editor.layer] ) then
				editor.saved = false
				map.removeTile( editor.mx, editor.my, layers[editor.layer] )
			end
		end

	end

end

function editor.draw()
	
	if Game.State == "Editor" then


		--love.graphics.setBackgroundColor( 63, 159, 193 )
		--Draw cursor thing--
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.rectangle( "line", editor.mx, editor.my, editor.tilesize, editor.tilesize )
		love.graphics.setColor( 255, 255, 255 )
		
		if editor.debug then
			love.graphics.setColor( 230, 230, 230 )
			local bh = camera.y + Game.Height - 75
			local fh = love.graphics.getFont():getHeight()+5
			love.graphics.rectangle( "fill", camera.x, bh, Game.Width, 75 )
			love.graphics.setColor( 42, 42, 42 )
			love.graphics.print( "Layer: " .. layers[editor.layer], camera.x, bh )
		end

		if editor.showscroll then

			Game.SetFont( "OpenSans-Light", 35 )

			love.graphics.setColor( 255, 255, 255, 50 )
			love.graphics.rectangle("fill", camera.x, camera.y, Game.Width, Game.Height)

			love.graphics.setColor( 255, 255, 255 )
			love.graphics.printf( tiles[editor.selected].texture, camera.x, camera.y + (Game.Height/2), Game.Width, "center" )
			love.graphics.draw( tileset, map.quads[tiles[editor.selected].texture], camera.x + Game.Width/2 -25, camera.y + (Game.Height/2)-50)
			
			Game.SetFont( "OpenSans-Light", 20 )

		end

	end

end

function editor.keypressed( key )
	if Game.State == "Editor" then
		if key == "s" then
			if love.keyboard.isDown("lctrl") and not editor.saved then
				print( "saving" )
				editor.save( editor.filename )
			end
		elseif key == "o" then
			if love.keyboard.isDown("lctrl") then
				editor.load("Untitled")
				editor.saved = true
			end
		elseif key == "0" then
			if love.keyboard.isDown("lctrl") then
				camera.x = 0
				camera.y = 0
			end
		end
	end
end

function editor.keyreleased( key )
	if Game.State == "Editor" then
		if key == "tab" then

			editor.layer = editor.layer + 1
			if editor.layer > 3 then
				editor.layer = 1
			end

		elseif key == "f3" then

			editor.debug = not editor.debug
		
		elseif key == "l" then
			if love.keyboard.isDown("lctrl") then
				editor.initializeTest()
			end
		end
	end
end

function editor.wheelmoved( x, y )
	if y ~= 0 then
		editor.showscroll = true
		editor.scrolltimer = 0
	end
	if y > 0 then
		editor.selected = editor.selected + 1
		if editor.selected > #tiles then
			editor.selected = 1
		end
	elseif y < 0 then
		editor.selected = editor.selected - 1
		if editor.selected < 1 then
			editor.selected = #tiles
		end
	end
end

function editor.save( name )
	editor.saved = true
	local savedata = {}
	--Save scheme 1
	--[[ for i, v in pairs( map.tiles ) do
		local t = {
			x = v.x/editor.tilesize,
			y = v.y/editor.tilesize,
			t = v.texture,
			l = v.layer,			
		}
		table.insert( savedata, t )
	end --]]
	for i, v in pairs( map.tiles ) do

		local x = v.x/editor.tilesize
		local y = v.y/editor.tilesize
		if not savedata[v.layer] then savedata[v.layer] = {} end
		if not savedata[v.layer][x] then savedata[v.layer][x] = {} end
		table.insert( savedata[v.layer][x], {y = y; t = v.texture} )

	end
	if not love.filesystem.isDirectory("saves/") then
		love.filesystem.createDirectory("saves")
	end
	love.filesystem.write("saves/" .. name .. ".lua", table.serialize( savedata ) )

end

function editor.load( name )
	map.tiles = {}
	map.animated = {}
	map.nonstatic = {}
	if love.filesystem.isFile( "saves/" .. name .. ".lua" ) then
		local chunk = love.filesystem.load("saves/" .. name .. ".lua")()
		for layer, xlayer in pairs( chunk ) do
			for x, j in pairs( xlayer ) do
				for i, v in pairs(j) do
					map.placeTile(x*editor.tilesize, v.y*editor.tilesize, layer, {texture=v.t})
				end
			end
		end
		camera.x = 0
		camera.y = 0
	else
		error("Can't find \"saves/" .. name .. ".lua\"!")
	end

end

function editor.initializeTest()

	Game.PlayMode = "Test"
	editor.save( "temp" )
	map.build( "temp" )	
	player.init()

end

function editor.shutdownTest()
	Game.State = "Editor"
	editor.load("temp")
	love.filesystem.remove("saves/temp.lua")
end