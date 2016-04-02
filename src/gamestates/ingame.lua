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
	FLOOR_CANVAS = love.graphics.newCanvas(64, 64)
	useful.pushCanvas(FLOOR_CANVAS)
		love.graphics.draw(img_background, 0, 0)
	useful.popCanvas()
	for i = 1, 10 do
		Villager({
			x = 10 + math.random()*44, 
			y = 10 + math.random()*44 
		})
	end
end

function state:leave()
	GameObject.purgeAll()
	FLOOR_CANVAS = nil
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
		if villager and dist2 < 32 then
			villager.heat = villager.heat + 4*dt
			if villager.heat > 1 then
				villager.fire = true
			end
		end

		-- leave traces
		Particle.multiple({
			x = x,
			y = y,
			speed = 8,
			z_speed = 2,
			red = 209,
			green = 217,
			blue = 0
		}, 2)
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
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state