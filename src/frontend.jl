

# Height of the screen
HEIGHT = 1000
# Width of the screen
WIDTH = 1000
# Global variables to store a range of colors. 
# The Colors package is always imported into a game



arr1 = TextActor("START", "moonhouse", font_size=24, color=[0,0,0,0]); arr1.pos = (50,950)
arr2 = TextActor("-->", "moonhouse", font_size=24, color=[0,0,0,0]); arr2.pos = (50,150)
arr3 = TextActor("<--", "moonhouse", font_size=24, color=[0,0,0,0]); arr3.pos = (950,250)
arr4 = TextActor("-->", "moonhouse", font_size=24, color=[0,0,0,0]); arr4.pos = (50,350)
arr5 = TextActor("<--", "moonhouse", font_size=24, color=[0,0,0,0]); arr5.pos = (950,450)
arr6 = TextActor("-->", "moonhouse", font_size=24, color=[0,0,0,0]); arr6.pos = (50,550)
arr7 = TextActor("<--", "moonhouse", font_size=24, color=[0,0,0,0]); arr7.pos = (950,650)
arr8 = TextActor("-->", "moonhouse", font_size=24, color=[0,0,0,0]); arr8.pos = (50,750)
arr9 = TextActor("<--", "moonhouse", font_size=24, color=[0,0,0,0]); arr9.pos = (950,850)
arr10 = TextActor("<--", "moonhouse", font_size=24, color=[0,0,0,0]); arr10.pos = (950,50)
arr11 = TextActor("GOAL", "moonhouse", font_size=24, color=[0,0,0,0]); arr11.pos = (50,50)
##############################################


# we need ladders and snakes that are nested in the same abstract type
abstract type ShortCut end

# a shortcut that makes players to move forward
struct Ladder <: ShortCut
    from::Int
    to::Int
end
# a shortcut that makes players to move backward
struct Snake <: ShortCut
    from::Int
    to ::Int
end
# we need a board type to hold the board size and the snakes and ladders
struct Board
    size::Int
    shortcuts::Vector{<:ShortCut}
    # think whether to have the players/list thereof as properties of the board
end
# we need a player type to hold the player name and position
mutable struct Player
    name::String
    position::Int
end

# an abstract type for dice
abstract type AbstractDice end

# we need a dice type to roll the dice
struct Dice <: AbstractDice
    nSides::Int
end

# an additional dice type with weighted sides
struct WeightedDice <: AbstractDice
    nSides::Int
    weights::Vector{<:Real}
end

# a function to roll the abstract dice
roll(dice::AbstractDice) = error("roll not implemented for $(typeof(dice))")    
roll(dice::Dice) = rand(1:dice.nSides)
roll(dice::WeightedDice) = sample(1:dice.nSides, Weights(dice.weights))

# we need a game type to hold the specs and state of a game
mutable struct SGame
    board::Board
    players::Vector{Player}
    dice::AbstractDice
    current_player_index::Int
    is_over::Bool
    SGame(board, players, dice) = length(players) > 4 ? error("Four players max!") : new(board, players, dice, 1, false)
end



# rewrite as multiple methods
function makeDiceAndRoll(nSides::Int)
    dice = Dice(nSides)
    return roll(dice)
end

#make sure this works for both integer and float weights
function makeDiceAndRoll(nSides::Int, weights::Vector{<:Real})
    @assert length(weights) == nSides "Length of weights must be equal to number of sides"
    @assert all(w -> w >= 0, weights) "All weights must be non-negative"
    @assert sum(weights) > 0 "Sum of weights must be positive"  
    ww = sum(weights)/nSides
    dice = WeightedDice(nSides, weights)
    return roll(dice)
end


# write out the field names of the Game struct below

testGame() = SGame(Board(100, [Ladder(3, 22), Snake(17, 4)]),
                    [Player("Alice", 1), Player("Bob", 1)],
                    Dice(6))


