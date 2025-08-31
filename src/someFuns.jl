
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

testGame() = Game(Board(100, [Ladder(3, 22), Snake(17, 4)]),
                    [Player("Alice", 1), Player("Bob", 1)],
                    Dice(6),
                    1,
                    false)


oneRound(g::Game) = begin
    if g.is_over
        println("Game is already over.")
        return g
    end
    current_player = g.players[g.current_player_index]
    roll_value = roll(g.dice)
    println("Player $(current_player.name) rolled a $roll_value")
    new_position = current_player.position + roll_value
    if new_position > g.board.size
        new_position = g.board.size - (new_position - g.board.size) # bounce back if overshoot
        println("Player $(current_player.name) overshot and bounces back to $new_position")
    end
    # check for shortcuts
    for sc in g.board.shortcuts
        if sc.from == new_position
            println("Player $(current_player.name) hit a shortcut from $(sc.from) to $(sc.to)")
            new_position = sc.to
            break
        end
    end
    current_player.position = new_position
    println("Player $(current_player.name) moved to position $(current_player.position)")
    if current_player.position == g.board.size
        g.is_over = true
        println("Player $(current_player.name) wins!")
    end
    g.current_player_index = mod1(g.current_player_index + 1, length(g.players))
    return g
end