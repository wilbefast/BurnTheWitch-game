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
  life = 1,

  init = function(self, args)
    GameObject.init(self, args.x, args.y)  
    self.z = 0
    self.heat = 0
    self.t = math.random()
    self.sprite = img_villager[math.floor(math.random()*3) + 1]
  end,
}
Villager:include(GameObject)

--[[------------------------------------------------------------
Burn
--]]--

function Villager:burn(amount)
	self.heat = self.heat + amount
	if self.heat > 1 then
		audio:play_sound("immolate", 0.1)
		self.fire = true
		Particle.multiple({
			x = self.x,
			y = self.y,
			speed = 15,
			z_speed = 18,
			z = 2 + self.z,
			red = 209,
			green = 217,
			blue = 0,
			life = 0.5 + 0.3*math.random(),
			gravity = 4
		}, 10)
		self.z = 0
		shake = shake + 2
	end
	self:stopSpeaking()
end

--[[------------------------------------------------------------
Speach
--]]--

function Villager:startSpeaking()
	self.destination = nil
	self.dx, self.dy = 0, 0
	self.z = 0
	audio:play_sound("speak", 0.3)
	self.speach = true
end

function Villager:stopSpeaking()
	self.speach = false
end

--[[------------------------------------------------------------
Game loop
--]]--

function Villager:poof()
	if self.t > 1 then
		audio:play_sound("jump", 0.3)
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
end

function Villager:update(dt)
	GameObject.update(self, dt)

	-- wrap
	if self.x > WORLD_W + 4 then
		self.x = -4
	elseif self.x < -4 then
		self.x = WORLD_W + 4 
	end
	if self.x > WORLD_H + 4 then
		self.y = -4
		wrapped = true
	elseif self.y < -4 then
		self.x = WORLD_H + 4 
	end

	-- cool down
	if self.heat > 0 then
		self.heat = self.heat - 0.3*dt
	else
		self.heat = 0
	end

	-- on fire ?
	if self.fire then
		if self.x > 2 and self.x < (WORLD_W - 2) and self.y > 2 and (self.y < WORLD_H - 2) then
			self.life = self.life - dt*0.5
			if self.life < 0 then
				self.purge = true
				audio:play_sound("die", 0.2)
				Ash({
					x = self.x, 
					y = self.y
				})
				return
			end
		end

		-- turn
		if not self.angle then
			self.angle = math.random()*math.pi*2
		else
			self.angle = self.angle + 4*(math.random() - math.random())*dt
		end
		self.dx, self.dy = math.cos(self.angle)*self.speed*(2 + 2*self.life), math.sin(self.angle)*self.speed*(2 + 2*self.life)
		local pull_x, pull_y = (WORLD_W*0.5) - self.x, (WORLD_H*0.5) - self.y
		self.dx, self.dy = self.dx + 1.2*pull_x, self.dy + 1.2*pull_y

		-- jump
		self.t = self.t + (2 + math.random())*dt*(0.3 + 0.7*self.life)
		self.z = 6*math.abs(math.sin(self.t*math.pi*2))*(0.3 + 0.7*self.life)
		self:poof()

		-- embers
		Particle({
			x = self.x,
			y = self.y,
			speed = 5,
			z_speed = 12,
			z = 2 + self.z,
			red = 209,
			green = 217,
			blue = 0,
			life = 0.1 + 0.7*math.random(),
			gravity = 4
		})

		-- smoke
		if math.random() > 0.4 then
			Particle({
				x = self.x,
				y = self.y,
				speed = 2,
				z_speed = 8,
				z = 2 + self.z,
				red = 191,
				green = 191,
				blue = 189,
				life = 0.5 + 0.6*math.random(),
				gravity = 6
			})
		end

	-- destination ?
	elseif self.destination then
		local dist = Vector.dist(self.x, self.y, self.destination.x, self.destination.y)
		if dist < 8 then
			self.destination = nil
			self.z = 0
			self.t = 0
			return
		end
		local speed = self.speed*(1 + self.heat)
		local dx, dy = (self.destination.x - self.x)/dist, (self.destination.y - self.y)/dist
		self.dx, self.dy = dx*speed, dy*speed

		-- jump around
		self.t = self.t + 2*dt*(1 + self.heat)
		self.z = 3*math.abs(math.sin(self.t*math.pi*2))
		self:poof()
	elseif not self.speach then
		-- wait for a bit
		self.t = self.t + dt*math.random()*(1 + 2*self.heat)
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
	if self.fire then
		love.graphics.draw(img_villager_burning, self.x, self.y - self.z, 0, 1, 1, 3, 5)
	else
		love.graphics.draw(self.sprite, self.x, self.y - self.z, 0, 1, 1, 3, 5)
	end

	if self.speach then
		love.graphics.draw(self.sprite, self.x, self.y - self.z, 0, 2, 2, 3, 5)
	end
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