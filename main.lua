Game = {
	Width = love.graphics.getWidth(),
	Height = love.graphics.getHeight(),
	State = "Editor",
	PlayMode = "Test",
	Controls = {
		Left = "a",
		Right = "d",
		Jump = "space",
		Sprint = "lshift",
	},
	Fonts = {},
	Font = function( fontface, size )

		if not Game.Fonts[fontface] then
			Game.Fonts[fontface] = {}
		end
		if not Game.Fonts[fontface][size] then
			Game.Fonts[fontface][size] = love.graphics.newFont( "resources/" .. fontface .. ".ttf", size )
		end

		return Game.Fonts[fontface][size]

	end,
	SetFont = function( fontface, size )
		love.graphics.setFont( Game.Font( fontface, size ) )
	end,
	Worlds = {
		[1] = {
			name = "Grasslands",
			description = "Testing stuffs!",
			gravity = 750,
			levels = {
				[1] = "1",
				[2] = "2",

			}
		}
	},
}
tween = require "tween"
bump = require "bump"
require "copy"
require "camera"
require "ser"
require "editor"
require "map"
require "player"

function love.load()

	Game.SetFont( "OpenSans-Light", 20 )

end

function love.update( dt )

	editor.update( dt )
	player.update( dt )
	map.update( dt )

end

function love.draw()

	camera:set()

		map.draw()
		editor.draw()
		player.draw()

	camera:unset()

end

function love.keypressed( key )

	editor.keypressed( key )
	player.keypressed( key )
end

function love.keyreleased( key )

	if Game.State == "Editor" then
		editor.keyreleased( key )
	else
		if key == "l" and love.keyboard.isDown('lctrl') and Game.State == "Game" and Game.PlayMode == "Test" then
			editor.shutdownTest()
			print("shutting down test")
		end
	end

end

function love.mousepressed( x, y, button )

end

function love.mousereleased( x, y )

end

function love.wheelmoved( x, y )
	
	editor.wheelmoved( x, y )

end