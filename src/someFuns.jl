
# # rewrite as multiple methods
# """
#     makeDiceAndRoll(nSides::Int)
# 
# Create a dice with `nSides` sides and roll it once.
# """
# function makeDiceAndRoll(nSides::Int)
#     dice = Dice(nSides)
#     return roll(dice)
# end
# 
# #make sure this works for both integer and float weights
# """
#     makeDiceAndRoll(nSides::Int, weights::Vector{<:Real})
# 
# Create a weighted dice with `nSides` sides and given `weights`, and roll it once.
# """
# function makeDiceAndRoll(nSides::Int, weights::Vector{<:Real})
#     @assert length(weights) == nSides "Length of weights must be equal to number of sides"
#     @assert all(w -> w >= 0, weights) "All weights must be non-negative"
#     @assert sum(weights) > 0 "Sum of weights must be positive"  
#     ww = sum(weights)/nSides
#     dice = WeightedDice(nSides, weights)
#     return roll(dice)
# end
# 

# write out the field names of the Game struct below

"""
    testGame2()

Create a test game with two players, a custom board and a 6-sided dice.
"""
testGame2() = Game(Board(100, [Ladder(3, 22), Snake(17, 4)]),
                    [Player("Alice", [1]), Player("Bob", [1])],
                    Dice(6))

"""
    testGame0()

Create a simple test game with one player, a standard board and a 6-sided dice.
"""
testGame0() = Game(NM0, [Player("Alice", [1])], Dice(6))


"""
    oneTurn!(g::Game; print=false)

Run a single turn of the game, advancing the current player by one roll.
"""
function oneTurn!(g::Game; print=false)
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


"""
    oneRound!(g::Game; print=false)

Run a single round of the game, advancing all players by one turn.
"""
function oneRound!(g::Game; print=false)
    if g.is_over
        if(print) println("Game is already over.") end
        return g
    end 
    g.round += 1
    if(print) println("=== Round $(g.round) ===") end
    for _ in 1:length(g.players)
        g = oneTurn!(g, print=print)
        if g.is_over
            break
        end
    end
    return g
end

# convert position to table coordinates
"""
    posToTBT(pos::Int)

Convert a board position (1 to 100) to (x,y) coordinates for plotting on a 10x10 board.
"""
posToTBT(pos::Int) = (((pos - 1) % 10 + 1) * 100 - 50, (10 - div(pos - 1, 10)) * 100 - 50)


# alternative (nicer) pos to 10x10 function with 'forth and back'
"""
    posToTBT2(pos::Int)

Convert a board position (1 to 100) to (x,y) coordinates for plotting on a 10x10 board with alternating row directions.
"""
function posToTBT2(pos::Int) 
    row = div(pos - 1, 10)
    col = (pos - 1) % 10
    if isodd(row)
        col = 9 - col
    end
    return ((col + 1) * 100 - 50, (10 - row) * 100 - 50)
end

"""
    runToEnd!(g::Game; rMax=1e6)

Run the Game until completion or until `rMax` rounds have been played.
"""
function runToEnd!(g::Game; rMax=1e6)
    while g.round <= rMax && !g.is_over
        g = oneRound!(g; print=false)
    end
    return g
end 


"""
    runWithReps(g::Game, nReps::Int; rMax=1e6)

Run independent replicates of the game `g` until completion or until `rMax` rounds have been played. Retains the entire Game object for each replicate.
"""
function runWithReps(g::Game, nReps::Int; rMax=1e6)
    ggs = Game[]
    
    for rep in 1:nReps
        gRep = deepcopy(g)
        runToEnd!(gRep; rMax=rMax)
        push!(ggs, gRep)
    end
    return ggs
end