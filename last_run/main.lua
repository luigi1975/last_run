--codice di Marco Bruti tratto dal libro "I Love Lua"
--modificato da Luigi Fontana / PiadaMakkine

local runnerImg, speedbarImg
local canvasImg
local elapsed, frameElapsed, pressTime, speedStepTime
local runnerSheet = {}
local currentFrame
local myCanvas
local gameStages = {["START"] = "1", ["RUN"] = "2", ["STOP"] = "3"}
local gameStage
local counter, speed, runnerX, runnerY, distance
local screenX, screenY = 800, 480
local record = 1000

function initGame()
	elapsed = 0
	speed = 0
	counter = 5
	currentFrame = 1
	runnerY = 176
	runnerX = 0
	distance = 100
	gameStage = gameStages["START"]
end

function love.keypressed(key, scancode, isrepeat)
	if(gameStage == gameStages["RUN"]) then
		if(key == "space") then
			local diff = math.abs(love.timer.getTime() - speedStepTime)
			if(diff > 0.20) and (diff < 0.30) then
				if(speed < 10) then
					speed = speed + 1
				end
			elseif(speed > 0) then
				speed = speed -1
			end
			speedStepTime = love.timer.getTime()
		end
	elseif(gameStage == gameStages["STOP"]) then
		if(key == "escape") then
			os.exit()
		elseif(key == "return") then
			initGame()
		end
	end
end

function showScoreBoard(cnt, time, stage)
	love.graphics.setColor(0, 0, 0, 1)
	if(stage == gameStages["START"]) then
		love.graphics.printf(string.format("READY TO START! %1d", cnt), 0, 
			myCanvas:getHeight() * 0.70, myCanvas:getWidth() / 2, "center", 0, 2, 2)
	end
	if(stage == gameStages["RUN"]) then
		love.graphics.printf("GO!", 0, myCanvas:getHeight() * 0.70,
			myCanvas:getWidth() / 2, "center", 0, 2, 2)
	end
	if(stage == gameStages["RUN"]) or (stage == gameStages["STOP"]) then
		love.graphics.printf(string.format("TIME: %06.2f s", time), 0,
			myCanvas:getHeight() * 0.80, myCanvas:getWidth() / 2, "center", 0, 2, 2)
		love.graphics.print(string.format("Distance: %3d", distance), 0,
			myCanvas:getHeight() / 2 + 32)
	end
	if(stage == gameStages["STOP"]) then
		love.graphics.printf("GAME OVER (ENTER TO RESTART / ESC TO EXIT)", 0,
			myCanvas:getHeight() / 2, myCanvas:getWidth() / 2, "center", 0, 2, 2)
		love.graphics.printf(string.format("BEST TIME %06.2f s", record), 0, 
			myCanvas:getHeight() * 0.9, myCanvas:getWidth() / 2, "center", 0, 2, 2)
	end
end

function showSpeedBar()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", screenX / 2 - 4 - 5*32,
		runnerY + 112, 324, 40)
	for i = 0, math.floor(speed) - 1 do
		love.graphics.draw(speedbarImg, screenX / 2 + (i - 5) * 32,
			runnerY + 116)
	end
end

function love.load()
	love.window.setMode(screenX, screenY)
	runnerImg = love.graphics.newImage("runner1.png")
	speedbarImg = love.graphics.newImage("speedbar.png")
	canvasImg = love.graphics.newImage("canvas.png")

	myCanvas = love.graphics.newCanvas(screenX, screenY)
	love.graphics.setCanvas(myCanvas)
	love.graphics.draw(canvasImg, 0, 0)
	love.graphics.setCanvas()

	for i = 1, runnerImg:getWidth() / 64 do
		runnerSheet[i] = love.graphics.newQuad((i - 1) * 64, 0,
			64, 64, runnerImg:getDimensions())
	end

	initGame()
end

function love.update(dt)
	if gameStage == gameStages["START"] then
		elapsed = elapsed + dt
		if(elapsed >= 1) then
			counter = counter - 1
			elapsed = 0
		end
		if (counter == 0) then
			gameStage = gameStages["RUN"]
			elapsed = 0
			speedStepTime = love.timer.getTime()
		end
	elseif gameStage == gameStages["RUN"] then
		if((love.timer.getTime() - speedStepTime) > 0.5) and
			(speed > 0) then
			speed = speed - 1
			speedStepTime = love.timer.getTime()
		end
		runnerX = runnerX + speed * dt * 10
		elapsed = elapsed + dt
		if(runnerX >= screenX) then
			if(distance < 400) then
				runnerX = (runnerX - screenX)
				distance = distance + 100
			else
				if(record > elapsed) then
					record = elapsed
				end
				gameStage = gameStages["STOP"]
			end
		end
		if(speed == 0) then
			frameElapsed = 0
		else
			frameElapsed = frameElapsed + dt
			if(frameElapsed > 0.5 / speed) then
				frameElapsed = 0
				currentFrame = ((currentFrame + 1) % 6)
			end
		end
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(myCanvas, 0, 0)
	if(gameStage == gameStages["START"]) then
		showScoreBoard(counter, 0, gameStage)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(runnerImg, runnerSheet[currentFrame], runnerX, runnerY - 15,
			0, 1, 1)
	elseif(gameStage == gameStages["RUN"]) then
		showScoreBoard(0, elapsed, gameStage)
		love.graphics.setColor(1, 1, 1, 1)
		showSpeedBar(speed)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(runnerImg, runnerSheet[currentFrame + 1],
			runnerX, runnerY - 15, 0, 1, 1)
	elseif(gameStage == gameStages["STOP"]) then
		showScoreBoard(0, elapsed, gameStage)
	end
end