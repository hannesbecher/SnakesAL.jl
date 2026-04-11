
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
    takeTurn!(g::Game)

Run a single turn of the game and return a `TurnSummary` describing the outcome.
Returns `nothing` when the game is already over.
"""
function takeTurn!(g::Game)
    g.is_over && return nothing

    current_player_index = g.current_player_index
    current_player = g.players[current_player_index]
    start_position = current_player.position[end]
    roll_value = roll(g.dice)
    landing_position = min(start_position + roll_value, g.board.size)
    new_position = landing_position
    shortcut = nothing

    for sc in g.board.shortcuts
        if sc.from == new_position
            shortcut = sc
            new_position = sc.to
            break
        end
    end

    push!(current_player.position, new_position)
    won = new_position == g.board.size
    won && (g.is_over = true)
    g.current_player_index = mod1(g.current_player_index + 1, length(g.players))

    return TurnSummary(
        current_player.name,
        current_player_index,
        start_position,
        roll_value,
        landing_position,
        new_position,
        shortcut,
        won,
    )
end

"""
    oneTurn!(g::Game; print=false)

Run a single turn of the game, advancing the current player by one roll.
"""
function oneTurn!(g::Game; print=false)
    summary = takeTurn!(g)
    if isnothing(summary)
        if(print) println("Game is already over.") end
        return g
    end

    if(print) println("Player $(summary.player_name) rolled a $(summary.roll_value)") end
    if(print) println("Player $(summary.player_name) landed on $(summary.landing_position)") end
    if !isnothing(summary.shortcut) && print
        println("Player $(summary.player_name) hit a shortcut from $(summary.shortcut.from) to $(summary.shortcut.to)")
    end
    if(print) println("Player $(summary.player_name) moved to position $(summary.end_position)") end
    if summary.won && print
        println("Player $(summary.player_name) wins!")
    end

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

Convert a board position (1 to 100) to (x,y) coordinates for plotting on a 10x10 board with
alternating row directions.
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

Run independent replicates of the game `g` until completion or until `rMax` rounds have
been played. Retains the entire Game object for each replicate.
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
