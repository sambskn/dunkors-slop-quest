import "CoreLibs/graphics"

local gfx = playdate.graphics

local system6Font = gfx.font.new("fonts/SYSTEM6")
gfx.setFont(system6Font)

local playerImage = gfx.image.new("pics/player")
local playerBackImage = gfx.image.new("pics/playerBack")
local playerRightImage = gfx.image.new("pics/playerRight")

gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0,0,400,240)

local x = 200
local y = 120

local leftDown = false
local rightDown = false
local upDown = false
local downDown = false

local labelOffset = 16
local speed = 2

local lastDir = "down"

function playdate.update()
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(0,0,400,240)

  gfx.setColor(gfx.kColorBlack)
  if lastDir == "down" then
    playerImage:drawAnchored(x, y, 0.5, 0.5)
  elseif lastDir == "up" then
    playerBackImage:drawAnchored(x, y, 0.5, 0.5)
  elseif lastDir == "right" then
    playerRightImage:drawAnchored(x, y, 0.5, 0.5)
  elseif lastDir == "left" then
    playerRightImage:drawAnchored(x, y, 0.5, 0.5, gfx.kImageFlippedX)
  end
  
  if leftDown then
    x -= 1 * speed
    lastDir = "left"
  end
  if rightDown then
    x += 1 * speed
    lastDir = "right"
  end
  if upDown then
    y -= 1 * speed
    lastDir = "up"
  end
  if downDown then
    y += 1 * speed
    lastDir = "down"
  end

  gfx.drawText("it YOU playboy", x + labelOffset, y + labelOffset)

  playdate.drawFPS(0,0)
end


function playdate.leftButtonDown() leftDown = true end
function playdate.leftButtonUp() leftDown = false end
function playdate.rightButtonDown() rightDown = true end
function playdate.rightButtonUp() rightDown = false end
function playdate.upButtonDown() upDown = true end
function playdate.upButtonUp() upDown = false end
function playdate.downButtonDown() downDown = true end
function playdate.downButtonUp() downDown = false end
