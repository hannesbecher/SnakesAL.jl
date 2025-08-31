 # Height of the screen
HEIGHT = 1000
# Width of the screen
WIDTH = 1000
# Global variables to store a range of colors. 
# The Colors package is always imported into a game

px=500
py=500
offset = 200

# The draw function is called once per frame to render objects to the screen.
# In our game, we only define the `draw` function, it's called by the engine. 
# Within the function, we draw the individual elements, in this case line, rectangles and circles
function draw()

    global px
    global py
    global offset
    for i in 1:9
        #l = Line(xpos1, ypos1, xpos2, ypos2)
        draw(Line(100i, 1, 100i, 1000), colorant"darkgrey")
        draw(Line(0, 100i, 1000, 100i), colorant"darkgrey")

        draw(Circle(px+offset, py+offset, 20), colorant"red", fill=true)
    end

end

# The update function is called once per frame by the game engine, and should be used
# to change the game state. In this case, we iterate through the color range, and store
# the current color in a global variable. The global value is then used in the `draw`
# function to render the screen background
function update()
    #global current_color
    #global color_state

# do things like
    # update player
    # roll dice
    # move piece
    # check for shortcut and move again if applicable

end


function changeOffsetSign()
    global offset
    offset = -offset
end

# If the "space" key is pressed, the sign of offste changes
function on_key_down(g, k)
    global offset
    if k == Keys.SPACE
        changeOffsetSign()
        schedule_once(changeOffsetSign, 1)
    end
end
