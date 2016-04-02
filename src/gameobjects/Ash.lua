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
Initialisation
--]]--

local Ash = Class
{
  type = GameObject.newType("Ash"),

  init = function(self, args)
    GameObject.init(self, args.x, args.y)  

		useful.pushCanvas(FLOOR_CANVAS)
			love.graphics.draw(img_ash, self.x, self.y, 0, 1, 1, 4, 3)
		useful.popCanvas()

  end,
}
Ash:include(GameObject)

--[[------------------------------------------------------------
Game loop
--]]--

function Ash:update(dt)
	if GameObject.countOfType("Villager") > 0 then
		-- smoke
		if math.random() > 0.4 then
			Particle({
				x = self.x,
				y = self.y,
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

function Ash:draw()
end

--[[------------------------------------------------------------
Export
--]]--

return Ash