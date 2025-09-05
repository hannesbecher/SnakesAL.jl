# SnakesAL

[![Build Status](https://github.com/hannesbecher/SnakesAL.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/hannesbecher/SnakesAL.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Standalone works
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

## Nanda & Misra (2024) examples
Not exported, but available via:
```
SnakesAL.NM... where ... is any of the following:
NM0     NM10α
NM14G0  NM6U
NM7∆    NM8Ξ
```