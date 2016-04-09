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
GLOBAL VARIABLES
--]]------------------------------------------------------------

WORLD_W, WORLD_H = 64, 64
FLOOR_CANVAS = nil
shake = 0

--[[------------------------------------------------------------
LOCAL VARIABLES
--]]------------------------------------------------------------

local WORLD_CANVAS = nil
local CAPTURE_SCREENSHOT = false
local DEBUG = false

local cursor_t = 0
local cursor_i = 1
cursor_lit = false

--[[------------------------------------------------------------
LOVE CALLBACKS
--]]------------------------------------------------------------

function love.load(arg)

  -- "Unrequited" library
  Class = require("unrequited/Class")
  Vector = require("unrequited/Vector")
  GameState = require("unrequited/GameState")
  GameObject = require("unrequited/GameObject")
  babysitter = require("unrequited/babysitter")
  useful = require("unrequited/useful")
  audio = require("unrequited/audio")
  log = require("unrequited/log")
  log:setLength(21)

  -- game-specific code
  Particle = require("gameobjects/Particle")
  Villager = require("gameobjects/Villager")
  Ash = require("gameobjects/Ash")
  scaling = require("scaling")
  ingame = require("gamestates/ingame")
  title = require("gamestates/title")

  -- set timestamp
  timestamp = useful.getTimestamp()

  -- startup logs
  log.print = true
  log:write("Starting '#BurnTheWitch'!")

  -- set scaling based on resolution
  scaling.reset()

  -- set interpolation
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setLineStyle("rough", 1)

  -- resources
  -- ... fonts
  font = love.graphics.newFont("assets/ttf/MunroSmall.ttf", 10)
  love.graphics.setFont(font)
  -- ... png
  img_background = love.graphics.newImage("assets/png/background.png")
  img_overlay = love.graphics.newImage("assets/png/overlay.png")
  img_villager = {
    love.graphics.newImage("assets/png/villager_1.png"),
    love.graphics.newImage("assets/png/villager_2.png"),
    love.graphics.newImage("assets/png/villager_3.png")
  }
  img_ash = love.graphics.newImage("assets/png/ash_pile.png")
  img_villager_burning = love.graphics.newImage("assets/png/villager_burning.png")
  img_shadow = love.graphics.newImage("assets/png/shadow.png")
  img_cursor = love.graphics.newImage("assets/png/cursor.png")
  img_cursor_fire = {
    love.graphics.newImage("assets/png/cursor_fire_1.png"),
    love.graphics.newImage("assets/png/cursor_fire_2.png"),
    love.graphics.newImage("assets/png/cursor_fire_3.png")
  }
  img_cursor_fire = useful.shuffle(img_cursor_fire)
  img_stipple = love.graphics.newImage("assets/png/stipple.png")

  -- initialise random
  math.randomseed(os.time())

  -- no mouse
  love.mouse.setVisible(false)
  if love.system.getOS() == "Android" then
    HIDE_CURSOR = true
  end
  cursor_t = math.random()

  -- save directory
  love.filesystem.setIdentity("BurnTheWitch")

  -- window title
  love.window.setTitle("#BurnTheWitch")

  -- canvases
  WORLD_CANVAS = love.graphics.newCanvas(64, 64)
  FLOOR_CANVAS = love.graphics.newCanvas(64, 64)
  useful.pushCanvas(FLOOR_CANVAS)
    love.graphics.draw(img_background, 0, 0)
  useful.popCanvas()

  -- window icon
  --love.window.setIcon(love.image.newImageData("assets/png/icon.png"))

  -- clear colour
  love.graphics.setBackgroundColor(0, 0, 0)

  -- play music
  audio:load_music("BurnTheWitch")
  audio:play_music("BurnTheWitch", 1)

  -- sound
  audio:load_sound("die", 1, 3)
  audio:load_sound("extinguish", 0.5, 2)
  audio:load_sound("ignite", 0.9, 2)
  audio:load_sound("immolate", 1, 3)
  audio:load_sound("jump", 1, 6)
  audio:load_sound("speak", 1, 2)
  audio:load_sound("start", 1, 1)
  audio:load_sound("win", 1, 1)

  GameState.switch(title)
end

function love.focus(f)
  GameState.focus(f)
end

function love.quit()
  GameState.quit()
end

function love.keypressed(key, uni)
  GameState.keypressed(key, uni)
  if key == "d" then
    DEBUG = not DEBUG
  elseif key == "x" then
    CAPTURE_SCREENSHOT = not CAPTURE_SCREENSHOT
  end
end

function love.keyreleased(key, uni)
  GameState.keyreleased(key, uni)
end

function love.mousepressed(x, y, button)
  local x, y = love.mouse.getPosition()
  x, y = scaling.scaleMouse(x, y)

  cursor_lit = true
  audio:play_sound("ignite", 0.3)
  Particle.multiple({
    x = x,
    y = y,
    speed = 12,
    z_speed = 18,
    z = 2,
    red = 209,
    green = 217,
    blue = 0,
    life = 0.3 + 0.3*math.random(),
    gravity = 4
  }, 4)
  GameState.mousepressed(x, y, button)

  shake = shake + 0.5
end

function love.mousereleased(x, y, button)
  audio:play_sound("extinguish", 0.3)
  local x, y = love.mouse.getPosition()
  x, y = scaling.scaleMouse(x, y)

  cursor_lit = false
  Particle.multiple({
    x = x,
    y = y,
    speed = 3,
    z_speed = 8,
    z = 2,
    red = 191,
    green = 191,
    blue = 189,
    life = 0.5 + 0.6*math.random(),
    gravity = 6
  }, 6)
  GameState.mousereleased(x, y, button)

  shake = shake + 0.3
end

function love.update(dt)
	GameState.update(dt)
  cursor_t = cursor_t + 12*dt
  if cursor_t > 1 then
    cursor_t = cursor_t - 1
    cursor_i = cursor_i + 1
    if cursor_i > #img_cursor_fire then
      cursor_i = 1
    end
  end

  shake = shake - 6*dt
  if shake < 0 then
    shake = 0
  end
end

function love.draw()
  local x, y = love.mouse.getPosition()
  x, y = scaling.scaleMouse(x, y)

  love.graphics.setFont(font)

  useful.pushCanvas(WORLD_CANVAS)
    -- clear
    love.graphics.setColor(64, 41, 41)
    love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
    useful.bindWhite()
    -- draw any other state specific stuff
    GameState.draw()
    -- draw cursor
    if not HIDE_CURSOR then
      if cursor_lit then
        love.graphics.draw(img_cursor, x, y + 2, 0, 1, -1)
        love.graphics.draw(img_cursor_fire[cursor_i], x - 3, y - 5)
      else
        love.graphics.draw(img_cursor, x, y)
      end
    end
  useful.popCanvas()

  love.graphics.push()
    -- scaling
    love.graphics.scale(WINDOW_SCALE, WINDOW_SCALE)
    -- playable area is the centre sub-rect of the screen
    love.graphics.translate(
      (WINDOW_W - VIEW_W)*0.5/WINDOW_SCALE + math.random()*shake, 
      (WINDOW_H - VIEW_H)*0.5/WINDOW_SCALE + math.random()*shake)
    -- draw the canvas
    love.graphics.draw(WORLD_CANVAS, 0, 0)
  love.graphics.pop() -- pop offset

  -- capture GIF footage
  if CAPTURE_SCREENSHOT then
    useful.recordGIF()
  end

  -- draw logs
  if DEBUG then
    log:draw(16, 48)
  end
end