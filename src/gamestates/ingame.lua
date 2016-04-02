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
			x = 4 + math.random()*56, 
			y = 4 + math.random()*56 
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
end

function state:draw()
	love.graphics.draw(FLOOR_CANVAS, 0, 0)
	GameObject.drawAll()
	love.graphics.draw(img_overlay, 0, 0)
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state