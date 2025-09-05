module SnakesAL


import StatsBase.sample
import StatsBase.Weights
# Write your package code here.


# need to make board of 100 (or variable size)

# need to make snakes and ladders

# need to implement moving rules

# need to implement dice

include("types.jl")
include("someFuns.jl")
include("examples.jl")

export makeDiceAndRoll, oneRound, testGame0, testGame2, NaMiBoard, Game, Board, Player, Dice,
 WeightedDice, Ladder, Snake, runToEnd!, roll, oneTurn!, oneRound!


end
