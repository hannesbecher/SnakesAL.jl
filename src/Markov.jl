

# Only defined for unweighted dice, see below
getTransitionMatrix(board::Board, dice::AbstractDice) = error("getTransitionMatrix not implemented for $(typeof(dice))")

"""
    getTransitionMatrix(board::Board, dice::AbstractDice)

Compute the transition matrix for the given board and dice.
"""
function getTransitionMatrix(board::Board, dice::Dice)
    n = board.size
    P = zeros(n, n) # transition matrix
    # TODO: instead of looping over all fields, start with list [1] and add visitables states
    # TODO: also keep track of already visited states to avoid infinite loops
    for i in 1:n
        # only run if i is not a shortcut start otherwise prob to stay is 0
        if any(sc -> sc.from == i, board.shortcuts)
            continue
        end 
        for roll_value in 1:dice.nSides

            j = i + roll_value
            if j > n
                j = n # stop at end, dont bounce or overshoot
                #j = n - (j - n) # bounce back if overshoot
            end
            # check for shortcuts
            for sc in board.shortcuts
                if sc.from == j
                    j = sc.to
                    break
                end
            end
            P[i, j] += 1 / dice.nSides
        end
    end
    return P
end 

# TODO: change as method above
function getTransitionMatrix(board::Board, dice::WeightedDice)
    n = board.size
    P = zeros(n, n) # transition matrix
    for i in 1:n
        # only run if i is not a shortcut start otherwise prob to stay is 0
        if any(sc -> sc.from == i, board.shortcuts)
            continue
        end 
        for (roll_value, weight) in zip(dice.sides, dice.weights)

            j = i + roll_value
            if j > n
                j = n # stop at end, dont bounce or overshoot
                #j = n - (j - n) # bounce back if overshoot
            end
            # check for shortcuts
            for sc in board.shortcuts
                if sc.from == j
                    j = sc.to
                    break
                end
            end
            P[i, j] += weight
        end
    end
    return P
end

function removeZeroFields(P)
    states = 1:size(P, 1)
    non0cols = map(x -> sum(x)!=0, eachcol(P))
    non0rows = map(x -> sum(x)!=0, eachrow(P))
    tokeep = non0cols .| non0rows
    return states[tokeep], P[tokeep, tokeep]
end


"""
    getMarkovTransitionExpectation(board::Board, dice::AbstractDice)

Compute the expected number of steps to reach the end of the board using Markov chain analysis.
"""
function getMarkovTransitionExpectation(board::Board, dice::AbstractDice)
    P = getTransitionMatrix(board, dice)
    # remove states that are not reachable (e.g. the starting fields of shortcuts)
    _, P = removeZeroFields(P)


    # now the last state is the absorbing state (the end)
    n = size(P, 1)
    Q = P[1:end-1, 1:end-1] # transient states
    I_Q = inv(I(n-1) - Q)

    return sum(I_Q[1,:])
end

"""
    getMarkovTransitionExpectation(gg::Game)
"""
getMarkovTransitionExpectation(gg::Game) = getMarkovTransitionExpectation(gg.board, gg.dice)


"""
    getMarkovTransitionVariance(board::Board, dice::AbstractDice)

Compute the variance of the number of steps to reach the end of the board using Markov chain analysis.
"""
function getMarkovTransitionVariance(board::Board, dice::AbstractDice)
    # analogous to the Expectation function above
    P = getTransitionMatrix(board, dice)
    _, P = removeZeroFields(P)

    n = size(P, 1)
    Q = P[1:end-1, 1:end-1] # transient states
    I_Q = inv(I(n-1) - Q)

    ones_vec = ones(n-1)
    e = I_Q * ones_vec
    v = (2 * I_Q - I(n-1)) * e - e.^2

    return v[1]
end
"""
    getMarkovTransitionVariance(gg::Game)
"""
getMarkovTransitionVariance(gg::Game) = getMarkovTransitionVariance(gg.board, gg.dice)