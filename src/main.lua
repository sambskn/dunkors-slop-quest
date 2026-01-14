import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/math"

local gfx = playdate.graphics

-- sounds
local synth = playdate.sound.synth.new(playdate.sound.kWaveSawtooth)
synth:setAttack(0.0125)
synth:setSustain(0.2)
synth:setRelease(0.125)
local noiseSynth = playdate.sound.synth.new(playdate.sound.kWaveNoise)
synth:setAttack(0.05)
synth:setSustain(0)
synth:setRelease(0.25)

local function moveNoise()
  local time = playdate.sound.getCurrentTime()
  synth:playNote("C3", 0.5, 0.2, time)
  synth:playNote("F3", 0.5, 0.2, time + 0.1)
end

local function bonkNoise()
  local time = playdate.sound.getCurrentTime()
  synth:playNote("G2", 0.5, 0.2, time)
  synth:playNote("F2", 0.5, 0.2, time + 0.51)
  synth:playNote("C2", 0.6, 0.2, time + 1.02)
end

local function stairsNoise()
  local time = playdate.sound.getCurrentTime()
  noiseSynth:playNote("C3", 0.1, 0.2, time)
  noiseSynth:playNote("B3", 0.1, 0.2, time + 0.11)
  noiseSynth:playNote("A3", 0.1, 0.2, time + 0.21)
end

-- font import yknow - this one nice
local system6Font = gfx.font.new("fonts/SYSTEM6")
gfx.setFont(system6Font)

-- level? config????
local currentLevel = 1
local levels = {
  {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 1,
    1, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 1,
    1, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 1,
    1, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 1,
    1, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  },
  {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1,
    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1,
    1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  },
  {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 1,
    1, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 1,
    1, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 1,
    1, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 1,
    1, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  },
}

local stairLocs = {
  {
    10, 1
  },
  {
    1, 1
  },
  {
    9, 1
  }
}

local startLocs = {
  {
    1, 5
  },
  {
    10, 5
  },
  {
    1, 1
  }
}

-- offset from upper left corner to start of tilemap
local tilemapOffsetX = 8
local tilemapOffsetY = 2
local tileGridWidth = 12
local tileGridHeight = 7
local tilesImageTable = gfx.imagetable.new("pics/tiles")
local tilemap = gfx.tilemap.new()
tilemap:setImageTable(tilesImageTable)


local function canGoTo(x, y)
  -- check tile (adjust) for lua 1 index ew
  local nextTileIndex = tilemap:getTileAtPosition(x + 1, y + 1)
  if nextTileIndex == 2 then
    return true
  else
    return false
  end
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
local playerSpriteTargetX = gridToScreenX(x)
local playerSpriteTargetY = gridToScreenY(y)

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
gfx.fillRect(0, 0, 400, 240)

gfx.sprite.setBackgroundDrawingCallback(
  function(_x, _y, _width, _height)
    tilemap:draw(tilemapOffsetX, tilemapOffsetY)
  end
)

local lastDir = "down"

local healthSpriteText = gfx.sprite.spriteWithText("VIBES: 4", 1000, 13)
healthSpriteText:setCenter(0, 0)
healthSpriteText:moveTo(tilemapOffsetX, 226)
healthSpriteText:setZIndex(10)
healthSpriteText:add()

local offsetXForLevelText = 200
local levelSpriteText = gfx.sprite.spriteWithText(string.format("LEVEL: %d", currentLevel), 1000, 13)
levelSpriteText:setCenter(0, 0)
levelSpriteText:moveTo(tilemapOffsetX + offsetXForLevelText, 226)
levelSpriteText:setZIndex(10)
levelSpriteText:add()

--init section
local function setupTilesForScreen(level)
  -- reset player to start pos for this floor
  x = startLocs[currentLevel][1]
  y = startLocs[currentLevel][2]
  -- reset stair position too
  stairX = stairLocs[currentLevel][1]
  stairY = stairLocs[currentLevel][2]
  -- actually move sprites for player/stairs
  playerSprite:moveTo(gridToScreenX(x), gridToScreenY(y))
  stairsSprite:moveTo(gridToScreenX(stairX), gridToScreenY(stairY))
  -- set tilemap to current level layout
  tilemap:setTiles(levels[level], tileGridWidth)
  -- finally, reset player sprite dir
  lastDir = "down"
end
-- start for level 1
setupTilesForScreen(1)

function playdate.update()
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(0, 0, 400, 240)
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
  local newX = gridToScreenX(x)
  local newY = gridToScreenY(y)
  if newX ~= playerSpriteTargetX or newY ~= playerSpriteTargetY then
    playerSpriteTargetX = newX
    playerSpriteTargetY = newY
  end
  if playerSprite.x ~= playerSpriteTargetX or playerSprite.y ~= playerSpriteTargetY then
    -- figure out amount to move
    local diffX = playerSpriteTargetX - playerSprite.x
    local diffY = playerSpriteTargetY - playerSprite.y
    local newX = playdate.math.lerp(playerSprite.x, playerSpriteTargetX, 0.2)
    local newY = playdate.math.lerp(playerSprite.y, playerSpriteTargetY, 0.2)
    if math.abs(diffX) < 0.1 then
      newX = playerSpriteTargetX
    end
    if math.abs(diffY) < 0.1 then
      newY = playerSpriteTargetY
    end
    playerSprite:moveTo(newX, newY)
  end

  if x == stairX and y == stairY then
    stairsNoise()
    -- on da stairs
    print("we on da stairs")
    currentLevel += 1
    if currentLevel > table.getsize(levels) then
      print("oof loop that shi play bo")
      currentLevel = 1
    end
    local newLevelTextImage = gfx.imageWithText(
      string.format("LEVEL: %d", currentLevel), 1000, 13
    )
    levelSpriteText:setImage(newLevelTextImage)
    setupTilesForScreen(currentLevel)
  end
end

--left button
function playdate.leftButtonDown()
  lastDir = "left"
  if canGoTo(x - 1, y) then
    x -= 1
    moveNoise()
  else
    bonkNoise()
  end
end

--right button
function playdate.rightButtonDown()
  lastDir = "right"
  if canGoTo(x + 1, y) then
    x += 1
    moveNoise()
  else
    bonkNoise()
  end
end

--down button
function playdate.downButtonDown()
  lastDir = "down"
  if canGoTo(x, y + 1) then
    y += 1
    moveNoise()
  else
    bonkNoise()
  end
end

--up button
function playdate.upButtonDown()
  lastDir = "up"
  if canGoTo(x, y - 1) then
    y -= 1
    moveNoise()
  else
    bonkNoise()
  end
end
