local tileset = love.graphics.newImage( "resources/tilemap.png" )
tileset:setFilter( "nearest", "nearest" )

map = {
	tiles = {},
	nonstatic = {},
	animated = {},
	spritebatches = {
		fg = love.graphics.newSpriteBatch( tileset, 5000 ),
		mg = love.graphics.newSpriteBatch( tileset, 5000 ),
		bg = love.graphics.newSpriteBatch( tileset, 5000 ),
	},
	quads = {},
}

--Add the texture quads
local tilemaplookup = {
	{ "dirt", "grass", "cutoffleft", "cutofftop", "cutoffright", "cutoffbottom", "", "", "", "" },
	{ "gcl", "gcr", "gcil", "gcir", "", "", "", "", "", ""},
	{ "goal", "", "", "", "", "", "", "", "", "" }
}
for y, b in pairs( tilemaplookup ) do
	for x, k in pairs( b ) do
		local xa = (x-1)*editor.tilesize
		local ya = (y-1)*editor.tilesize
		map.quads[ k ] = love.graphics.newQuad( (x-1)*editor.tilesize, (y-1)*editor.tilesize, editor.tilesize, editor.tilesize, tileset:getWidth(), tileset:getHeight() )
	end
end



local tile = {
	x = 0,
	y = 0,
	w = 50, --editor.tilesize
	h = 50, --editor.tilesize
	texture = "dirt",
	hasAnimation = false,
	layer = "mg",
	static = true,

	draw = function( self )
		if self.hasAnimation then

		end
	end,
	update = function( self, dt )
		if not self.static then
			if self.onupdate then self:onupdate( dt ) end
		end
	end,
	oncontact = function( self, x, y )
		--For when the player contacts this object
	end
}
tile.__index = tile

function tile:new( data )
	local data = data or {}
	local self = setmetatable( data, tile )
	return self
end

function map.placeTile( x, y, layer, data )
	--for loading levels without colliders
	local data = data or {}
	data.x = x
	data.y = y
	data.layer = layer
	local t = tile:new( data )
	if t.hasAnimation then
		table.insert( map.animated, t )
	end
	if not t.static then
		table.insert( map.nonstatic, t )
	end
	table.insert( map.tiles, t )
	map.updateSpriteBatches()
	return
end

function map.placeTileInWorld( x, y, layer, data )
	--For loading levels with colliders
	map.placeTile( x, y, layer, data )
	if not data.nocolliders and Game.World then
		Game.World:add("obj"..tostring(#map.tiles), x, y, editor.tilesize, editor.tilesize)
	end
end

function map.removeTile( x, y, layer )
	for i, v in pairs( map.tiles ) do
		if v.x == x and v.y == y and v.layer == layer then
			table.remove( map.tiles, i )
			v = nil
			map.updateSpriteBatches()
			return
		end
	end
end

function map.advanceLevel()

end

function map.update( dt )
	for i, v in pairs( map.nonstatic ) do
		if v.update then v:update( dt ) end
	end
end

function map.draw( )

	if Game.State == "Editor" or Game.State == "Game" then

		love.graphics.setColor( 255, 255, 255 )

		love.graphics.draw( map.spritebatches.bg )
		for i, v in pairs( map.animated ) do
			if v.layer == "bg" and v.draw then v:draw() end
		end
		love.graphics.draw( map.spritebatches.mg )
		for i, v in pairs( map.animated ) do
			if v.layer == "mg" and v.draw then v:draw() end
		end

		if Game.State == "Game" then
			player.draw()
		end

		love.graphics.draw( map.spritebatches.fg )
		for i, v in pairs( map.animated ) do
			if v.layer == "fg" and v.draw then v:draw() end
		end

	end
end

function map.checkPos( x, y, layer )
	for i, v in pairs( map.tiles ) do
		if v.x == x and v.y == y and layer == v.layer then
			return true
		end
	end
	return false
end

function map.updateSpriteBatches()

	for i, v in pairs( map.spritebatches ) do
		v:clear()
	end
	for i, v in pairs( map.tiles ) do
		map.spritebatches[v.layer]:add( map.quads[ v.texture ], v.x, v.y, 0, 1, 1 )
	end

end

function map.build( name )
	Game.World = bump.newWorld(15)
	if love.filesystem.isFile( "saves/" .. name .. ".lua" ) then
		local chunk = love.filesystem.load("saves/" .. name .. ".lua")()
		for layer, xlayer in pairs( chunk ) do
			for x, j in pairs( xlayer ) do
				for i, v in pairs(j) do
					map.placeTileInWorld(x*editor.tilesize, v.y*editor.tilesize, layer, {texture=v.t})
				end
			end
		end
		Game.State = "Game"
	else
		error("Can't find \"saves/" .. name .. ".lua\"!")
	end

end