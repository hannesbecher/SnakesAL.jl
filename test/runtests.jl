
# julia -e 'using Pkg; Pkg.activate("."); Pkg.test("SnakesAL")'

using SnakesAL
using Test

@testset "Dice" begin
    # Write your tests here.
    d6 = Dice(6)
    @test roll(d6) > 0 
    d6w = WeightedDice(6, [1,2,3,4,5,6])
    @test roll(d6w) > 0 
end


@testset "Boards" begin
    b = NaMiBoard(100, [3 17; 22 4])
    @test length(b.shortcuts) == 2
    @test b.size == 100
    @test_throws AssertionError NaMiBoard(100, [3 17; 3 4]) # same start
end


@testset "Games" begin
    g = testGame0()
    @test g.board.size == 100
    @test length(g.players) == 1
    @test g.dice.nSides == 6
    @test g.current_player_index == 1
    @test g.is_over == false
    @test g.round == 0
    g = oneTurn!(g, print=true)
    @test length(g.players[1].position) == 2
    g = oneRound!(g, print=true)
    @test length(g.players[1].position) == 3
    g = runToEnd!(g)
    @test g.is_over == true
end

@testset "Markov" begin
    b = SnakesAL.NM0
    d = Dice(6)
    P = getTransitionMatrix(b, d)
    @test size(P,1) == 100
    @test size(P,2) == 100
    @test isapprox(sum(P, dims=2), ones(100)) # rows sum to 1
    exp = getMarkovTransitionExpectation(b, d)
    @test isapprox(exp,28.76190476190474)
    var = getMarkovTransitionVariance(b, d)
    @test isapprox(var,6.848072562358311)
end

