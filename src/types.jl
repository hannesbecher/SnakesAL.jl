
# we need a game type to hold the specs and state of a game


# we need ladders and snakes that are nested in the same abstract type
abstract type ShortCut end

# a shortcut that makes players to move forward
struct Ladder <: ShortCut
    from::Int
    to::Int
end
# a shortcut that makes players to move backward
struct Snake <: ShortCut
    from::Int
    to ::Int
end
# we need a board type to hold the board size and the snakes and ladders
struct Board
    size::Int
    shortcuts::Vector{<:ShortCut}
    # think whether to have the players/list thereof as properties of the board
end
# we need a player type to hold the player name and position
mutable struct Player
    name::String
    position::Int
end

# an abstract type for dice
abstract type AbstractDice end

# we need a dice type to roll the dice
struct Dice <: AbstractDice
    nSides::Int
end

# an additional dice type with weighted sides
struct WeightedDice <: AbstractDice
    nSides::Int
    weights::Vector{<:Real}
end

# a function to roll the abstract dice
roll(dice::AbstractDice) = error("roll not implemented for $(typeof(dice))")    
roll(dice::Dice) = rand(1:dice.nSides)
roll(dice::WeightedDice) = sample(1:dice.nSides, Weights(dice.weights))

# we need a game type to hold the specs and state of a game
mutable struct Game
    board::Board
    players::Vector{Player}
    dice::AbstractDice
    current_player_index::Int
    is_over::Bool
end
