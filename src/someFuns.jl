
# rewrite as multiple methods
function makeDiceAndRoll(sides::Int)
    dice = Dice(sides)
    return roll(dice)
end

#make sure this works for both integer and float weights
function makeDiceAndRoll(sides::Int, weights::Vector{<:Real})
    @assert length(weights) == sides "Length of weights must be equal to number of sides"
    @assert all(w -> w >= 0, weights) "All weights must be non-negative"
    @assert sum(weights) > 0 "Sum of weights must be positive"  
    ww = sum(weights)/sides
    dice = WeightedDice(sides, weights)
    return roll(dice)
end