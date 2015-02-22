--Snake
--field size: 31x21 | 10x10 pixel tiles
screen = platform.window
scrWidth = screen:width()
scrHeight = screen:height()

--game data
gameover = false
snakeLength = 4 -- actual length = snakeLength-1
direction = 1 -- 0 = up, 1 = right, 2 = down, 3 = left
newdir = direction
plrx = 15
plry = 10
score = 0
foodx = 0
foody = 0

--temporary:

--constants
initial = true
GOStr = "Game Over!"
gow = 0
goh = 0
tileSize = 10
fieldW = 31
fieldH = 21
field = {}

function on.construction()
--	print("scr-width: " .. scrWidth .. ", scr-height: " .. scrHeight)
	--"load" initial game state:
	resetGame()
	runFieldUpdate()
	timer.start(0.25)
end

function resetGame()
	--reset variables
	gameover = false
	direction = 1
	snakeLength = 4
	plrx = 15
	plry = 10
	score = 0
	spawnFood()
	
	--initialization
	initField(fieldW, fieldH)
	
	--spawn player
	field[plry * fieldW + plrx] = snakeLength
end

function on.paint(gc)
	if initial == true then
		gow = gc:getStringWidth(GOStr)
		goh = gc:getStringHeight(GOStr)
		initial = false
	end
	if gameover == true then
		gc:setColorRGB(180, 180, 180)
		gc:fillRect(0, 0, scrWidth, scrHeight)
		displayGameover(gc)
	else
		gc:setColorRGB(180, 180, 180)
		gc:fillRect(0, 0, scrWidth, scrHeight)
		gc:setColorRGB(130, 130, 130)
		gc:fillRect(fieldW * tileSize, 0, scrWidth - fieldW * tileSize, scrHeight)
		drawField(gc)
		drawFood(gc)
		--gc:setColorRGB(255, 0, 255)
		--gc:drawString(keyname, scrWidth-gc:getStringWidth(keyname), scrHeight-gc:getStringHeight(keyname), "top")
	end
end

function initField(width, height)
	for i=0, width * height - 1 do
		field[i] = 0
	end
end

function displayGameover(gc)
	-- "GO-window"
	gc:setColorRGB(130, 130, 130)
	gc:fillRect(scrWidth/4, scrHeight/4, scrWidth/2, scrHeight/2)
	
	-- "Game Over"
	gc:setColorRGB(255, 0, 0)
	gc:drawString(GOStr, scrWidth/2 - gow/2, scrHeight/2 - goh, "top")
	
	-- Score
	local scostr = "Score: " .. score
	local scostrw = gc:getStringWidth(scostr)
	local scostrh = gc:getStringHeight(scostr)
	gc:setColorRGB(0, 0, 255)
	gc:drawString(scostr, scrWidth/2 - scostrw/2, scrHeight/2 + scostrh/2, "top")
end

function spawnFood()
	-- I know there is a bug where the food spawns on top of the player, it's intentionally left unfixed. I don't want to deal with infinite looping freezing the calculator
	foodx = math.random(fieldW)-1
	foody = math.random(fieldH)-1
end

function runFieldUpdate()
	for i=0, fieldW * fieldH - 1 do
		if field[i] > 0 then
			field[i] = field[i] - 1
		end
	end
end

function on.timer()
	if gameover == false then
		direction = newdir
		playerMove()
		runFieldUpdate()
	else
		timer.stop()
	end
	
	screen:invalidate()
end

function playerMove()
	local nx = plrx
	local ny = plry
	
	if direction == 0 then
		ny = plry - 1
	end
	if direction == 1 then
		nx = plrx + 1
	end
	if direction == 2 then
		ny = plry + 1
	end
	if direction == 3 then
		nx = plrx - 1
	end
	
	--switch side by going into the wall:
	if nx >= fieldW then
		nx = 0
	end
	if ny >= fieldH then
		ny = 0
	end
	if nx < 0 then
		nx = fieldW-1
	end
	if ny < 0 then
		ny = fieldH-1
	end
	
	if field[ny * fieldW + nx] <= 1 then
		field[ny * fieldW + nx] = snakeLength
		plrx = nx
		plry = ny
		
		if plrx == foodx and plry == foody then
			score = score + 1
			spawnFood()
			snakeLength = snakeLength + 1
		end
	else
		gameover = true
	end
end

function drawField(gc)
	gc:setColorRGB(0, 0, 0)
	for x=0, fieldW-1 do
		for y=0, fieldH-1 do
			if field[y * fieldW + x] > 0 then
				drawTile(gc, x, y)
			end
		end
	end
end

function drawFood(gc)
	gc:setColorRGB(255,255,255)
	drawTile(gc, foodx, foody)
end

function drawTile(gc, x, y)
	gc:fillRect(x * tileSize, y * tileSize, tileSize, tileSize)
end

function on.arrowKey(key)
	if key == "up" and direction ~= 2 then
		newdir = 0
	end
	if key == "right" and direction ~= 3 then
		newdir = 1
	end
	if key == "down" and direction ~= 0 then
		newdir = 2
	end
	if key == "left" and direction ~= 1 then
		newdir = 3
	end
end

function on.enterKey()
	resetGame()
	runFieldUpdate()
	timer.start(0.25)
end
