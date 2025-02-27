local moving = require("moving")

local windowW, windowH = love.window.getMode()
local cellSize = windowH / 8

local mainFont = love.graphics.newFont(20)
mainFont:setFilter("nearest")
love.graphics.setFont(mainFont)

function love.load()
	local wPawn = love.graphics.newImage("assets/whitePawn.png")
	local wRook = love.graphics.newImage("assets/whiteRook.png")
	local wKnight = love.graphics.newImage("assets/whiteKnight.png")
	local wBishop = love.graphics.newImage("assets/whiteBishop.png")
	local wQueen = love.graphics.newImage("assets/whiteQueen.png")
	local wKing = love.graphics.newImage("assets/whiteKing.png")

	local token = love.graphics.newImage("assets/token.png")

	--pawn 1
	--rook 2
	--knight 3
	--bishop 4
	--queen 5
	--king 6
	--token 7

	PieceSprites = { wPawn, wRook, wKnight, wBishop, wQueen, wKing, token }

	Board = {
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 2, 3, 4, 5, 6, 4, 3, 2 },
	}

	ActiveX, ActiveY = nil, nil
	PossibleMoves = {}
	PlayerTurn = 1
	TokensLeft = 15
	GameEnded = false
	Winner = nil
	TurnNumber = 1
	ExtraTurns = 5
	BoardW, BoardH = #Board, #Board[1]

	BoardCanvas = love.graphics.newCanvas(windowH, windowH)
	love.graphics.setCanvas(BoardCanvas)
	for y = 0, BoardH do
		for x = 0, BoardW do
			--DRAW BOARD
			if (x + y) % 2 == 0 then
				love.graphics.setColor(0.933, 0.933, 0.835)
				love.graphics.rectangle("fill", x * cellSize, y * cellSize, cellSize, cellSize)
				love.graphics.setColor(0.49, 0.58, 0.365)
				if x == 0 then
					love.graphics.print(tostring(8 - y), x * cellSize, y * cellSize)
				end
				if y == 7 then
					love.graphics.print(string.char(97 + x), (x + 1) * cellSize - 16, (y + 1) * cellSize - 24)
				end
			else
				love.graphics.setColor(0.49, 0.58, 0.365)
				love.graphics.rectangle("fill", x * cellSize, y * cellSize, cellSize, cellSize)
				love.graphics.setColor(0.933, 0.933, 0.835)
				if x == 0 then
					love.graphics.print(tostring(8 - y), x * cellSize, y * cellSize)
				end
				if y == 7 then
					love.graphics.print(string.char(97 + x), (x + 1) * cellSize - 16, (y + 1) * cellSize - 24)
				end
			end
		end
	end
	love.graphics.setCanvas()

	SidebarCanvas = love.graphics.newCanvas(windowW, windowH)
	love.graphics.setCanvas(SidebarCanvas)

	local mainFontH = mainFont:getHeight()
	--QUIT BUTTON
	QuitButton = {
		x = 600,
		y = windowH - 50,
		w = 200,
		h = 50,
		text = "QUIT",
		color = { 0.8, 0.3, 0.3 },
		colorText = { 1, 1, 1 },
	}
	love.graphics.setColor(QuitButton.color)
	love.graphics.rectangle("fill", QuitButton.x, QuitButton.y, QuitButton.w, QuitButton.h)
	love.graphics.setColor(QuitButton.colorText)
	love.graphics.print(
		QuitButton.text,
		(QuitButton.x + QuitButton.w / 2) - mainFont:getWidth(QuitButton.text) / 2,
		windowH - (windowH - QuitButton.y - (QuitButton.h / 2)) - mainFontH / 2
	)

	--RESTART BUTTON
	RestartButton = {
		x = 600,
		y = windowH - 100,
		w = 200,
		h = 50,
		text = "RESTART",
		color = { 0.3, 0.3, 0.3 },
		colorText = { 1, 1, 1 },
	}
	love.graphics.setColor(RestartButton.color)
	love.graphics.rectangle("fill", RestartButton.x, RestartButton.y, RestartButton.w, RestartButton.h)
	love.graphics.setColor(RestartButton.colorText)
	love.graphics.print(
		RestartButton.text,
		(RestartButton.x + RestartButton.w / 2) - mainFont:getWidth(RestartButton.text) / 2,
		windowH - (windowH - RestartButton.y - (RestartButton.h / 2)) - mainFontH / 2
	)

	--ADD TURNS BUTTONS
	PlusButton = {
		x = 600,
		y = windowH - 150,
		w = 100,
		h = 50,
		text = "+",
		color = { 1, 1, 1 },
		colorText = { 1, 1, 1 },
	}
	love.graphics.rectangle("line", PlusButton.x, PlusButton.y, PlusButton.w, PlusButton.h)
	love.graphics.print(
		PlusButton.text,
		(PlusButton.x + PlusButton.w / 2) - mainFont:getWidth(PlusButton.text) / 2,
		windowH - (windowH - PlusButton.y - (PlusButton.h / 2)) - mainFontH / 2
	)
	MinusButton = {
		x = 700,
		y = windowH - 150,
		w = 100,
		h = 50,
		text = "-",
		color = { 1, 1, 1 },
		colorText = { 1, 1, 1 },
	}
	love.graphics.rectangle("line", MinusButton.x, MinusButton.y, MinusButton.w, MinusButton.h)
	love.graphics.print(
		MinusButton.text,
		(MinusButton.x + MinusButton.w / 2) - mainFont:getWidth(MinusButton.text) / 2,
		windowH - (windowH - MinusButton.y - (MinusButton.h / 2)) - mainFontH / 2
	)

	love.graphics.setColor(1, 1, 1)
	love.graphics.printf("Add extra turns for chess", PlusButton.x, PlusButton.y - 50, 200, "left")
	love.graphics.setCanvas()

	Restart()
