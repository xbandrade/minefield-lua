local Minefield = require('minefield')
local game = Minefield:new(15, 20, .1)  -- rows, columns, mine rate
game:print()

while true do
    io.write('r c - Hit square on position (r, c)\n')
    io.write('1 - Show Matrix\n0 - Exit\n>>> ')
    local cin = io.read()
    if cin == '1' then
        game:print()
    elseif cin == '0' then
        break
    else
        local row, col = cin:match('(%d+)%s+(%d+)')
        if row and col then
            row = tonumber(row)
            col = tonumber(col)
            if game:is_valid_pos(row, col) then
                local mines_hit = game:hit(row, col)
                if mines_hit == -1 then
                    game:game_over(row, col)
                    break
                elseif mines_hit == -2 then
                    game:victory()
                    break
                else
                    game:print()
                end
            else
                io.write('\nInvalid Position\n')
            end
        else
            io.write('\nInvalid input format\n')
        end
    end
end
