using SnakesAL
using Test

@testset "SnakesAL.jl" begin
    # Write your tests here.
    @test SnakesAL.makeDiceAndRoll(6) > 0 
    @test SnakesAL.makeDiceAndRoll(6, [1,2,3,4,5,6]) > 0 
end