end

function Restart()
	Board = {
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 2, 3, 4, 5, 6, 4, 3, 2 },
	}
	Winner = nil
	GameEnded = false
	TurnNumber = 1
	ActiveX, ActiveY = nil, nil
	PossibleMoves = {}
	PlayerTurn = 1
	TokensLeft = 15
	BoardW, BoardH = #Board, #Board[1]
end

function DropToken(x)
	local y = 0
	while Board[y + 1][x] == 0 do
		y = y + 1
	end
	Board[y][x] = 7
	PlayerTurn = 1
	TokensLeft = TokensLeft - 1
	return x, y
end

function CheckWin(lastX, lastY)
	local count = 0
	--Check horizontal
	for i = 1, BoardW do
		if Board[lastY][i] == 7 then
			count = count + 1
		else
			count = 0
		end
		if count >= 4 then
			return true
		end
	end
	count = 0
	--Check Vertical
	for j = 1, BoardH do
		if Board[j][lastX] == 7 then
			count = count + 1
		else
			count = 0
		end
		if count >= 4 then
			return true
		end
	end
	--Check diagonal top-left to bottom-right
	count = 0
	local row = lastY
	local col = lastX
	while row > 1 and col > 1 do
		row = row - 1
		col = col - 1
	end
	while row <= BoardH and col <= BoardW do
		if Board[row][col] == 7 then
			count = count + 1
		else
			count = 0
		end
		if count >= 4 then
			return true
		end
		row = row + 1
		col = col + 1
	end
	--Check diagonal bottom-left to top-right
	count = 0
	row = lastY
	col = lastX
	while row < BoardH and col > 1 do
		row = row + 1
		col = col - 1
	end
	while row >= 1 and col <= BoardW do
		if Board[row][col] == 7 then
			count = count + 1
		else
			count = 0
		end
		if count >= 4 then
			return true
		end
		row = row - 1
		col = col + 1
	end
	return false
end

function EndGame(w)
	if w == 1 then
		Winner = "Chess"
	elseif w == 2 then
		Winner = "Connect 4"
	else
		Winner = "Undefined"
	end
	GameEnded = true
end

function CheckFallingTokens(x, y)
	if Board[y - 1][x] == 7 then
		local j = y
		while Board[j - 1][x] == 7 do
			while Board[y + 1][x] == 0 do
				y = y + 1
			end
			Board[j - 1][x] = 0
			Board[y][x] = 7
			if CheckWin(x, y) then
				EndGame(2)
				break
			end
			j = j - 1
			y = j
		end
	end
end

local function checkButtonPress(x, y, b)
	return x > b.x and x < b.x + b.w and y > b.y and y < b.y + b.h
end

