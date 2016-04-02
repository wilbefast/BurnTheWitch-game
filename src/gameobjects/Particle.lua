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

local Particle = Class
{
  type = GameObject.newType("Particle"),

  init = function(self, args)
    GameObject.init(self, args.x, args.y)  
    
    -- speed
    local speed
    if args.speed then
    	speed = args.speed
    else
    	speed = math.random()*4
    end

    -- direction
    local dx, dy
    if args.dx and args.dy then
    	dx, dy = args.dx, args.dy
    else
    	local r = math.random()*2*math.pi
    	dx = math.cos(r)*speed
    	dy = math.sin(r)*speed
    end
    local dz
    if args.dz then
    	dz = args.dz
    else
    	local r = math.random()*math.pi
    	dz = math.sin(r)*(args.z_speed or speed)
    end
    self.dx = dx
    self.dy = dy
    self.dz = dz

    -- height
    local z
    if args.z then
    	z = args.z
    else
    	z = 0
    end
    self.z = z

    -- colour
    self.red = args.red or 255
    self.green = args.green or 255
    self.blue = args.blue or 255
  end,
}
Particle:include(GameObject)

Particle.multiple = function(args, count)
	for i = 1, count do
		Particle(args)
	end
end

--[[------------------------------------------------------------
Game loop
--]]--

function Particle:update(dt)
	GameObject.update(self, dt)

	self.dz = self.dz - dt*10
	self.z = self.z + dt*self.dz
	if self.z < 0 then
		self.z = 0
		self.purge = true
	end
end

function Particle:draw()
	love.graphics.setColor(self.red, self.green, self.blue)
	love.graphics.points(self.x, self.y - self.z)
	useful.bindWhite()
end

--[[------------------------------------------------------------
Export
--]]--

return Particle