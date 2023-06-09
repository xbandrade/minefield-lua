math.randomseed(os.time())
local Minefield = {}

function Minefield:new(rows, cols, mine_rate)
    mine_rate = mine_rate or 0.2
    local obj = {
        rows = rows,
        cols = cols,
        matrix = {},
        reveal = {},
        first_hit = true,
        hits_left = rows * cols
    }
    for i = 1, rows do
        obj.matrix[i] = {}
        for j = 1, cols do
            obj.matrix[i][j] = '-'
        end
    end
    local mines_count = 0
    for i = 1, rows do
        obj.reveal[i] = {}
        for j = 1, cols do
            local rand = math.random()
            obj.reveal[i][j] = rand < mine_rate and 1 or 0
            mines_count = mines_count + obj.reveal[i][j]
        end
    end
    obj.hits_left = obj.hits_left - mines_count
    setmetatable(obj, {__index = Minefield})
    return obj
end

function Minefield:get(row, col)
    return self.reveal[row][col]
end
function Minefield:get_matrix(row, col)
    return self.matrix[row][col]
end

function Minefield:set_matrix(row, col, val)
    self.matrix[row][col] = val
end

function Minefield:reveal_mines()
    for i = 1, self.rows do
        for j = 1, self.cols do
            if self:get(i, j) == 1 then
                self:set_matrix(i, j, 'X')
            end
        end
    end
end

function Minefield:game_over(row, col)
    io.write('\nGame Over!\n')
    self:reveal_mines()
    self:print()
end

function Minefield:victory()
    io.write('\nVictory!\n')
    self:reveal_mines()
    self:print()
end

function Minefield:has_mine(row, col)
    return self.reveal[row][col] == 1 and 1 or 0
end

function Minefield:is_valid_pos(row, col)
    return row >= 1 and row <= self.rows and col >= 1 and col <= self.cols
end

function Minefield:print(matrix)
    matrix = matrix or self.matrix
    io.write('\n')
    for i = 1, self.rows do
        for j = 1, self.cols do
            io.write(matrix[i][j] .. ' ')
        end
        io.write('\n')
    end
    io.write('\n\n')
end

function Minefield:hit(row, col, rec)
    rec = rec or false
    if self.first_hit then
        self.reveal[row][col] = 0
        self.first_hit = false
    elseif self:get(row, col) == 1 then
        return -1  -- Hit a mine
    end
    local matrix_value = self:get_matrix(row, col)
    if matrix_value ~= '-' then
        if not rec then
            io.write('Position already hit!\n')
        end
        return matrix_value
    end
    local mines = 0
    for i = -1, 1 do
        for j = -1, 1 do
            if (i ~= 0 or j ~= 0) and self:is_valid_pos(row + i, col + j) then
                mines = mines + self:has_mine(row + i, col + j)
            end
        end
    end
    self:set_matrix(row, col, mines)
    self.hits_left = self.hits_left - 1
    if self.hits_left <= 0 then
        return -2  -- Victory
    end
    if mines == 0 then
        self:hit_neighbors(row, col)
    end
    return mines
end

function Minefield:hit_neighbors(row, col, rec)
    for i = -1, 1 do
        for j = -1, 1 do
            if ((i ~= 0 or j ~= 0) and
                    self:is_valid_pos(row + i, col + j) and
                    self:get_matrix(row + i, col + j) == '-') then
                self:hit(row + i, col + j, true)
            end
        end
    end
end

return Minefield
