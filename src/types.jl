
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


function NaMiBoard(size::Int, elements::AbstractArray{Int,2})
    # check the input is correct
    @assert all(diff(elements[1,:]) .>= 1) "Starting point must be in strictly monotonic increasing order"
    @assert all(elements[1,:] .!= elements[2,:]) "A shortcut must start and end on different fields"
    @assert all(elements .> 1) "All 'from' positions must be > 1"
    @assert all(elements .< size) "All 'to' positions must be less than board size"
    
    # create a vector of Snake and Ladder structs
    scVect = map(sc -> sc[1] < sc[2] ? Ladder(sc[1], sc[2]) : Snake(sc[1], sc[2]), eachcol(elements))

    # return Board struct
    return Board(size, scVect)
end


# we need a player type to hold the player name and position
mutable struct Player
    name::String
    position::Vector{Int}
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
    round::Int
    Game(board, players, dice) = length(players) > 4 ? error("Four players max!") : new(board, players, dice, 1, false, 0)
end
