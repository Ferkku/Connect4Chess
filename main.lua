local moving = require "moving"

local windowW, windowH = love.window.getMode()
local cellSize = windowH / 8

local mainFont = love.graphics.newFont(20)
mainFont:setFilter("nearest")
love.graphics.setFont(mainFont)

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

local pieceSprites = {wPawn, wRook, wKnight, wBishop, wQueen, wKing, token}

local boardCanvas = love.graphics.newCanvas(windowH, windowH)
love.graphics.setCanvas(boardCanvas)
    for y=0, 7 do
        for x=0, 7 do
            --DRAW BOARD
            if (x + y) % 2 == 0 then
                love.graphics.setColor(0.933, 0.933, 0.835)
                love.graphics.rectangle("fill", x * cellSize, y * cellSize, cellSize, cellSize)
                love.graphics.setColor(0.49, 0.58, 0.365)
                if x == 0 then
                    love.graphics.print(tostring(8-y), x * cellSize, y * cellSize)
                end
                if y == 7 then
                    love.graphics.print(string.char(97 + x), (x+1) * cellSize - 16, (y+1) * cellSize - 24)
                end
            else
                love.graphics.setColor(0.49, 0.58, 0.365)
                love.graphics.rectangle("fill", x * cellSize, y * cellSize, cellSize, cellSize)
                love.graphics.setColor(0.933, 0.933, 0.835)
                if x == 0 then
                    love.graphics.print(tostring(8-y), x * cellSize, y * cellSize)
                end
                if y == 7 then
                    love.graphics.print(string.char(97 + x), (x+1) * cellSize - 16, (y+1) * cellSize - 24)
                end
            end
        end
    end
love.graphics.setCanvas()

