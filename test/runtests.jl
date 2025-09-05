using SnakesAL
using Test

@testset "Dice" begin
    # Write your tests here.
    @test makeDiceAndRoll(6) > 0 
    @test makeDiceAndRoll(6, [1,2,3,4,5,6]) > 0 
end


@testset "Boards" begin
    b = NaMiBoard(100, [3 17; 22 4])
    @test length(b.shortcuts) == 2
    @test b.size == 100
    @test_throws AssertionError NaMiBoard(100, [3 17; 3 4]) # same start
end

