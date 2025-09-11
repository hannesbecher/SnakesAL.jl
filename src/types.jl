
# we need a game type to hold the specs and state of a game


# we need ladders and snakes that are nested in the same abstract type
abstract type ShortCut end

# a shortcut that makes players to move forward
struct Ladder <: ShortCut
	from::Int
	to::Int
	Ladder(from, to) = from >= to ? error("Ladder must go up!") : new(from, to)
end
# a shortcut that makes players to move backward
struct Snake <: ShortCut
	from::Int
	to::Int
	Snake(from, to) = from <= to ? error("Snake must go down!") : new(from, to)
end

"""
	constructShortcut(from::Int, to::Int)

Make the correct type depending on direction of shortcut.
"""
function constructShortcut(from::Int, to::Int)
	@assert from != to "Each shortcut must start and end on a different field. Multi shortcut loop present?"
	return from < to ? Ladder(from, to) : Snake(from, to)
end



function checkUniqueShortcutFroms(shortcuts::Vector{<:ShortCut})
	if length(unique(map(sc -> sc.from, shortcuts))) != length(shortcuts)
		error("Each shortcut 'from' position must be unique!")
	end
	return true
end

sortShortcuts!(shortcuts::Vector{<:ShortCut}) = sort!(shortcuts, by = sc -> sc.from)


"""
	delinkHeadToTail(s1::ShortCut, s2::ShortCut)

Takes two shortcuts `s1` and `s2` where the `to` field of `s1` is the same as the `from` field of `s2`.
Returns a new shortcut to replace `s1` so that it goes from the `from` field of `s1` to the `to` field of `s2`.
"""
function delinkHeadToTail(s1::ShortCut, s2::ShortCut)
	return constructShortcut(s1.from, s2.to)
end


function delinkAllHeadToTailPairs!(shortcuts::Vector{<:ShortCut})
	@label before_loop
	for i in 1:length(shortcuts)
		for j in 1:length(shortcuts)
			if j!=i && shortcuts[i].to == shortcuts[j].from
				shortcuts[i] = delinkHeadToTail(shortcuts[i], shortcuts[j])
				@goto before_loop
			end
		end
	end
	return shortcuts
end	

"""
	checkAndConditionShortcuts!(shortcuts::Vector{<:ShortCut})

Used in `Board` constructor, makes sure that there are no infinite loops,
that each shortcut `from` position is unique, that all head-to-tail pairs
are delinked and that the shortcuts are sorted by their 'from' position.
"""
function checkAndConditionShortcuts!(shortcuts::Vector{<:ShortCut})
	checkUniqueShortcutFroms(shortcuts)
	delinkAllHeadToTailPairs!(shortcuts)
	return sortShortcuts!(shortcuts)
end

# function needed to delink head to tail shortcuts into to with the same end field as Nanda and Misra do

# a board type to hold the board size and the snakes and ladders
# add constructor that makes sure that each shortcut starting field can only be used once
mutable struct Board
	size::Int
	shortcuts::Vector{<:ShortCut}
	Board(size, shortcuts) = new(size, checkAndConditionShortcuts!(shortcuts))
end


"""
	NaMiBoard(size::Int, elements::AbstractArray{Int,2})

Create a standard board of given size with snakes and ladders defined by the 2-row matrix `elements` as by Nanda and Misra (2024). The first row contains the starting points of the shortcuts, the second row the end points. Ladders go from lower to higher numbers, snakes from higher to lower numbers. The starting points must be in strictly monotonic increasing order.
"""
function NaMiBoard(size::Int, elements::AbstractArray{Int, 2})
	# check the input is correct
	@assert all(diff(elements[1, :]) .>= 1) "Starting point must be in strictly monotonic increasing order"
	@assert all(elements[1, :] .!= elements[2, :]) "A shortcut must start and end on different fields"
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


"""
	WeightedDice(nSides::Int, sides::Vector{Int}, weights::Vector{<:Real})

An additional dice type with weighted sides. The `weights` may also be given as a
`UnitRange`. The sides need not be consecutive integers.
"""
struct WeightedDice <: AbstractDice
	"Number of sides"
	nSides::Int
	sides::Vector{Int} # could be any set of integers, not just 1:nSides
	"Weights for each side"
	weights::Vector{<:Real}

end

# constructor to create a weighted dice from a range of weights




WeightedDice(sides::Int, weights::Vector{<:Real}) = WeightedDice(sides, 1:sides, weights/sum(weights))
WeightedDice(sides::Int, weights::UnitRange{<:Real}) = WeightedDice(sides, 1:sides, collect(weights)/sum(collect(weights)))
"""
	WeightedDice(sides::Vector{Int}, weights::Vector{<:Real})   

Several additional methods for WeightedDice allow for more flexible construction. The sides
and weights must have the same length. The `sides` or `weights` may also be given as
`UnitRange`s. The `sides` may also be one single `Int` as in `Dice`.
"""
WeightedDice(sides::Vector{Int}, weights::Vector{<:Real}) = length(sides) == length(weights) ? WeightedDice(length(sides), sides, weights/sum(weights)) : error("Sides and weights must have the same length")
WeightedDice(sides::Vector{Int}, weights::UnitRange{<:Real}) = WeightedDice(sides, collect(weights)/sum(collect(weights)))
WeightedDice(sides::UnitRange{<:Int}, weights::Vector{<:Real}) = WeightedDice(collect(sides), weights/sum(weights))
WeightedDice(sides::UnitRange{<:Int}, weights::UnitRange{<:Real}) = WeightedDice(collect(sides), collect(weights)/sum(collect(weights)))


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

function Base.show(io::IO, ::MIME"text/plain", g::Game)
	println(
		io,
		"""SnakesAL Game
			 board size = $(g.board.size)
			 nPlayers = $(length(g.players))
		   $(join(map(p -> "    Player: $(p.name), position: $(p.position[end])", g.players), "\n"))
			 current_player = \"$(g.players[g.current_player_index].name)\"
			 dice = $(typeof(g.dice)) with $(g.dice.nSides) sides$(if typeof(g.dice) == WeightedDice "\n    sides = $(g.dice.sides)\n    weights = $(g.dice.weights)" else "" end )
			 is_over = $(g.is_over)
			 round = $(g.round)
		   """,
	)
end

# show function for weighted dice that rounds the weights to 3 digits
function Base.show(io::IO, ::MIME"text/plain", wd::WeightedDice)
	println(io, "WeightedDice with $(wd.nSides) sides")
	println(io, "    sides = $(wd.sides)")
	println(io, "    weights = $(round.(wd.weights, digits=3))")
end
