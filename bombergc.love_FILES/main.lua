-- Code pour le GameJam Grille
-- un simple bomberman like

io.stdout:setvbuf("no")

love.graphics.setDefaultFilter("nearest")

if arg[#arg] == "-debug" then
  require("mobdebug").start()
end

--require("heros")
--require("map")

-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
Game = {}
Game.zoom = 1
Game.screen = {}
Game.screen.width = 1024
Game.screen.height = 768
Game.volume = {}
Game.volume.current = 20
Game.volume.max = 100
Game.FPS = 0
Game.state = "intro"
Game.victory = false
math.randomseed(os.clock())


-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
function NewInput()
  local input = {}
  input.down = ""
  input.left = ""
  input.up = ""
  input.right = ""
  input.bomb = ""
  return input
end


-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
SoundsLib = {}
function LoadSounds()
  SoundsLib = {}
  SoundsLib.bomb = love.audio.newSource("sounds/bomb.wav","static")
  SoundsLib.bombset = love.audio.newSource("sounds/bombset.wav","static")
  SoundsLib.confirm = love.audio.newSource("sounds/confirm.wav","static")
  SoundsLib.died = love.audio.newSource("sounds/died.ogg","static")
  SoundsLib.goal = love.audio.newSource("sounds/goal.wav","static")
  SoundsLib.hurryup = love.audio.newSource("sounds/hurryup.wav","static")
  SoundsLib.intro = love.audio.newSource("sounds/intro.mp3","stream")
  SoundsLib.intro:setLooping(true)
  SoundsLib.itemget = love.audio.newSource("sounds/itemget.wav","static")
  SoundsLib.level1 = love.audio.newSource("sounds/level1.mp3","stream")
  SoundsLib.level1:setLooping(true)
  SoundsLib.level2 = love.audio.newSource("sounds/level2.mp3","stream")
  SoundsLib.level2:setLooping(true)
  SoundsLib.lose = love.audio.newSource("sounds/lose.mp3","static")
  SoundsLib.pause = love.audio.newSource("sounds/pause.wav","static")
  SoundsLib.reset = love.audio.newSource("sounds/reset.wav","static")
  SoundsLib.select = love.audio.newSource("sounds/select.wav","static")
  SoundsLib.timeup = love.audio.newSource("sounds/timeup.wav","static")
  SoundsLib.victory = love.audio.newSource("sounds/victory.mp3","static")
  SoundsLib.walk = love.audio.newSource("sounds/walk.wav","static")
end


-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
FontsLib = {}
function LoadFonts()
  FontsLib = {}
  FontsLib.debug = {}
  FontsLib.debug.font = love.graphics.newFont("images/bm.ttf",20)
  FontsLib.debug.color = {1, 1, 1, 1}
  FontsLib.intro = {}
  FontsLib.intro.font = love.graphics.newFont("images/bm.ttf",50)
  FontsLib.intro.color = {1, 1, 1, 1}
  FontsLib.play = {}
  FontsLib.play.font = love.graphics.newFont("images/bm.ttf",20)
  FontsLib.play.color = {1, 1, 1, 1}
  FontsLib.gameover = {}
  FontsLib.gameover.font = love.graphics.newFont("images/bm.ttf",30)
  FontsLib.gameover.color = {1, 1, 1, 1}
  FontsLib.menu = {}
  FontsLib.menu.font = love.graphics.newFont("images/blocked.ttf",50)
  FontsLib.menu.color = {1, 1, 1, 1}
end


-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
function NewPosition(pPosition)
  local position = {}
  if pPosition == nil then
    position.x = 0
    position.y = 0
  else
    position.x = pPosition.x
    position.y = pPosition.y
  end
  return position
end

function EqPosition(pPosition1, pPosition2)
  if pPosition1.x == pPosition2.x and pPosition1.y == pPosition2.y then
    return true
  end
  return false
end

SpritesLib = {}
function NewSprite(pFilename, pPosition)
  local sprite = {}
  sprite.position = NewPosition(pPosition)
  sprite.drawSprite = true
  sprite.delete = false
  sprite.image = love.graphics.newImage("images/" .. pFilename .. ".png")
  sprite.width = sprite.image:getWidth()
  sprite.height = sprite.image:getHeight()
  sprite.quad = {idle={love.graphics.newQuad(0,0,sprite.width,sprite.height,sprite.width, sprite.height)}}
  sprite.move = "idle"
  sprite.stopAnimation = false
  sprite.currAnimation = 1
  sprite.currAnimation0 = 1
  sprite.dtAnimation = 0.1
  sprite.dtAnimation0 = 0.1
  sprite.sx = 1*Game.zoom 
  sprite.sy = 1*Game.zoom 
  sprite.radian = 0
  sprite.offsetx = 0
  sprite.offsety = 0
  sprite.color = {1, 1, 1, 1}
  sprite.time = 0

  table.insert(SpritesLib, sprite)
  return sprite
end


-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
function NewGrid()
  local grid = {}
  grid.width = 15
  grid.height = 15
  grid.cells = {}
  grid.cellSize = 32*Game.zoom 
  grid.offsetx = 0
  grid.offsety = 0
  grid.NONE = 0
  grid.WALL = -1
  grid.BOMB = -2
  grid.BRICK = 3
  grid.colorBomb = {0, 0, 1, 1}
  grid.colorBrick = {0xd6/255, 0xd6/255, 0xcf/255, 1}
  grid.colorWall = {0x80/255, 0x80/255, 0x80/255, 1}
  grid.colorBg = {0x33/255, 0x77/255, 0, 1}
  grid.powerup = "none" -- "none","power","bomb"
  return grid
end
Grid = NewGrid()

function GetXYInGrid(pPosition)
  local pGrid = Grid
  local x = pPosition.x + pGrid.offsetx
  local y = pPosition.y + pGrid.offsety
  return x, y
end

function GetIJInGrid(pPosition)
  local pGrid = Grid
  local i = math.floor(pPosition.y / pGrid.cellSize) + 1 
  local j = math.floor(pPosition.x / pGrid.cellSize) + 1 
  return i, j
end

function InitGrid()
  local pGrid = Grid
  pGrid.offsetx = (Game.screen.width / 2) - ((pGrid.cellSize * pGrid.width) / 2)
  pGrid.offsety = (Game.screen.height / 2) - ((pGrid.cellSize * pGrid.height) / 2)

  pGrid.cells = {}
  for l = 1, pGrid.height do
    pGrid.cells[l ] = {}
    for c = 1, pGrid.width do
      pGrid.cells[l ][c ] = pGrid.NONE
    end
  end
  for lin = 1, pGrid.height do
    pGrid.cells[lin ][1 ] = pGrid.WALL
    pGrid.cells[lin ][pGrid.width ] = pGrid.WALL
  end
  for col = 1, pGrid.width do
    pGrid.cells[1 ][col ] = pGrid.WALL
    pGrid.cells[pGrid.height ][col ] = pGrid.WALL
  end
  for lin = 3, pGrid.height-2 do
    for col = 3, pGrid.width-2 do
      if lin % 2 ~= 0 and col % 2 ~=0 then
        pGrid.cells[lin ][col ] = pGrid.WALL
      end
    end
  end
end

function DrawGrid()
  local x = 0
  local y = 0
  local pGrid = Grid

  for lin = 1, pGrid.height do
    for col = 1, pGrid.width do
      x = (col - 1) * pGrid.cellSize + pGrid.offsetx
      y = (lin - 1) * pGrid.cellSize + pGrid.offsety

      if pGrid.cells[lin ][col ] == pGrid.WALL then
        love.graphics.setColor(pGrid.colorWall)
        love.graphics.rectangle("fill", x, y, pGrid.cellSize - 1, pGrid.cellSize - 1)
      else
        love.graphics.setColor(pGrid.colorBg)
        love.graphics.rectangle("fill", x, y, pGrid.cellSize, pGrid.cellSize)
      end
    end
  end
end



-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
BricksLib = {}
function NewBrick(line, col)
  local position = NewPosition()
  position.x = (col-1) * Grid.cellSize
  position.y = (line-1) * Grid.cellSize
  local brick = NewSprite("brick",position)
  local dim = brick.width
  brick.quad = {
    idle = {
      love.graphics.newQuad(0,0,dim,dim,brick.width, brick.height)
    },
    boom = {
      love.graphics.newQuad(0,dim*1,dim,dim,brick.width, brick.height),
      love.graphics.newQuad(0,dim*2,dim,dim,brick.width, brick.height),
      love.graphics.newQuad(0,dim*3,dim,dim,brick.width, brick.height),
      love.graphics.newQuad(0,dim*3,0,0,brick.width, brick.height)
    }
  }
  brick.height = dim
  brick.offsetx = dim
  brick.offsety = dim
  brick.sx = 1*Game.zoom 
  brick.sy = 1*Game.zoom 
  brick.dtAnimation = 0.3
  brick.dtAnimation0 = 0.3
  brick.explode = false
  brick.line = line
  brick.col = col
  brick.time = brick.dtAnimation*4
  table.insert(BricksLib,brick)
  return brick
end

-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
BombsLib = {}
function NewBomb(pPlayer)

  local i,j = GetIJInGrid(pPlayer.position)
  local positionInGrid = NewPosition()
  positionInGrid.x = (j-1)*Grid.cellSize
  positionInGrid.y = (i-1)*Grid.cellSize

  local bomb = NewSprite("bomb",positionInGrid)
  local dim = bomb.image:getHeight()
  bomb.quad = {
    idle={
      love.graphics.newQuad(dim*0,0,dim,dim,bomb.image:getWidth(), bomb.image:getHeight()),
      love.graphics.newQuad(dim*1,0,dim,dim,bomb.image:getWidth(), bomb.image:getHeight()),
      love.graphics.newQuad(dim*2,0,dim,dim,bomb.image:getWidth(), bomb.image:getHeight())
    }
  }
  bomb.offsetx = dim
  bomb.offsety = dim
  bomb.width = dim
  bomb.height = dim
  bomb.hero = pPlayer
  bomb.power = pPlayer.power
  bomb.time = 3
  bomb.sx = 2*Game.zoom 
  bomb.sy = 2*Game.zoom 
  bomb.isFree = false
  table.insert(BombsLib, bomb)
  SoundsLib.bombset:play()
  return bomb
end


-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
ExplosionsLib = {}
function NewExplosion(pBomb)
  local explosion = NewSprite("explosion", pBomb.position)
  local dim = 32
  local w = explosion.width
  local h = explosion.height
  explosion.drawSprite = false
  explosion.quad = {
    start = {
      love.graphics.newQuad(dim*0,0,dim,dim,w, h),
      love.graphics.newQuad(dim*1,0,dim,dim,w, h),
      love.graphics.newQuad(dim*2,0,dim,dim,w, h),
      love.graphics.newQuad(dim*3,0,dim,dim,w, h),
      love.graphics.newQuad(dim*4,0,dim,dim,w, h),
      love.graphics.newQuad(dim*5,0,dim,dim,w, h),
      love.graphics.newQuad(dim*6,0,dim,dim,w, h),
      love.graphics.newQuad(dim*6,0,0,dim,w, h),
    },
    middle = {
      love.graphics.newQuad(dim*0,dim,dim,dim,w, h),
      love.graphics.newQuad(dim*1,dim,dim,dim,w, h),
      love.graphics.newQuad(dim*2,dim,dim,dim,w, h),
      love.graphics.newQuad(dim*3,dim,dim,dim,w, h),
      love.graphics.newQuad(dim*4,dim,dim,dim,w, h),
      love.graphics.newQuad(dim*5,dim,dim,dim,w, h),
      love.graphics.newQuad(dim*6,dim,dim,dim,w, h),
      love.graphics.newQuad(dim*6,dim,0,dim,w, h),
    },
    ending = {
      love.graphics.newQuad(dim*0,dim*2,dim,dim,w, h),
      love.graphics.newQuad(dim*1,dim*2,dim,dim,w, h),
      love.graphics.newQuad(dim*2,dim*2,dim,dim,w, h),
      love.graphics.newQuad(dim*3,dim*2,dim,dim,w, h),
      love.graphics.newQuad(dim*4,dim*2,dim,dim,w, h),
      love.graphics.newQuad(dim*5,dim*2,dim,dim,w, h),
      love.graphics.newQuad(dim*6,dim*2,dim,dim,w, h),
      love.graphics.newQuad(dim*6,dim*2,0,dim,w, h),
    }
  }
  explosion.stopAnimation = true
  explosion.move = "start"
  explosion.boom = { NewPosition(explosion.position) }
  explosion.power = pBomb.power
  explosion.width = 32
  explosion.height = 32
  explosion.dtAnimation = 0.15
  explosion.dtAnimation0 = 0.15
  explosion.speed = 0.05
  explosion.speed0 = 0.05
  explosion.time = 1
  explosion.goLeft = true
  explosion.goRight = true
  explosion.goUp = true
  explosion.goDown = true
  explosion.foyer = true
  explosion.radian = 0
  explosion.sx = 1 * Game.zoom
  explosion.sy = 1 * Game.zoom
  table.insert(ExplosionsLib, explosion)
  return explosion
end

function NewExplosionFragment( pExplosion, pPosition, direction )
  local explosion = NewExplosion( pExplosion )
  explosion.foyer = false
  explosion.move = "ending"
  explosion.currAnimation = pExplosion.currAnimation
  explosion.dtAnimation = pExplosion.dtAnimation
  explosion.position = NewPosition(pPosition)
  explosion.power = pExplosion.power - 1
  explosion.time = pExplosion.time
  explosion.goLeft = false
  explosion.goRight = false
  explosion.goUp = false
  explosion.goDown = false
  explosion[direction] = true
  if explosion.goLeft then
    explosion.radian = math.pi
  elseif explosion.goUp then
    explosion.radian = -math.pi/2
  elseif explosion.goDown then
    explosion.radian = math.pi/2
  else
    explosion.radian = 0
  end
  return explosion
end


-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
ActorsLib = {}
function NewHero(pHeroName, pSpritesetName)
  local hero = NewSprite(pSpritesetName)
  local dim = hero.image:getWidth()
  hero.quad = {}
  hero.quad.down = { 
    love.graphics.newQuad(0,dim*0,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*1,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*2,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
  }
  hero.quad.right = {
    love.graphics.newQuad(0,dim*3,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*4,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*5,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
  }
  hero.quad.left = {
    love.graphics.newQuad(0,dim*6,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*7,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*8,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
  }
  hero.quad.up = {
    love.graphics.newQuad(0,dim*9,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*10,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*11,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
  }
  hero.quad.died = {
    love.graphics.newQuad(0,dim*12,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*13,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*14,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*15,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*16,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*17,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*18,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*19,dim,dim,hero.image:getWidth(), hero.image:getHeight()),
    love.graphics.newQuad(0,dim*19,0,dim,hero.image:getWidth(), hero.image:getHeight()),
  }
  hero.move = "down"
  hero.currAnimation = 1
  hero.oldPosition = NewPosition(hero.position)
  hero.speed = 5*Game.zoom
  hero.power = 1
  hero.bombs = 1
  hero.name = tostring(pHeroName)
  hero.sx = 2*Game.zoom 
  hero.sy = 2*Game.zoom 
--  hero.offsetx = -6*Game.zoom 
  hero.offsety = -12*Game.zoom 
  hero.width = 24*Game.zoom 
  hero.height = 24*Game.zoom 
  hero.drawSprite = false
  hero.input = NewInput()
  hero.dead = false
  hero.time = 2

  table.insert(ActorsLib,hero)

  return hero
end


-----------------------------------------------------------------
-----------------------------------------------------------------
--
--INTRO
Intro = {}
Intro.image = love.graphics.newImage("images/actor0.png")
Intro.quad = love.graphics.newQuad(0, 0, 24, 24, Intro.image:getWidth(), Intro.image:getHeight())
Intro.state = "intro"
Intro.nextState =""
Intro.stateTime = 4
Intro.stateTime0 = 4
function _StopAllSound()
  for k, v in pairs(SoundsLib) do
    SoundsLib[k]:stop()
  end
end

function StartIntro()
  Game.state = "intro"
  Intro.state = "intro"
  Intro.nextState = "intro"
  love.graphics.setFont(FontsLib.intro.font)
  _StopAllSound()
  SoundsLib.intro:play()
end

function UpdateIntro(dt)
  Intro.stateTime = Intro.stateTime - dt
  if Intro.stateTime <= 0 then
    if Intro.state=="intro" then
      Intro.stateTime = Intro.stateTime0
      Intro.state = "title"
    elseif Intro.state=="title" then
      Intro.stateTime = Intro.stateTime0
      StartMenu(false)
    end
  end
--  end
end

function DrawIntro()
  local x = Game.screen.width /2
  local y = Game.screen.height /2
  local msg = ""
  if Intro.state == "intro" then
    love.graphics.setColor(FontsLib.intro.color)
    msg = "GameCodeur - GameJam"
    x = x - FontsLib.intro.font:getWidth(msg)/2
    love.graphics.print(msg, x, y)
  elseif Intro.state == "title" then
    love.graphics.setColor(FontsLib.intro.color)
    msg = "BomberMan like"
    x = x - FontsLib.intro.font:getWidth(msg)/2
    love.graphics.print(msg,x,y)
  end
end

function InputIntro(key)
  if key=="escape" or key == "return" then
    Intro.stateTime = 0
  end
end

-- MENU
function StartMenu(stopSound)
  Game.state = "menu"
  love.graphics.setFont(FontsLib.menu.font)
  if stopSound == false then
  else
    _StopAllSound()
  end
  SoundsLib.intro:play()
end

function UpdateMenu(dt)
end

function DrawMenu()
  local x = Game.screen.width /2
  local y = Game.screen.height /2
  local msg = "PRESS ENTER TO PLAY"
  love.graphics.setColor(FontsLib.menu.color)
  x = x - FontsLib.menu.font:getWidth(msg)/2
  love.graphics.print(msg,x,y)
  love.graphics.setColor({1,1,1,1})    
  love.graphics.draw(Intro.image,Intro.quad,x+Intro.image:getWidth()*10/2,y-300,0,10,10)
end

function InputMenu(key)
  if key=="return" then
    SoundsLib.confirm:play()
    StartGame()
  end
end

-- GAME
function HasVictory()
  if #ActorsLib <= 1 then
    return true
  end
  return false
end

function StartGame()
  love.graphics.setFont(FontsLib["debug"].font)
  InitGrid()
  _StopAllSound()
  SoundsLib.level1:play()
  Game.state = "game"

  SpritesLib = {}
  BricksLib = {}
  BombsLib = {}
  ExplosionsLib = {}
  ActorsLib = {}

  Player1 = NewHero("Dynablaster", "actor0")
  Player1.input = {up="up",down="down",left="left",right="right",bomb="return"}
  Player2 = NewHero("Enemy", "actor1")
  Player2.input = {up="kp5",down="kp2",left="kp1",right="kp3",bomb="kp0"}
  MakeGridLevel1()
end

function UpdateGame(dt)
  InputActor()
  UpdateBombs(dt)
  UpdateExplosion(dt)
  UpdateActors(dt)
  UpdateBricks(dt)
  UpdateSprite(dt)
  Game.FPS = 1/dt
  if HasVictory() then
    StartEndGame()
  end
end


function DrawActorInfos(pPlayer,xs,ys,dy)
  local rc = _GetSpriteRect( pPlayer )
  love.graphics.setColor(FontsLib.debug.color)
  love.graphics.print(pPlayer.name,xs, ys)
  love.graphics.print('rx, ry:\n'..tostring(rc.x)..","..tostring(rc.y),xs, ys+dy*1)
  love.graphics.print('x, y:\n'..tostring(pPlayer.position.x)..","..tostring(pPlayer.position.y),xs, ys+dy*2)
  local i,j = GetIJInGrid(pPlayer.position)
  love.graphics.print('i, j:\n'..i..","..j,xs, ys+dy*3)
  love.graphics.print('Power:\n'..tostring(pPlayer.power),xs, ys+dy*4)
  love.graphics.print('Bomb:\n'..tostring(pPlayer.bombs),xs, ys+dy*5)
  for n=1, #BombsLib do
    local bomb = BombsLib[n]
    if bomb.hero == pPlayer then 
      i,j = GetIJInGrid(bomb.position)
      love.graphics.print('i, j:\n'..i..","..j,xs, ys+dy*(5+n))
    end
  end
end

function DrawGame()

  DrawGrid()
  DrawSpites()
  DrawEplosion()
  DrawActor()

  local xs = 10
  local ys = 100
  local dy = 40
  DrawActorInfos(Player1,xs,ys,dy)
  DrawActorInfos(Player2,800,ys,dy)

  local sFPS = string.format("FPS : %.2f",Game.FPS)
  love.graphics.print(sFPS,0,0)
end

function InputGame(key)
  for na = 1, #ActorsLib do
    local pPlayer = ActorsLib[ na]

    if key == pPlayer.input.bomb then
      if pPlayer.bombs>0 then
        pPlayer.bombs =  pPlayer.bombs - 1
        NewBomb( pPlayer )
      end
    end
    if key == "kp*" then
      pPlayer.power = pPlayer.power + 1
    end
    if key == "kp+" then
      pPlayer.bombs = pPlayer.bombs + 1
    end
  end

  if key == "r" then
    Player1.radian = Player1.radian + math.pi/2
  end
  if key == "escape" then
    SoundsLib.pause:play()
    StartPause()
  end
end


-- PAUSE
function StartPause()
  Game.state = "pause"
end

function UpdatePause(dt)
end

function DrawPause()
  DrawGame()
  local w = Game.screen.width
  local h = Game.screen.height
  love.graphics.setColor(0,0,0,0.3)
  love.graphics.rectangle("fill",0,0,w,h)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print("PAUSE",w/2,h/2)
end

function InputPause(key)
  if key == "escape" then
    Game.state = "game"
    SoundsLib.pause:play()
  end
end

-- ENDGAME
function StartEndGame()
  Game.state = "endgame"
  Game.victory = true
  _StopAllSound()
  love.graphics.setFont(FontsLib.gameover.font)
  if #ActorsLib == 1 and ActorsLib[1].dead == false then
    Game.victory = true
    SoundsLib.victory:play()
  else 
    Game.victory = false
    SoundsLib.lose:play()
  end
end

function UpdateEndGame(dt)
end

function DrawEndGame()
  local msg = ""
  local w = Game.screen.width
  local h = Game.screen.height

  love.graphics.setColor({0,0.5,0.5,1})
  love.graphics.rectangle("fill",0,0,w,h)
  love.graphics.setColor(FontsLib.gameover.color)
  if #ActorsLib == 1 and ActorsLib[1].dead == false then
    msg = "Winner is ".. ActorsLib[#ActorsLib].name
    local x = (w - FontsLib.gameover.font:getWidth(msg))/2
    local y = (h - FontsLib.gameover.font:getHeight(msg))/2
    love.graphics.print(msg,x,y)
    local act = ActorsLib[#ActorsLib]
    love.graphics.draw(act.image, act.quad.down[1],(w - act.width)/2, (h - act.height)/2+50, 0,10,10)
  else
    msg ="Draw game"
    local x = (w - FontsLib.gameover.font:getWidth(msg))/2
    local y = (h - FontsLib.gameover.font:getHeight(msg))/2
    love.graphics.print(msg,x,y)
  end
end

function InputEndGame(key)
  if key == "return" then
    SoundsLib.confirm:play()
    StartMenu()
  end
end

--
function _BottomRight(i,j)
  local pGrid = Grid
  if (j~=pGrid.height-1 or i~=pGrid.width-1) and (j~=pGrid.height-2 or i~=pGrid.width-1) and (j~=pGrid.height-1 or i~=pGrid.width-2) then
    return true
  end
  return false
end
function _TopLeft(i,j)
  if (j~=2 or i~=2) and (j~=3 or i~=2) and (j~=2 or i~=3) then
    return true
  end
  return false
end
function MakeGridLevel1()
  local pGrid = Grid
  local c, i, j = 0,0,0
  local nwall = (Grid.width-2)/2*(Grid.height-2)/2
  local ct = ( Grid.width*pGrid.height - nwall )/2
  while c<ct do   
    j = math.random(2,pGrid.width-1)
    i = math.random(2,pGrid.height-1)
    if _BottomRight(i,j) and _TopLeft(i,j) then
      if pGrid.cells[i][j] == pGrid.NONE then
        pGrid.cells[i][j] = NewBrick(i,j)
        c = c +1
      end
    end
  end

  Player1.position.x = (2-1)*Grid.cellSize + Grid.cellSize/2
  Player1.position.y = (2-1)*Grid.cellSize + Grid.cellSize/2

  Player2.position.x = (pGrid.width-2)*Grid.cellSize + Grid.cellSize/2
  Player2.position.y = (pGrid.height-2)*Grid.cellSize + Grid.cellSize/2
end

--
function love.load()
  love.window.setMode(Game.screen.width, Game.screen.height)
  love.window.setTitle("GameJam - grille")

  LoadSounds()
  LoadFonts()

  StartIntro()
end

-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
function DrawActor()
  for np = 1, #ActorsLib do
    local actor = ActorsLib[np]
    local x, y = GetXYInGrid(actor.position)
    local offx, offy = (actor.width-actor.offsetx)/2/Game.zoom, (actor.height-actor.offsety)/2/Game.zoom
    local quad = actor.quad[actor.move][actor.currAnimation]
    love.graphics.setColor(actor.color)
--     local rc = _GetSpriteRect( actor )
--    love.graphics.rectangle("fill",rc.x+Grid.offsetx,rc.y+Grid.offsety,rc.w,rc.h)
    love.graphics.draw(actor.image, quad, x, y, actor.radian,
      actor.sx, actor.sy, offx, offy)
  end
end

function DrawSpites()
  for np = 1, #SpritesLib do
    local sprite = SpritesLib[np]
    if sprite.drawSprite == true then
      local x, y = GetXYInGrid(sprite.position)
      local offx, offy = (sprite.width-sprite.offsetx)/2, (sprite.height-sprite.offsety)/2
      local quad = sprite.quad[sprite.move][sprite.currAnimation]
      love.graphics.setColor(sprite.color)
      love.graphics.draw(sprite.image, quad, x, y, sprite.radian,
        sprite.sx, sprite.sy, offx, offy)
    end
  end
end

function DrawEplosion()
  for np = 1, #ExplosionsLib do
    local explosion = ExplosionsLib[np]
    local position = explosion.position
    local d = explosion.width
--    local offx, offy = (d-explosion.offsetx)/2, (d-explosion.offsety)/2
    local quad = explosion.quad[explosion.move][explosion.currAnimation]
    local x, y = GetXYInGrid( position )
    love.graphics.setColor(explosion.color)
    love.graphics.draw(explosion.image, quad, x+d/2, y+d/2, explosion.radian,
      explosion.sx, explosion.sy, d/2, d/2)
  end
end

function love.draw()
  if Game.state == "intro" then
    DrawIntro()
  elseif Game.state == "menu" then
    DrawMenu()
  elseif Game.state == "game" then
    DrawGame()
  elseif Game.state == "endgame" then
    DrawEndGame()
  elseif Game.state =="pause" then
    DrawPause()
  end
end

-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
function love.keypressed(key)

  if Game.state == "intro" then
    InputIntro(key)
  elseif Game.state == "menu" then
    InputMenu(key)
  elseif Game.state == "game" then
    InputGame(key)
  elseif Game.state == "endgame" then
    InputEndGame(key)
  elseif Game.state =="pause" then
    InputPause(key)
  end
end

-----------------------------------------------------------------
-----------------------------------------------------------------
--
--
function RectangleCollide(rect1, rect2)
  if rect1.x < rect2.x + rect2.w and rect1.x + rect1.w > rect2.x and rect1.y < rect2.y + rect2.h and rect1.h + rect1.y > rect2.y then
    return true
  end
  return false
end

function _CheckCollideGrid( line, col, rectPlayer)
  local pGrid = Grid
  if line<=pGrid.height and col<=pGrid.width and pGrid.cells[line][col] ~= pGrid.NONE then
    local rc = {x=(col-1)*pGrid.cellSize, y=(line-1)*pGrid.cellSize,
      w=pGrid.cellSize, h=pGrid.cellSize}
    if RectangleCollide(rc, rectPlayer) == true then
      return true
    end
  end
  return false
end

function _GetSpriteRect(pPlayer)
  local rc = {
    x=pPlayer.position.x - pPlayer.width/2,
    y=pPlayer.position.y - pPlayer.height/2,
    w=pPlayer.width, 
    h=pPlayer.height
  }
  return rc
end


function Collide( pPlayer )
  local pGrid = Grid
  local line, col = GetIJInGrid( pPlayer.position )
  local rectPlayer = _GetSpriteRect(pPlayer)

  if pPlayer.position.x + pPlayer.width/2 >= (pGrid.width) * pGrid.cellSize - 1 then return true end
  if pPlayer.position.y + pPlayer.height >= (pGrid.height)*pGrid.cellSize - 1 then return true end
  if pPlayer.position.x - pPlayer.width/2 <0 then return true end
  if pPlayer.position.y - pPlayer.height/2 <0 then return true end

  if _CheckCollideGrid(line,col,rectPlayer) then return true end
  if _CheckCollideGrid(line+1,col,rectPlayer) then return true end
  if _CheckCollideGrid(line,col+1,rectPlayer) then return true end
  if _CheckCollideGrid(line+1,col+1,rectPlayer) then return true end
  return false
end

function BombCollide( bomb, pPlayer )
  local rcS = {x=bomb.position.x, y=bomb.position.y, w=bomb.width, h=bomb.height}
  local rc = _GetSpriteRect(pPlayer)
  if RectangleCollide(rcS,rc) then
    return true
  end
  return false
end

function BombsCollide( pPlayer )
  for nb=1, #BombsLib do
    local bomb = BombsLib[nb]
    if bomb.isFree == false and bomb.hero == pPlayer then
      return false
    end
    if BombCollide(bomb, pPlayer) == true then
      return true
    end
  end
  return false
end

function _ActorKeyDown( pPlayer )

  local playSound =false
  if love.keyboard.isDown(pPlayer.input.right)  then
    pPlayer.position.x = pPlayer.position.x + pPlayer.speed
    pPlayer.move = "right"
    pPlayer.currAnimation = 1
    playSound = true
  end

  if love.keyboard.isDown(pPlayer.input.left) and pPlayer.position.x > 0 then
    pPlayer.position.x = pPlayer.position.x - pPlayer.speed
    pPlayer.move = "left"
    pPlayer.currAnimation = 1
    playSound = true
  end

  if love.keyboard.isDown(pPlayer.input.up) and pPlayer.position.y > 0 then
    pPlayer.position.y = pPlayer.position.y - pPlayer.speed
    pPlayer.move = "up"
    pPlayer.currAnimation = 1
    playSound = true
  end

  if love.keyboard.isDown(pPlayer.input.down) then
    pPlayer.position.y = pPlayer.position.y + pPlayer.speed
    pPlayer.move = "down"
    pPlayer.currAnimation = 1
    playSound = true
  end
  return playSound
end

function InputActor()

  for na = 1, #ActorsLib do
    local pPlayer = ActorsLib[na]
    if pPlayer.dead == false then

      pPlayer.oldPosition = NewPosition(pPlayer.position)

      local playSound = _ActorKeyDown(pPlayer)

      if Collide( pPlayer ) or BombsCollide( pPlayer ) then
        pPlayer.position = NewPosition(pPlayer.oldPosition)
        playSound = false
      end

      if playSound == true then SoundsLib.walk:play() end
    end
  end
end

function UpdateAnimation(anim, dt)
  anim.dtAnimation = anim.dtAnimation - dt
  if anim.dtAnimation <= 0 then
    anim.dtAnimation = anim.dtAnimation0
    anim.currAnimation = anim.currAnimation + 1
    if anim.currAnimation > #anim.quad[anim.move] then
      if anim.stopAnimation == true then
        anim.currAnimation = #anim.quad[anim.move]
      else
        anim.currAnimation = anim.currAnimation0
      end
    end
  end
end


function DoExplosion( pBomb )
  NewExplosion(pBomb)
  SoundsLib.bomb:stop()
  SoundsLib.bomb:play()
end

function ExplosionCollide(sprite)
  for nexp = 1, #ExplosionsLib do
    local exp = ExplosionsLib[nexp]
    local rcE = {x=exp.position.x, y=exp.position.y, w=Grid.cellSize, h=Grid.cellSize}
    local rcS = {x=sprite.position.x, y=sprite.position.y, w=sprite.width, h=sprite.height}
    if RectangleCollide(rcS, rcE) then
      return true
    end
  end
  return false
end

function UpdateBombs(dt)
  for nbomb = #BombsLib, 1, -1  do
    local bomb = BombsLib[nbomb]
    UpdateAnimation(bomb, dt)
    if BombCollide(bomb, bomb.hero) == false then
      bomb.isFree = true
    end
    local collideExplosion = ExplosionCollide(bomb)
    bomb.time = bomb.time - dt
    if bomb.time <= 0 or collideExplosion==true then
      bomb.delete = true
      bomb.hero.bombs = bomb.hero.bombs +1
      DoExplosion( bomb )
      table.remove(BombsLib, nbomb)
    end
  end
end

function _ExplosionFragment(explosion, line, col, direction)
  local pGrid = Grid

  if line<=0 or col<=0 or line>pGrid.height or col>pGrid.width then
    return false
  end

  if pGrid.cells[line][col] == pGrid.NONE then
    local pos = NewPosition()
    pos.x = (col-1) * pGrid.cellSize
    pos.y = (line-1) * pGrid.cellSize
    if explosion.foyer == false then
      explosion.move = "middle"
    end
    NewExplosionFragment(explosion, pos, direction)
  elseif pGrid.cells[line][col] == pGrid.WALL then
    return false
  else
    local brick = pGrid.cells[line][col]
    brick.explode = true
    if explosion.foyer == false then
      explosion.move = "middle"
    end
    return false
  end

  return true
end
function ExtendExplosionFragment( explosion )
  local i,j = GetIJInGrid(explosion.position)

  if explosion.power> 0 then
    if explosion.goRight then 
      _ExplosionFragment(explosion, i, j+1, "goRight")
    end
    if explosion.goLeft then 
      _ExplosionFragment(explosion, i, j-1, "goLeft")
    end
    if explosion.goUp then 
      _ExplosionFragment(explosion, i-1, j, "goUp")
    end
    if explosion.goDown then 
      _ExplosionFragment(explosion, i+1, j, "goDown")
    end
    explosion.power = 0
  end

end


function UpdateExplosion(dt)
  for nex = #ExplosionsLib, 1, -1  do
    local explosion = ExplosionsLib[nex]
    UpdateAnimation(explosion, dt)
    explosion.speed = explosion.speed - dt
    if explosion.speed <= 0 then
      explosion.speed = explosion.speed0
      ExtendExplosionFragment(explosion)
    end
    explosion.time = explosion.time - dt
    if explosion.time <= 0 then
      explosion.delete = true
      table.remove(ExplosionsLib, nex)
    end
  end
end


function UpdateSprite(dt)
  for nsprite = #SpritesLib, 1, -1 do
    local sprite = SpritesLib[nsprite]
    if sprite.delete == true then
      table.remove(SpritesLib, nsprite)
    end
  end
end

function UpdateBricks(dt)
  for nbrick = #BricksLib, 1, -1 do

    local brick = BricksLib[nbrick]
    if brick.explode == true then
      brick.move = "boom"
      UpdateAnimation(brick,dt)
      brick.time = brick.time - dt

      if brick.time <= 0 then
        Grid.cells[brick.line][brick.col] = Grid.NONE
        brick.delete = true
        table.remove(BricksLib, nbrick)
      end
    end

  end
end

function DoActorDead(act)
  act.move = "died"
  act.dead = true
  act.stopAnimation = true
  SoundsLib.died:play()
end


function UpdateActors(dt)
  for nact = #ActorsLib, 1, -1 do
    local act = ActorsLib[nact]
    if ExplosionCollide(act) then
      DoActorDead(act)
    end
    UpdateAnimation(act,dt)
    if act.dead == true then
      act.time = act.time - dt
      if act.time <= 0 then
        table.remove(ActorsLib, nact)
      end
    end

  end
end


function love.update(dt)
  if Game.state == "intro" then
    UpdateIntro(dt)
  elseif Game.state == "menu" then
    UpdateMenu(dt)
  elseif Game.state == "game" then
    UpdateGame(dt)
  elseif Game.state == "endgame" then
    UpdateEndGame(dt)
  elseif Game.state =="pause" then
    UpdatePause(dt)
  end
end
