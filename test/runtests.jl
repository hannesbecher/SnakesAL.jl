
# julia -e 'using Pkg; Pkg.activate("."); Pkg.test("SnakesAL")'

using SnakesAL
using Test

@testset "ShortCuts" begin
    s1 = Snake(17, 7)
    @test s1.from == 17
    @test s1.to == 7
    l1 = Ladder(3, 22)
    @test l1.from == 3
    @test l1.to == 22
    @test_throws ErrorException Snake(7,17) # snake must go down
    @test_throws ErrorException Snake(7,7) # snake must go down
    @test_throws ErrorException Ladder(22,3) # ladder must go up
    @test_throws ErrorException Ladder(22,22) # ladder must go up
end

@testset "Dice" begin
    # Write your tests here.
    d6 = Dice(6)
    @test roll(d6) > 0 
    d6w1 = WeightedDice(6, [1,2,3,4,5,6])
    d6w2 = WeightedDice(6, 1:6)
    d6w3 = WeightedDice([2,3,4,5,6,7], [1,2,3,4,5,6])
    d6w4 = WeightedDice([1,2,3,4,5,6], 1:6)
    d6w5 = WeightedDice(6:11, [1,2,3,4,5,6])
    d6w6 = WeightedDice(6:11, 1:6)
    @test roll(d6w1) > 0 
    @test roll(d6w2) > 0
    @test roll(d6w3) > 0
    @test roll(d6w4) > 0
    @test roll(d6w5) > 0
    @test roll(d6w6) > 0
    @test_throws ErrorException WeightedDice([1,2,3], [1,2]) # sides and weights length mismatch
end


@testset "Boards" begin
    b = NaMiBoard(100, [3 17; 22 4])
    @test length(b.shortcuts) == 2
    @test b.size == 100
    @test_throws AssertionError NaMiBoard(100, [3 17; 3 4]) # same start
    scs = [Ladder(10,20), Ladder(1,30), Ladder(3,80)]
    bb = Board(100, scs)
    @test all(bb.shortcuts .== [Ladder(1,30), Ladder(3,80), Ladder(10,20)]) # shortcuts are sorted by constructor of Board
    @test_throws ErrorException Board(100, [Ladder(10,20), Ladder(10,30), Ladder(3,80)]) # same start
    
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
    wd = WeightedDice(6, [1,2,3,4,5,6])
    P = getTransitionMatrix(b, d)
    @test size(P,1) == 100
    @test size(P,2) == 100
    @test isapprox(sum(P, dims=2), ones(100)) # rows sum to 1
    exp = getMarkovTransitionExpectation(b, d)
    @test isapprox(exp,28.76190476190474)
    var = getMarkovTransitionVariance(b, d)
    @test isapprox(var,6.848072562358311)
    expw = getMarkovTransitionExpectation(b, wd)
    @test isapprox(expw,23.289940828769044)
    varw = getMarkovTransitionVariance(b, wd)
    @test isapprox(varw,2.8022128013834617)
    gg = Game(b, [Player("Alice", [1])], d)
    @test isapprox(getMarkovTransitionExpectation(gg), exp)
    @test isapprox(getMarkovTransitionVariance(gg), var)
    gg2 = Game(b, [Player("Bob", [1])], wd)
    @test isapprox(getMarkovTransitionExpectation(gg2), expw)
    @test isapprox(getMarkovTransitionVariance(gg2), varw)
end

