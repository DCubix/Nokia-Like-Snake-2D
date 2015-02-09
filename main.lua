require "keycodes"
screen ( 512, 412, 32, "Snake" )
setframetimer(30)
--backcolor(185, 220, 200)
backcolor(175, 190, 155)

scene = createimage(128, 103)
colorkey(255, 0, 255)
bg = loadimage("data/bg.bmp")
numf = loadbmpfont("data/num.bmp", 1, 38, "0123456789:ABCDEFGHIJKLMNOPQRSTUVWXYZ+")
nocolorkey()

fruit = {
	X = 0,
	Y = 0
}

snake = {}
local score = 0
local lives = 3
local length = 8
local speed = 0.4
local utime = 4
local gameover = false

function randomFruit()
	fruit.X = math.random(6, 121)
	fruit.Y = math.random(15, 92)
	for i, v in ipairs(snake) do
		while circlecoll (fruit.X,fruit.Y,1,v.X,v.Y,1,0) do
			fruit.X = math.random(0, 127)
			fruit.Y = math.random(0, 127)
		end
	end
end

function restart()
	lives = 3
	gameover = false
	initSnake()
	randomFruit()
end

function initSnake()
	lenght = 8
	speed = 0.1
	score = 0
	snake = {}
	for i = 1, length do
		snake[i] = {X = 40, Y = 40 - 0.2 * i, F = 3}
	end
end

local t = 0
local key = 0
local ex, ey = 0

restart()

while key ~= 27 do
	cls()
	key = getkey()

	t = t + 30

	if not gameover then
		if keystate(Keys.Left) then
			if snake[1].F ~= 2 then
				snake[1].F = 0
			end
		elseif keystate(Keys.Right) then
			if snake[1].F ~= 0 then
				snake[1].F = 2
			end
		elseif keystate(Keys.Up) then
			if snake[1].F ~= 3 then
				snake[1].F = 1
			end
		elseif keystate(Keys.Down) then
			if snake[1].F ~= 1 then
				snake[1].F = 3
			end
		end
	else
		if keystate(Keys.Enter) then
			restart()
		end
	end

	if circlecoll (snake[1].X,snake[1].Y,2,fruit.X+1,fruit.Y+1,1,0) then
		randomFruit()
		length = length + 1
		score = score + 10
		speed = speed + 0.01
		
		if speed >= 2.0 then
			speed = 2.0
		end
		snake[length] = {X = snake[length-1].X, Y = snake[length-1].Y, F = 0}
	end

	if t >= utime then
		if not gameover then
			if snake[1].F == 0 then
				snake[1].X = snake[1].X - speed
				ex = 2
				ey = 0
			elseif snake[1].F == 1 then
				snake[1].Y = snake[1].Y - speed
				ex = 0
				ey = 2
			elseif snake[1].F == 2 then
				snake[1].X = snake[1].X + speed
				ex = -2
				ey = 0
			elseif snake[1].F == 3 then
				snake[1].Y = snake[1].Y + speed
				ex = 0
				ey = -2
			end
			-- Check wall col
			if not boxcoll (snake[1].X-1, snake[1].Y-1, snake[1].X+1, snake[1].Y+1, 8, 21, 113, 71) then
				lives = lives - 1
				initSnake()
				if lives <= 0 then
					gameover = true
				end
			end
			
			-- Update snake
			for i = #snake, 2, -1 do
				snake[i].X = snake[i].X + ((snake[i - 1].X - snake[i].X) / 2)
				snake[i].Y = snake[i].Y + ((snake[i - 1].Y - snake[i].Y) / 2)
				snake[i].F = snake[i - 1].F
			end
		end
		t = 0
	end

	startimagedraw(scene)
	cls()
	color(0, 0, 0)

	if not gameover then
		alphachannel(80)
		fillcircle(fruit.X+1, fruit.Y+2, 1)
		alphachannel(255)
		fillcircle(fruit.X+1, fruit.Y+1, 1)
		
		-- Draw Everything
		for i = 1, #snake do
			local v = snake[i]
			alphachannel(80)
			fillcircle (v.X, v.Y+1, 1)
			alphachannel(255)
			fillcircle (v.X, v.Y, 1)
		end
	end
		
	for i = #snake, 2, -1 do
		local s = snake[i]
		local sx = s.X+ex
		local sy = s.Y+ey
		if circlecoll (snake[1].X-ex,snake[1].Y-ey,1,sx,sy,1,0) then
			lives = lives - 1
			initSnake()
			if lives <= 0 then
				gameover = true
			end
			break
		end
		--color(255, 0, 0)
		--circle (s.X+ex, s.Y+ey, 1)
	end
	--color(255, 0, 0)
	--circle(fruit.X+1, fruit.Y+1, 1)
	
	alphachannel(80)
	putimage(0, 1, bg)
	alphachannel(255)
	putimage(0, 0, bg)

	--color(0, 255, 0)
	--box (6, 14, 121, 93)

	alphachannel(80)
	bmptext(4, 4, string.format("%08d", score), numf)
	alphachannel(255)
	bmptext(4, 3, string.format("%08d", score), numf)

	for i = 1, 3 do
		alphachannel(60)
		bmptext(100 + (6*i), 3, "+", numf)
	end

	for i = 1, lives do
		alphachannel(80)
		bmptext(100 + (6*i), 4, "+", numf)
		alphachannel(255)
		bmptext(100 + (6*i), 3, "+", numf)
	end
	
	if gameover then
		local w = imagewidth(scene)/2 - ((fontwidth(numf)*9)/2)
		local h = imageheight(scene)/2 - fontheight(numf)/2
		alphachannel(80)
		bmptext(w, h+1, "GAME OVER", numf)
		alphachannel(255)
		bmptext(w, h, "GAME OVER", numf)
	end
	
	stopimagedraw()

	buffer = zoomimage(scene, 4.0, 4.0)
	putimage(0, 0, buffer)
	freeimage(buffer)
	--drawtext(0, 0, speed)
	sync()
end
closewindow()
