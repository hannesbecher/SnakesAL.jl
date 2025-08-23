
# we need a game type to hold the specs and state of a game


# we need ladders and snakes that are nested in the same abstract type
abstract type ShortCut end

struct Ladder <: ShortCut
    from::Int
    to::Int
end

struct Snake <: ShortCut
    from::Int
    to ::Int
end
# we need a board type to hold the board size and the snakes and ladders
struct Board
    size::Int
    shortcuts::Vector{ShortCut}
end
# we need a player type to hold the player name and position
struct Player
    name::String
    position::Int
end
# we need a game type to hold the specs and state of a game
struct Game
    board::Board
    players::Vector{Player}
    current_player_index::Int
    is_over::Bool
end

# an abstract type for dice
abstract type AbstractDice end

# we need a dice type to roll the dice
struct Dice <: AbstractDice
    sides::Int
end

# an additional dice type with weighted sides
struct WeightedDice <: AbstractDice
    sides::Int
    weights::Vector{<:Real}
end

# a function to roll the abstract dice
roll(dice::AbstractDice) = error("roll not implemented for $(typeof(dice))")    
roll(dice::Dice) = rand(1:dice.sides)
roll(dice::WeightedDice) = sample(1:dice.sides, Weights(dice.weights))

