import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx = playdate.graphics

local system6Font = gfx.font.new("fonts/SYSTEM6")
gfx.setFont(system6Font)

local tilesImageTable = gfx.imagetable.new("pics/tiles")
local tilemap = gfx.tilemap.new()
tilemap:setImageTable(tilesImageTable)
tilemap:setTiles({
  1,1,1,1,1,1,1,1,1,1,1,1,
  1,2,2,2,2,2,2,2,2,2,2,1,
  1,2,2,2,2,2,2,2,2,2,2,1,
  1,2,2,2,2,2,2,2,2,2,2,1,
  1,2,2,2,2,2,2,2,2,2,2,1,
  1,2,2,2,2,2,2,2,2,2,2,1,
  1,1,1,1,1,1,1,1,1,1,1,1,
}, 12)

local tilemapOffsetX = 8
local tilemapOffsetY = 8

-- these assume that tilemap is 32 x 32 squares
function gridToScreenX(x)
  return x * 32 + tilemapOffsetX + 16
end
function gridToScreenY(y)
  return y * 32 + tilemapOffsetY + 16
end

local playerImage = gfx.image.new("pics/player")
local playerBackImage = gfx.image.new("pics/playerBack")
local playerRightImage = gfx.image.new("pics/playerRight")

local playerSprite = gfx.sprite.new(playerImage)

local x = 1
local y = 1

function wrapXY()
  if x > 11 then
    x = 0
  end
  if x < 0 then
    x = 11
  end
  if y > 6 then
    y = 0
  end
  if y < 0 then
    y = 6
  end
end

playerSprite:moveTo(gridToScreenX(x), gridToScreenY(y))
playerSprite:add()


gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0,0,400,240)

gfx.sprite.setBackgroundDrawingCallback(
  function( x, y, width, height)
    tilemap:draw(tilemapOffsetX, tilemapOffsetY)
  end
)

local lastDir = "down"

function playdate.update()
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(0,0,400,240)
  gfx.sprite.update()
  gfx.setColor(gfx.kColorBlack)
  if lastDir == "down" then
    playerSprite:setImage(playerImage)
  elseif lastDir == "up" then
    playerSprite:setImage(playerBackImage)
  elseif lastDir == "right" then
    playerSprite:setImage(playerRightImage)
  elseif lastDir == "left" then
    playerSprite:setImage(playerRightImage, gfx.kImageFlippedX)
  end

  playerSprite:moveTo(gridToScreenX(x), gridToScreenY(y))
  playdate.drawFPS(0,0)
end


--left button
function playdate.leftButtonDown()
  x -= 1
  lastDir = "left"
  wrapXY()
end


--right button
function playdate.rightButtonDown()
  x += 1
  lastDir = "right"
  wrapXY()
end

--down button
function playdate.downButtonDown()
  y += 1
  lastDir = "down"
  wrapXY()      
end


--up button
function playdate.upButtonDown()
  y -= 1
  lastDir = "up"
  wrapXY()      
end

