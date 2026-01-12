import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx = playdate.graphics

local system6Font = gfx.font.new("fonts/SYSTEM6")
gfx.setFont(system6Font)

-- offset from upper left corner to start of tilemap
local tilemapOffsetX = 8
local tilemapOffsetY = 2
local tileGridWidth = 12
local tileGridHeight = 7
local tilesImageTable = gfx.imagetable.new("pics/tiles")
local tilemap = gfx.tilemap.new()
tilemap:setImageTable(tilesImageTable)

local function setupTilesForScreen()
  gfx.sprite.addWallSprites(tilemap, {2}, tilemapOffsetX, tilemapOffsetY)
  tilemap:setTiles({
    1,1,1,1,1,1,1,1,1,1,1,1,
    1,2,2,2,2,2,2,2,1,2,2,1,
    1,2,2,2,2,2,2,2,1,2,2,1,
    1,2,2,1,2,2,2,2,1,2,2,1,
    1,2,2,1,2,2,2,2,2,2,2,1,
    1,2,2,1,2,2,2,2,2,2,2,1,
    1,1,1,1,1,1,1,1,1,1,1,1,
  }, tileGridWidth)
end

local function canGoTo(x, y)
  -- check tile (adjust) for lua 1 index ew
  local nextTileIndex = tilemap:getTileAtPosition(x + 1, y + 1)
  if nextTileIndex == 2 then
    return true
  else
    return false
  end
  return false
end

-- these assume that tilemap is 32 x 32 squares
local function gridToScreenX(x)
  return x * 32 + tilemapOffsetX + 16
end
local function gridToScreenY(y)
  return y * 32 + tilemapOffsetY + 16
end

local playerImage = gfx.image.new("pics/player")
local playerBackImage = gfx.image.new("pics/playerBack")
local playerRightImage = gfx.image.new("pics/playerRight")
local playerZ = 5
local playerSprite = gfx.sprite.new(playerImage)

local x = 1
local y = 1


playerSprite:moveTo(gridToScreenX(x), gridToScreenY(y))
playerSprite:setZIndex(playerZ)
playerSprite:add()

local stairsImage = gfx.image.new("pics/stairs")
local stairsSprite = gfx.sprite.new(stairsImage)
local stairX = 5
local stairY = 3
local stairZ = 4
stairsSprite:moveTo(gridToScreenX(stairX), gridToScreenY(stairY))
stairsSprite:setZIndex(stairZ)
stairsSprite:add()

gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0,0,400,240)

gfx.sprite.setBackgroundDrawingCallback(
  function( _x, _y, width, height)
    tilemap:draw(tilemapOffsetX, tilemapOffsetY)
  end
)

local lastDir = "down"

local healthSpriteText = gfx.sprite.spriteWithText("VIBES: 4", 1000, 13)
healthSpriteText:setCenter(0, 0)
healthSpriteText:moveTo(tilemapOffsetX, 226)
healthSpriteText:setZIndex(10)
healthSpriteText:add()

--init section
setupTilesForScreen()

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
end

--left button
function playdate.leftButtonDown()
  if canGoTo(x -1, y) then    
    x -= 1
    lastDir = "left"
  end
end


--right button
function playdate.rightButtonDown()
  
  if canGoTo(x + 1, y) then    
    x += 1
    lastDir = "right"
  end
end

--down button
function playdate.downButtonDown()
  if canGoTo(x, y + 1) then 
    y += 1
    lastDir = "down"
  end
end


--up button
function playdate.upButtonDown()
  if canGoTo(x, y - 1) then 
    y -= 1
    lastDir = "up"
  end
end

