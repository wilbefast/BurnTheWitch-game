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

--[[------------------------------------------------------------
LOCAL VARIABLES
--]]------------------------------------------------------------

local WORLD_CANVAS = nil
local CAPTURE_SCREENSHOT = false
local DEBUG = false

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
  Villager = require("gameobjects/Villager")
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
  img_villager = love.graphics.newImage("assets/png/villager.png")
  img_shadow = love.graphics.newImage("assets/png/shadow.png")

  -- initialise random
  math.randomseed(os.time())

  -- no mouse
  love.mouse.setVisible(false)
  if love.system.getOS() == "Android" then
    HIDE_CURSOR = true
  end

  -- save directory
  love.filesystem.setIdentity("BurnTheWitch")

  -- window title
  love.window.setTitle("#BurnTheWitch")

  -- canvas
  WORLD_CANVAS = love.graphics.newCanvas(64, 64)
  
  -- window icon
  --love.window.setIcon(love.image.newImageData("assets/png/icon.png"))

  -- clear colour
  love.graphics.setBackgroundColor(0, 0, 0)

  -- play music
  --audio:play_music("music", 0.3)


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
  GameState.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  GameState.mousereleased(x, y, button)
end

function love.update(dt)
	GameState.update(dt)
end

function love.draw()
  love.graphics.setFont(font)

  useful.pushCanvas(WORLD_CANVAS)
    -- clear
    love.graphics.setColor(64, 41, 41)
    love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
    useful.bindWhite()
    -- draw any other state specific stuff
    GameState.draw()
  useful.popCanvas()

  love.graphics.push()
    -- scaling
    love.graphics.scale(WINDOW_SCALE, WINDOW_SCALE)
    -- playable area is the centre sub-rect of the screen
    love.graphics.translate((WINDOW_W - VIEW_W)*0.5/WINDOW_SCALE, (WINDOW_H - VIEW_H)*0.5/WINDOW_SCALE)
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