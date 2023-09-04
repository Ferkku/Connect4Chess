local moving = {}
local directions = {
    {1, 1},
    {1, -1},
    {-1, 1},
    {-1, -1}
}
local possibleMoves = {}

local function getRookMoves(board, x, y)
    for i=x-1, 1, -1 do
        if board[y][i] ~= 0 then
            break
        end
        table.insert(possibleMoves, {i, y})
    end
    for i=x+1, 8 do
        if board[y][i] ~= 0 then
            break
        end
        table.insert(possibleMoves, {i, y})
    end
    for j=y-1, 1, -1 do
        if board[j][x] ~= 0 then
            break
        end
        table.insert(possibleMoves, {x, j})
    end
    for j=y+1, 8 do
        if board[j][x] ~= 0 then
            break
        end
        table.insert(possibleMoves, {x, j})
    end
end

local function getBishopMoves(board, x, y)
    for _, dir in ipairs(directions) do
        local i=x + dir[1]
        local j=y + dir[2]
        while true do
            if i > 8 or j > 8 or i < 1 or j < 1 then
                break
            end
            if board[j][i] == 0 then
                table.insert(possibleMoves, {i, j})
            else
                break
            end
            i = i + dir[1]
            j = j + dir[2]
        end
    end
end

function moving.showMoves(piece, board, x, y)
    possibleMoves = {}
    if piece == 1 and y > 1 then
        if board[y-1][x] == 0 then
            table.insert(possibleMoves, {x, y-1})
            if y == 7 and board[y-2][x] == 0 then
                table.insert(possibleMoves, {x, y-2})
            end
        end
    elseif piece == 2 then
        getRookMoves(board, x, y)
    elseif piece == 3 then
        local moves = {
            {x + 2, y + 1},
            {x + 2, y - 1},
            {x - 2, y + 1},
            {x - 2, y - 1},
            {x + 1, y + 2},
            {x + 1, y - 2},
            {x - 1, y + 2},
            {x - 1, y - 2}
        }

        for _, move in ipairs(moves) do
            local moveX, moveY = move[1], move[2]
            if moveX >= 1 and moveX <= 8 and moveY >= 1 and moveY <= 8 then
                if board[moveY][moveX] == 0 then
                    table.insert(possibleMoves, {moveX, moveY})
                end
            end
        end
    elseif piece == 4 then
        getBishopMoves(board, x, y)
    elseif piece == 5 then
        getRookMoves(board, x, y)
        getBishopMoves(board, x, y)
    elseif piece == 6 then
        for i=-1, 1 do
            for j=-1, 1 do
                if x+i >= 1 and y+j >= 1 and x+i <= 8 and y+j <= 8 then
                    if board[y+j][x+i] == 0 then
                        table.insert(possibleMoves, {x+i, y+j})
                    end
                end
            end
        end
    end

    return possibleMoves
end

return moving