local sidebarCanvas = love.graphics.newCanvas(windowW, windowH)
love.graphics.setCanvas(sidebarCanvas)
    --INFO
    love.graphics.setColor(0, 0, 0.3)
    love.graphics.rectangle("fill", 600, 0, 200, windowH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Chess gets the first 3 turns", 600, 120, 200, "left")

    --QUIT BUTTON
    love.graphics.setColor(0.8, 0.3, 0.3)
    love.graphics.rectangle("fill", windowH, windowH - 50, 200, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("QUIT", windowH + 100 - mainFont:getWidth("QUIT") / 2, windowH - 25 - mainFont:getHeight() / 2)

    --RESTART BUTTON
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", windowH, windowH - 100, 200, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("RESTART", windowH + 100 - mainFont:getWidth("RESTART") / 2, windowH - 75 - mainFont:getHeight() / 2)
love.graphics.setCanvas()

local board
local activeX, activeY
local possibleMoves
local playerTurn
local tokensLeft
local gameEnded
local winner
local turnNumber

local function restart()
    board = {
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 1, 1, 1, 1, 1, 1},
        {2, 3, 4, 5, 6, 4, 3, 2}
    }
    winner = nil
    gameEnded = false
    turnNumber = 1
    activeX, activeY = nil, nil
    possibleMoves = {}
    playerTurn = 1
    tokensLeft = 15
end

function love.load()
    restart()
end

local function dropToken(x)
    local y = 0
    while board[y+1][x] == 0 do
        y = y + 1
    end
    board[y][x] = 7
    playerTurn = 1
    tokensLeft = tokensLeft - 1
    return x, y
end

local function checkWin(lastX, lastY)
    local count = 0
    --Check horizontal
    for i=1, 8 do
        if board[lastY][i] == 7 then
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
    for j=1, 8 do
        if board[j][lastX] == 7 then
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
    while row <= 8 and col <= 8 do
        if board[row][col] == 7 then
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
    while row < 8 and col > 1 do
        row = row + 1
        col = col - 1
    end
    while row >= 1 and col <= 8 do
        if board[row][col] == 7 then
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

local function endGame(w)
    if w == 1 then
        winner = "Chess"
    elseif w == 2 then
        winner = "Connect 4"
    else
        winner = "Nobody"
    end
    gameEnded = true
end

local function checkFallingTokens(x, y)
    if board[y-1][x] == 7 then
        local j = y
        while board[j-1][x] == 7 do
            while board[y+1][x] == 0 do
                y = y + 1
            end
            board[j-1][x] = 0
            board[y][x] = 7
            if checkWin(x, y) then
                endGame(2)
                break
            end
            j = j - 1
            y = j
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if x > windowH and x < windowW and y > windowH - 50 and y < windowH then
            love.event.quit()
        elseif x > windowH and x < windowW and y > windowH - 100 and y < windowH - 50 then
            restart()
        end
        local clickX = math.floor(x / cellSize) + 1
        local clickY = math.floor(y / cellSize) + 1
        if clickX >= 1 and clickX <= 8 and clickY >= 1 and clickY <= 8 and not gameEnded then
            if playerTurn == 1 then
                local piece = board[clickY][clickX]

                for _, move in ipairs(possibleMoves) do
                    if move[1] == clickX and move[2] == clickY then
                        board[clickY][clickX] = board[activeY][activeX]
                        board[activeY][activeX] = 0
                        if activeY > 1 then
                            checkFallingTokens(activeX, activeY)
                        end
                        possibleMoves = {}
                        activeX = nil
                        activeY = nil
                        if turnNumber > 2 then
                            playerTurn = 2
                        end
                        turnNumber = turnNumber + 1
                        return
                    end
                end

                possibleMoves = {}
                if piece ~= 0 then
                    possibleMoves = moving.showMoves(piece, board, clickX, clickY)
                    activeX = clickX
                    activeY = clickY
                else
                    activeX = nil
                    activeY = nil
                end
            elseif playerTurn == 2 then
                if board[1][clickX] == 0 then
                    local prevTokenX, prevTokenY = dropToken(clickX)
                    if checkWin(prevTokenX, prevTokenY) then
                        endGame(2)
                    elseif tokensLeft <= 0 then
                        endGame(1)
                    end
                end
            end
        end
    end
end

function love.draw()

    love.graphics.setColor(1, 1, 1)
    --DRAW BOARD
    love.graphics.draw(boardCanvas, 0, 0)

    --SIDEBAR
    love.graphics.draw(sidebarCanvas)
    love.graphics.print("Player (" .. playerTurn .. ") turn", windowH, 0)
    love.graphics.print("Tokens left: " .. tokensLeft, windowH, 30)

    --DRAW POSSIBLE MOVES FOR ACTIVE PIECE
    if activeX then
        love.graphics.setColor(0.886, 0.318, 0.29)
        love.graphics.rectangle("fill", (activeX-1) * cellSize, (activeY-1) * cellSize, cellSize, cellSize)
        for _, move in pairs(possibleMoves) do
            love.graphics.setColor(0.24, 0.24, 0.24, 0.43)
            love.graphics.circle("fill", (move[1]-1) * cellSize + (cellSize / 2), (move[2]-1) * cellSize + (cellSize / 2), 10)
        end
    end

    --DRAW TOKEN GHOST
    if playerTurn == 2 then
        local mouseX = math.floor(love.mouse.getX() / cellSize) * cellSize
        love.graphics.setColor(1, 1, 1, 0.5)
        if mouseX < 600 then
            love.graphics.draw(pieceSprites[7], mouseX, 0, 0, 0.5, 0.5)
        end
    end

    --DRAW PIECES
    for y=0, 7 do
        for x=0, 7 do
            local piece = board[y+1][x+1]
            love.graphics.setColor(1, 1, 1)
            if piece ~= 0 then
                love.graphics.draw(pieceSprites[piece], x * cellSize, y * cellSize, 0, 0.5, 0.5)
            end
        end
    end

    --WINNING SCREEN
    if gameEnded then
        local text = winner .. " Won the Game!!!"
        local textW = mainFont:getWidth(text)
        love.graphics.setColor(0, 0, 0.3)
        love.graphics.rectangle("fill", windowW / 2 - textW / 2, windowH / 2 - 50, textW, 100)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(text, windowW / 2 - (textW / 2), windowH / 2 - mainFont:getHeight() / 2, 0)
    end

end
