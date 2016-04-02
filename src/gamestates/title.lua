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
TITLE GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end

function state:enter()
end

function state:leave()
end

--[[------------------------------------------------------------
Callbacks
--]]--


function state:keypressed(key, uni)
  if key == "escape" then
  	return love.event.push("quit")
  end
end

function state:mousepressed()
	GameState.switch(ingame)
end


function state:update(dt)
end

function state:draw()

	-- text
	love.graphics.printf("Burn The Witch", WORLD_W*0.1, WORLD_H*0.1, WORLD_W*0.8, "center")
	love.graphics.printf("@wilbefast", WORLD_W*0.1, WORLD_H*0.55, WORLD_W*0.8, "center")
	love.graphics.printf("#lowrezjam", WORLD_W*0.1, WORLD_H*0.75, WORLD_W*0.8, "center")

  -- cursor
  if not HIDE_CURSOR then
	  local x, y = love.mouse.getPosition( )
	  x = (x - (WINDOW_W - VIEW_W)*0.5)/WINDOW_SCALE
	  y = (y - (WINDOW_H - VIEW_H)*0.5)/WINDOW_SCALE
	  --love.graphics.draw(cursor, x, y)
	end

  useful.bindWhite()

end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state