oneRound(g::SGame) = begin
    if g.is_over
        println("Game is already over.")
        return g
    end
    current_player = g.players[g.current_player_index]
    roll_value = roll(g.dice)
    println("Player $(current_player.name) rolled a $roll_value")
    new_position = current_player.position + roll_value
    if new_position > g.board.size
        new_position = g.board.size - (new_position - g.board.size) # bounce back if overshoot
        println("Player $(current_player.name) overshot and bounces back to $new_position")
    end
    # check for shortcuts
    for sc in g.board.shortcuts
        if sc.from == new_position
            println("Player $(current_player.name) hit a shortcut from $(sc.from) to $(sc.to)")
            new_position = sc.to
            break
        end
    end
    current_player.position = new_position
    println("Player $(current_player.name) moved to position $(current_player.position)")
    if current_player.position == g.board.size
        g.is_over = true
        println("Player $(current_player.name) wins!")
    end
    g.current_player_index = mod1(g.current_player_index + 1, length(g.players))
    return g
end

# convert position to table coordinates
posToTBT(pos::Int) = (((pos - 1) % 10 + 1) * 100 - 50, (10 - div(pos - 1, 10)) * 100 - 50)


# alternative pos to 10x10 with forth and back
posToTBT2(pos::Int) = begin
    row = div(pos - 1, 10)
    col = (pos - 1) % 10
    if isodd(row)
        col = 9 - col
    end
    return ((col + 1) * 100 - 50, (10 - row) * 100 - 50)
end

addJitter(x, y, pxMax=3) = (x + rand(-pxMax:pxMax), y + rand(-pxMax:pxMax))

##############################################






# gg = SGame(Board(100, [Ladder(3, 22), Snake(17, 4)]),
#                     [Player("Alice", 1), Player("Bob", 1)],
#                     Dice(6))
# 
gg = SGame(Board(100, [Ladder(3, 22),
                       Ladder(14, 24),
                       Ladder(36, 71),
                       Ladder(43, 58),
                       Ladder(64, 72),
                       Snake(17, 4),
                       Snake(81, 7),
                       Snake(56, 42),
                       Snake(35, 31),
                       Snake(17, 4)
                       ]
                ),
                    [Player("Pam", 1),
                    Player("John", 1),
                    Player("Gemma", 1),
                    Player("Carl", 1)
                    ],
                    Dice(6))




# function to draw a arrow, based on Line


# The draw function is called once per frame to render objects to the screen.
# In our game, we only define the `draw` function, it's called by the engine. 
# Within the function, we draw the individual elements, in this case line, rectangles and circles
function draw()

    global gg

    draw(arr1) #START
    draw(arr2)
    draw(arr3)
    draw(arr4)
    draw(arr5)
    draw(arr6)
    draw(arr7)
    draw(arr8)
    draw(arr9)
    draw(arr10)
    draw(arr11) # GOAL

    # the game grid, 100 field ATM, consider making adjustable
    for i in 1:9
        #l = Line(xpos1, ypos1, xpos2, ypos2)
        draw(Line(100i, 1, 100i, 1000), colorant"darkgrey") # vertical
        draw(Line(0, 100i, 1000, 100i), colorant"darkgrey") # horizontal
        if isodd(i)
            # Rect(xpos, ypos, width, height)
            draw(Rect(0, 100i - 1, 900, 3), colorant"black")
        else
            draw(Rect(100, 100i -1, 900, 3), colorant"black")
        end
    end

    # draw shortcuts from gg objects
    for shortcut in gg.board.shortcuts
        if shortcut isa Ladder
            draw(Line(posToTBT2(shortcut.from)..., posToTBT2(shortcut.to)...), colorant"green")
        elseif shortcut isa Snake
            draw(Line(posToTBT2(shortcut.from)..., posToTBT2(shortcut.to)...), colorant"red")
        end
    end

    # draw circles for players
    for (n,p) in enumerate(gg.players)
        draw(Circle(addJitter(posToTBT2(p.position)...)..., 20),
        [colorant"blue",colorant"orange",colorant"violet",colorant"yellow"][n],
         fill=true)
    end

end

# The update function is called once per frame by the game engine, and should be used
# to change the game state. In this case, we iterate through the color range, and store
# the current color in a global variable. The global value is then used in the `draw`
# function to render the screen background
function update(g::Game)
    #global current_color
    #global color_state
    global gg
    if g.keyboard.SPACE
        oneRound(gg)
        sleep(0.1) # to avoid multiple rounds per key press
    end
# do things like
    # update player
    # roll dice
    # move piece
    # check for shortcut and move again if applicable

end

