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

local Villager = Class
{
  type = GameObject.newType("Villager"),

  init = function(self, x, y)
    GameObject.init(self, x, y)  
    self.z = 0
    self.t = 0
  end,
}
Villager:include(GameObject)

--[[------------------------------------------------------------
Game loop
--]]--

function Villager:update(dt)
	self.t = self.t + 2*dt
	if self.t > 1 then
		self.t = self.t - 1
	end
	self.z = 2*math.abs(math.sin(self.t*math.pi*2))
end

function Villager:draw()
	love.graphics.setColor(26, 16, 16)
	love.graphics.draw(img_shadow, self.x, self.y, 0, 1, 1, 3, 2)
	useful.bindWhite()
	love.graphics.draw(img_villager, self.x, self.y - self.z, 0, 1, 1, 3, 5)
end

--[[------------------------------------------------------------
Export
--]]--

return Villager