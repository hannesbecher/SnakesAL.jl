
# rewrite as multiple methods
function makeDiceAndRoll(nSides::Int)
    dice = Dice(nSides)
    return roll(dice)
end

#make sure this works for both integer and float weights
function makeDiceAndRoll(nSides::Int, weights::Vector{<:Real})
    @assert length(weights) == nSides "Length of weights must be equal to number of sides"
    @assert all(w -> w >= 0, weights) "All weights must be non-negative"
    @assert sum(weights) > 0 "Sum of weights must be positive"  
    ww = sum(weights)/nSides
    dice = WeightedDice(nSides, weights)
    return roll(dice)
end


# write out the field names of the Game struct below

testGame2() = Game(Board(100, [Ladder(3, 22), Snake(17, 4)]),
                    [Player("Alice", [1]), Player("Bob", [1])],
                    Dice(6))

testGame0() = Game(NM0, [Player("Alice", [1])], Dice(6))


function oneTurn!(g::Game, print=false)
    if g.is_over
        println("Game is already over.")
        return g
    end
    current_player = g.players[g.current_player_index]
    roll_value = roll(g.dice)
    if(print) println("Player $(current_player.name) rolled a $roll_value") end
    new_position = current_player.position[end] + roll_value
    if new_position > g.board.size
        new_position = g.board.size # stop at end, dont bounce or overshoot
        #new_position = g.board.size - (new_position - g.board.size) # bounce back if overshoot
        #println("Player $(current_player.name) overshot and bounces back to $new_position")
    end
    # check for shortcuts
    for sc in g.board.shortcuts
        if sc.from == new_position
            if(print) println("Player $(current_player.name) hit a shortcut from $(sc.from) to $(sc.to)") end
            new_position = sc.to
            break
        end
    end
    push!(current_player.position, new_position)
    if(print) println("Player $(current_player.name) moved to position $(current_player.position[end])") end
    if current_player.position[end] == g.board.size
        g.is_over = true
        if(print) println("Player $(current_player.name) wins!") end
    end
    g.current_player_index = mod1(g.current_player_index + 1, length(g.players))
    return g
end

function oneRound!(g::Game; print=false)
    g.round += 1
    if(print) println("=== Round $(g.round) ===") end
    for _ in 1:length(g.players)
        g = oneTurn!(g, print)
        if g.is_over
            break
        end
    end
    return g
end

# convert position to table coordinates
posToTBT(pos::Int) = (((pos - 1) % 10 + 1) * 100 - 50, (10 - div(pos - 1, 10)) * 100 - 50)


# alternative (nicer) pos to 10x10 function with 'forth and back'
posToTBT2(pos::Int) = begin
    row = div(pos - 1, 10)
    col = (pos - 1) % 10
    if isodd(row)
        col = 9 - col
    end
    return ((col + 1) * 100 - 50, (10 - row) * 100 - 50)
end

function runToEnd!(g::Game, rMax=1e6)
    while g.round <= rMax && !g.is_over
        g = oneRound!(g)
    end
    return g
end 