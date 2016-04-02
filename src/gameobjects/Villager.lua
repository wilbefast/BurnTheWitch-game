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

  speed = 8,

  init = function(self, args)
    GameObject.init(self, args.x, args.y)  
    self.z = 0
    self.t = math.random()
  end,
}
Villager:include(GameObject)

--[[------------------------------------------------------------
Game loop
--]]--

function Villager:update(dt)
	-- on fire ?
	if self.fire then

	-- destination ?
	elseif self.destination then
		local dist = Vector.dist(self.x, self.y, self.destination.x, self.destination.y)
		if dist < 8 then
			self.destination = nil
			self.z = 0
			self.t = 0
			return
		end
		local dx, dy = (self.destination.x - self.x)/dist, (self.destination.y - self.y)/dist
		self.x, self.y = self.x + dx*dt*self.speed, self.y + dy*dt*self.speed

		-- jump around
		self.t = self.t + 2*dt
		if self.t > 1 then
			self.t = self.t - 1
			Particle.multiple({
				x = self.x,
				y = self.y,
				speed = 12,
				z_speed = 2,
				red = 153,
				green = 98,
				blue = 98
				}, 
				12)
			useful.pushCanvas(FLOOR_CANVAS)
				local r, g, b
				if math.random() > 0.5 then
					r, g, b = 115, 74, 74
				else
					r, g, b = 64, 41, 41
				end
				love.graphics.setColor(r, g, b)
				love.graphics.points(self.x, self.y,
					self.x + math.random(), self.y + math.random(),
					self.x - math.random(), self.y - math.random())
				useful.bindWhite()	
			useful.popCanvas()
		end
		self.z = 3*math.abs(math.sin(self.t*math.pi*2))
	else
		-- wait for a bit
		self.t = self.t + dt*math.random()
		if self.t > 1 then
			self.destination = {
				x = 4 + math.random()*56,
				y = 4 + math.random()*56
			}
		end
	end
end

function Villager:draw()
	love.graphics.setColor(26, 16, 16)
	love.graphics.draw(img_shadow, self.x, self.y, 0, 1, 1, 3, 2)
	useful.bindWhite()
	love.graphics.draw(img_villager, self.x, self.y - self.z, 0, 1, 1, 3, 5)
end

function Villager:eventCollision(other, dt)
	if other:isType("Villager") then
		local dx, dy = Vector.normalise(self.x - other.x, self.y - other.y)
		self.dx, self.dy = self.dx + dx, self.dy + dy
	end
end

--[[------------------------------------------------------------
Export
--]]--

return Villager