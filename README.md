# SnakesAL

[![Build Status](https://github.com/hannesbecher/SnakesAL.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/hannesbecher/SnakesAL.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Core rules
The board has 100 fields. Players start on field 1. Whenever somebody's roll takes them to 100 or further, they land on 100, win, and the game is over.

## Run a simple game
```
# cd into repo directory
# then, in Julia:
using Pkg;Pkg.activate(".")
import SnakesAL

# Set up a Game by specifying a Board, vector of Players, and Dice
gg = Game(SnakesAL.NM0,           # a predifined board, 100 fields, no shortcuts
          [Player("April", [1])], # one player with name and starting field
          Dice(6))                # an ordinary "d6"
runToEnd!(gg); # roll dice and move until we hit field 100

# How many rounds did it take?
gg.round
# Retrace a  player's path
gg.players[1].position
```

## Analyse game length and variance
Using Markov chain theory:
```
myBoard = SnakesAL.NM0 # again, the boring board no shortcuts
getMarkovTransitionExpectation(myBoard, Dice(6)) # dependes on type of dice
getMarkovTransitionVariance(myBoard, Dice(6))
```

Using simulations
```
import StatsBase: mean, var
map(x-> runToEnd!(Game(myBoard, [Player("Bob", [1])], Dice(6))).round, 1:100000) |> mean
map(x-> runToEnd!(Game(myBoard, [Player("Bob", [1])], Dice(6))).round, 1:100000) |> var
# Should be very similar to theoretical values above.
```

## Retaining the entire game object
Check out the function `runWithReps`

## Nanda & Misra (2024) examples
Not exported, but available via:
```
SnakesAL.<...> where <...> is any of the following:
NM0     NM10α
NM14G0  NM6U
NM7∆    NM8Ξ
```

## Standalone works
But useses slightly different rules ATM.

```
# cd into the project directory
using Pkg
Pkg.activate(".")
Pkg.instantiate()
using GameZero
rungame("src/frontend.jl")
# Hit SPACE to roll the die.
```
![Game board for Snakes and Ladders with colored circles representing player pieces, diagonal lines indicating snakes and ladders, and grid lines forming the board layout; arrows and text labels are present along the left side, creating a playful and interactive atmosphere](img/snakes.png)

