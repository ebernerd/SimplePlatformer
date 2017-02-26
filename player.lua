player = {
	x = 0,
	y = 0,
	w = 36,
	h = 54,
	health = 100,
	speed = 1750,
	sprint = 1.5,
	stamina = 100,
	xvel = 0,
	yvel = 0,
	animtimer = 0,
	animlimit = 0.3,
	anim = false,
	textures = {
		left = love.graphics.newImage("resources/player-left.png"),
		right = love.graphics.newImage("resources/player-right.png")
	},
	direction = "right",
	canJump = true,
	isFalling = false
}

for i, v in pairs(player.textures) do
	v:setFilter("nearest", "nearest")
end

function player.reset()
	player.health = 100
	player.x = 0
	player.y = 0
	player.xvel = 0
	player.yvel = 0
end

function player.init()
	player.reset()
	if Game.World then
		Game.World:add(player, player.x, player.y, player.w, player.h)
	end

end

function player.update( dt )
	if Game.State == "Game" then

		camera.x = player.x - Game.Width/2 + player.w/2
		camera.y = player.y - Game.Height/2 + player.h/2

		local ddx, ddy = 0, 0
		local sprint = 1
		if love.keyboard.isDown( Game.Controls.Sprint ) then
			sprint = player.sprint
			player.animlimit = 0.22
		else 
			player.animlimit = 0.3
		end
		if love.keyboard.isDown( Game.Controls.Left ) then
			ddx = -player.speed * sprint
			player.animtimer = player.animtimer + dt
			player.direction = "left"
		elseif love.keyboard.isDown( Game.Controls.Right ) then
			ddx = player.speed * sprint
			player.animtimer = player.animtimer + dt
			player.direction = "right"
		else
			player.animtimer = 0
			player.anim = false
		end

		if player.animtimer > player.animlimit then
			player.anim = not player.anim
			player.animtimer = 0
		end

		if player.yvel > 1 then
			player.canJump = false
			player.anim = false
			player.isFalling = true
		end

		player.xvel = (player.xvel+(ddx*dt))
		
		--if not player.isFalling then
			player.xvel = player.xvel * 0.995 --friction is sensitive for some reason
		--else
		--	player.xvel = player.xvel * 0.998
		--end

		player.yvel = player.yvel + (map.gravity*dt)

		if Game.World:hasItem( player ) then
			player.x, player.y, cols, len = Game.World:move( player, (player.x + player.xvel*dt), (player.y + player.yvel*dt) )
			if len > 0 then

				for i, col in pairs( cols ) do
					if col.normal.y == -1 then
						player.yvel = 0
						player.canJump = true
						player.isFalling = false
					end
					if col.normal.x ~= 0 then
						player.xvel = 0
					end
				end

			end
		end

	end
end

function player.draw()

	if Game.State == "Game" then
		
		local y = player.y
		if player.anim then y = y - 5 end
		love.graphics.draw( player.textures[player.direction], player.x, y )

	end

end

function player.keypressed( key )
	if key == Game.Controls.Jump and player.canJump then
		player.yvel = -350
		player.canJump = false
	end
end