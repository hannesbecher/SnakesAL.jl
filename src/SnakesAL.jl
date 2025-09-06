module SnakesAL
import StatsBase.mean
import StatsBase.sample
import StatsBase.Weights

import LinearAlgebra: I,inv
# Write your package code here.


# need to make board of 100 (or variable size)

# need to make snakes and ladders

# need to implement moving rules

# need to implement dice

include("types.jl")
include("someFuns.jl")
include("examples.jl")
include("Markov.jl")

export oneRound, testGame0, testGame2, NaMiBoard, Game, Board, Player, Dice,
 WeightedDice, Ladder, Snake, runToEnd!, roll, oneTurn!, oneRound!, runWithReps,
 getTransitionMatrix, getMarkovTransitionExpectation, getMarkovTransitionVariance


end
