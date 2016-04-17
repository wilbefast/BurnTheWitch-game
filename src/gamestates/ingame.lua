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

local _villager_pick_t
local _current_villager
local _all_villagers

local _current_symbol

local _is_victory

local state = GameState.new()

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end

function state:enter()
	_villager_pick_t = -4
	_current_villager = nil
	_all_villagers = {}
	
	_is_victory = false

	audio:play_sound("start")

	for i = 1, 10 do
		if i%2 == 0 then
			table.insert(_all_villagers, Villager({
				x = WORLD_W + 5, 
				y = WORLD_H*math.random() 
			}))
		else
			table.insert(_all_villagers, Villager({
				x = -5, 
				y = WORLD_H*math.random() 
			}))
		end
	end
end

function state:leave()
	_all_villagers = nil
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

	if not _is_victory then
		_villager_pick_t = _villager_pick_t + dt
		if _villager_pick_t > 3 then


			-- disable the old guy?
			if _current_villager then
				_current_villager:stopSpeaking()
				_current_villager = nil
				_villager_pick_t = 1.5
			-- pick a new guy?
			else
				local tries = #_all_villagers
				 
				repeat
					_current_villager = _all_villagers[1]
					table.remove(_all_villagers, 1)
					table.insert(_all_villagers, _current_villager)
					tries = tries - 1
				until (tries <= 0) or (not _current_villager.purge and not _current_villager.fire)

				-- success ?
				if not _current_villager.purge and not _current_villager.fire then
					_current_symbol = useful.randIn(img_symbol)

					_bubble_x = useful.clamp(_current_villager.x, 16, 48)

					if _current_villager.y < 32 then
						_bubble_y = _current_villager.y + 8
					else
						_bubble_y = _current_villager.y - 24
					end

					if _current_villager then
						_villager_pick_t = 0
						_current_villager:startSpeaking()
					end
				end
			end
		end
	end

	if cursor_lit then
	  local x, y = love.mouse.getPosition()
		x, y = scaling.scaleMouse(x, y)

		-- set fire to dudes
		local villager, dist2 = GameObject.getNearestOfType("Villager", x, y, function(villager) 
			return not villager.fire 
		end)
		if villager and dist2 < 24 then
			villager:burn(4*dt)
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

	if not _is_victory and GameObject.countOfType("Villager") <= 0 then
		_is_victory = true
		audio:play_sound("win")
		shake = shake + 1
	end
end

function state:draw()
	love.graphics.draw(FLOOR_CANVAS, 0, 0)
	GameObject.drawAll()

	if _current_villager and _current_villager.speach then
		love.graphics.draw(img_bubble, _bubble_x - 8, _bubble_y - 8)

		local dx, dy = Vector.normalise(_current_villager.x - _bubble_x, _current_villager.y - _bubble_y)
		local angle = math.atan2(dy, dx) + math.pi
		love.graphics.draw(img_bubble_attach, _bubble_x + dx*11, _bubble_y + dy*11, angle, 1, 1, 0, 4)
		
		love.graphics.draw(_current_symbol, _bubble_x - 6, _bubble_y - 6)
	end
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