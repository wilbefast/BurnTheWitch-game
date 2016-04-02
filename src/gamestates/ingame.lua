--[[
(C) Copyright 2016 William Dyce

All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

--[[------------------------------------------------------------
INGAME GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end

function state:enter()
	for i = 1, 10 do
		if i%2 == 0 then
			Villager({
				x = WORLD_W + 5, 
				y = WORLD_H*math.random() 
			})
		else
			Villager({
				x = -5, 
				y = WORLD_H*math.random() 
			})
		end
	end
end

function state:leave()
	GameObject.purgeAll()
end

--[[------------------------------------------------------------
Callbacks
--]]--

function state:keypressed(key, uni)
  if key == "escape" then
  	GameState.switch(title)
  end
end

function state:mousepressed(x, y)
	if GameObject.countOfType("Villager") <= 0 then
		GameState.switch(title)
	end
end

function state:gamepadpressed(joystick, button)
end

local _view = { oblique = true }
function state:update(dt)
	GameObject.updateAll(dt, _view)

	if cursor_lit then
	  local x, y = love.mouse.getPosition()
		x, y = scaling.scaleMouse(x, y)

		-- set fire to dudes
		local villager, dist2 = GameObject.getNearestOfType("Villager", x, y, function(villager) 
			return not villager.fire 
		end)
		if villager and dist2 < 24 then
			villager.heat = villager.heat + 4*dt
			if villager.heat > 1 then
				villager.fire = true
				Particle.multiple({
					x = villager.x,
					y = villager.y,
					speed = 15,
					z_speed = 18,
					z = 2 + villager.z,
					red = 209,
					green = 217,
					blue = 0,
					life = 0.5 + 0.3*math.random(),
					gravity = 4
				}, 10)
				villager.z = 0
				shake = shake + 2
			end
		end

		-- flaming embers
		Particle.multiple({
			x = x,
			y = y,
			speed = 4,
			z_speed = 12,
			z = 2,
			red = 209,
			green = 217,
			blue = 0,
			life = 0.1 + 0.7*math.random(),
			gravity = 4
		}, 2)

		-- smoke
		if math.random() > 0.4 then
			Particle({
				x = x,
				y = y,
				speed = 2,
				z_speed = 8,
				z = 1,
				red = 191,
				green = 191,
				blue = 189,
				life = 0.5 + 0.6*math.random(),
				gravity = 6
			})
		end
	end
end

function state:draw()
	love.graphics.draw(FLOOR_CANVAS, 0, 0)
	GameObject.drawAll()
	love.graphics.draw(img_overlay, 0, 0)

	if cursor_lit and math.random() > 0.5 then
	  local x, y = love.mouse.getPosition()
  	x, y = scaling.scaleMouse(x, y)
		useful.pushCanvas(FLOOR_CANVAS)
			love.graphics.setColor(32, 16, 16)
			love.graphics.points(x, y, x + 2*math.random() - 2*math.random(), y + 2*math.random() - 2*math.random())
			useful.bindWhite()	
		useful.popCanvas()
	end

	if GameObject.countOfType("Villager") <= 0 then
	  --love.graphics.draw(img_stipple, 0, 0)

		-- text
		useful.bindBlack()
		love.graphics.printf("Well done! Now there are no more witches.", 
			WORLD_W*0.1, WORLD_H*0.15 + 1, WORLD_W*0.8, "center")
		love.graphics.setColor(215, 217, 160)
		love.graphics.printf("Well done! Now there are no more witches.", 
			WORLD_W*0.1, WORLD_H*0.15, WORLD_W*0.8, "center")
	  useful.bindWhite()
	end
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state