function love.mousepressed(x, y, button)
	if button == 1 then
		-- SIDEBAR BUTTONS
		if checkButtonPress(x, y, QuitButton) then
			love.event.quit()
		elseif checkButtonPress(x, y, RestartButton) then
			Restart()
		elseif checkButtonPress(x, y, PlusButton) then
			ExtraTurns = ExtraTurns + 1
		elseif checkButtonPress(x, y, MinusButton) then
			if ExtraTurns > 1 then
				ExtraTurns = ExtraTurns - 1
			end
		end

		-- BOARD
		local clickX = math.floor(x / cellSize) + 1
		local clickY = math.floor(y / cellSize) + 1
		if clickX >= 1 and clickX <= BoardW and clickY >= 1 and clickY <= BoardH and not GameEnded then
			if PlayerTurn == 1 then
				local piece = Board[clickY][clickX]

				for _, move in ipairs(PossibleMoves) do
					if move[1] == clickX and move[2] == clickY then
						Board[clickY][clickX] = Board[ActiveY][ActiveX]
						Board[ActiveY][ActiveX] = 0
						if ActiveY > 1 then
							CheckFallingTokens(ActiveX, ActiveY)
						end
						PossibleMoves = {}
						ActiveX = nil
						ActiveY = nil
						if TurnNumber >= ExtraTurns then
							PlayerTurn = 2
						end
						TurnNumber = TurnNumber + 1
						return
					end
				end

				PossibleMoves = {}
				if piece ~= 0 then
					PossibleMoves = moving.showMoves(piece, Board, clickX, clickY)
					ActiveX = clickX
					ActiveY = clickY
				else
					ActiveX = nil
					ActiveY = nil
				end
			elseif PlayerTurn == 2 then
				if Board[1][clickX] == 0 then
					local prevTokenX, prevTokenY = DropToken(clickX)
					if CheckWin(prevTokenX, prevTokenY) then
						EndGame(2)
					elseif TokensLeft <= 0 then
						EndGame(1)
					end
				end
			end
		end
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	--DRAW BOARD
	love.graphics.draw(BoardCanvas, 0, 0)

	--SIDEBAR
	love.graphics.setColor(0, 0, 0.3)
	love.graphics.rectangle("fill", 600, 0, 200, windowH)
	love.graphics.setColor(1, 1, 1)
	love.graphics.printf("Chess gets the first " .. tostring(ExtraTurns) .. " turns", 600, 120, 200, "left")

	love.graphics.draw(SidebarCanvas)
	love.graphics.print("Player (" .. PlayerTurn .. ") turn", windowH, 0)
	love.graphics.print("Tokens left: " .. TokensLeft, windowH, 30)

	--DRAW POSSIBLE MOVES FOR ACTIVE PIECE
	if ActiveX then
		love.graphics.setColor(0.886, 0.318, 0.29)
		love.graphics.rectangle("fill", (ActiveX - 1) * cellSize, (ActiveY - 1) * cellSize, cellSize, cellSize)
		for _, move in pairs(PossibleMoves) do
			love.graphics.setColor(0.24, 0.24, 0.24, 0.43)
			love.graphics.circle(
				"fill",
				(move[1] - 1) * cellSize + (cellSize / 2),
				(move[2] - 1) * cellSize + (cellSize / 2),
				10
			)
		end
	end

	--DRAW TOKEN GHOST
	if PlayerTurn == 2 then
		local mouseX = math.floor(love.mouse.getX() / cellSize) * cellSize
		love.graphics.setColor(1, 1, 1, 0.5)
		if mouseX < 600 then
			love.graphics.draw(PieceSprites[7], mouseX, 0, 0, 0.5, 0.5)
		end
	end

	--DRAW PIECES
	for y = 0, 7 do
		for x = 0, 7 do
			local piece = Board[y + 1][x + 1]
			love.graphics.setColor(1, 1, 1)
			if piece ~= 0 then
				love.graphics.draw(PieceSprites[piece], x * cellSize, y * cellSize, 0, 0.5, 0.5)
			end
		end
	end

	--WINNING SCREEN
	if GameEnded then
		local text = Winner .. " Won the Game!!!"
		local textW = mainFont:getWidth(text)
		love.graphics.setColor(0, 0, 0.3)
		love.graphics.rectangle("fill", windowW / 2 - textW / 2, windowH / 2 - 50, textW, 100)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(text, windowW / 2 - (textW / 2), windowH / 2 - mainFont:getHeight() / 2, 0)
	end
end
