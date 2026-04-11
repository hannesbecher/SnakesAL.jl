using Tachikoma

const DEFAULT_TERMINAL_SHORTCUTS = ShortCut[
    Ladder(3, 22),
    Ladder(14, 24),
    Ladder(36, 71),
    Ladder(43, 58),
    Ladder(64, 72),
    Snake(17, 4),
    Snake(35, 31),
    Snake(56, 42),
    Snake(81, 7),
    Snake(95, 75),
]

const DEFAULT_TERMINAL_PLAYERS = ["Pam", "John", "Gemma", "Carl"]

default_terminal_game() = Game(
    Board(100, deepcopy(DEFAULT_TERMINAL_SHORTCUTS)),
    [Player(name, [1]) for name in DEFAULT_TERMINAL_PLAYERS],
    Dice(6),
)

mutable struct TerminalSnakesApp <: Tachikoma.Model
    quit::Bool
    prototype::Game
    game::Game
    message::String
    last_roll::Union{Nothing, Int}
    last_player_index::Int
    last_shortcut::Union{Nothing, ShortCut}
end

function TerminalSnakesApp(; prototype::Game=default_terminal_game())
    prototype.board.size == 100 || error("The terminal frontend currently supports 100-field boards only.")
    stored_prototype = deepcopy(prototype)
    return TerminalSnakesApp(
        false,
        stored_prototype,
        deepcopy(stored_prototype),
        "Press [space] or [enter] to roll the die.",
        nothing,
        0,
        nothing,
    )
end

Tachikoma.should_quit(m::TerminalSnakesApp) = m.quit

function reset_terminal_game!(m::TerminalSnakesApp)
    m.game = deepcopy(m.prototype)
    m.message = "Started a new game. Press [space] or [enter] to roll."
    m.last_roll = nothing
    m.last_player_index = 0
    m.last_shortcut = nothing
    return m
end

function shortcut_label(shortcut::ShortCut)
    kind = shortcut isa Ladder ? "ladder" : "snake"
    return "$(kind) $(shortcut.from) -> $(shortcut.to)"
end

function format_turn_message(summary::TurnSummary)
    pieces = ["$(summary.player_name) rolled $(summary.roll_value): $(summary.start_position) -> $(summary.landing_position)"]
    if !isnothing(summary.shortcut)
        action = summary.shortcut isa Ladder ? "climbed a ladder" : "slid down a snake"
        push!(pieces, "$(action) to $(summary.end_position)")
    end
    summary.won && push!(pieces, "and wins")
    return join(pieces, ", ") * "."
end

function play_terminal_turn!(m::TerminalSnakesApp)
    if m.game.is_over
        m.message = "Game over. Press [r] to restart."
        return m
    end

    summary = takeTurn!(m.game)
    m.last_roll = summary.roll_value
    m.last_player_index = summary.player_index
    m.last_shortcut = summary.shortcut
    m.message = format_turn_message(summary)
    return m
end

function Tachikoma.update!(m::TerminalSnakesApp, evt::Tachikoma.KeyEvent)
    evt.key == :escape && (m.quit = true)
    evt.key == :enter && (play_terminal_turn!(m); return)

    if evt.key == :char
        evt.char == 'q' && (m.quit = true)
        evt.char == ' ' && (play_terminal_turn!(m); return)
        lowercase(evt.char) == 'r' && (reset_terminal_game!(m); return)
    end
end

function wrap_text(text::AbstractString, width::Int, max_lines::Int)
    width = max(width, 1)
    max_lines = max(max_lines, 1)
    words = split(String(text))
    isempty(words) && return [""]

    lines = String[]
    current = ""
    for word in words
        candidate = isempty(current) ? word : current * " " * word
        if textwidth(candidate) <= width
            current = candidate
            continue
        end

        push!(lines, isempty(current) ? truncate_text(word, width) : current)
        length(lines) == max_lines && return truncate_lines(lines, width)
        current = textwidth(word) <= width ? word : truncate_text(word, width)
    end

    isempty(current) || push!(lines, current)
    return truncate_lines(lines, width, max_lines)
end

function truncate_lines(lines::Vector{String}, width::Int, max_lines::Int=length(lines))
    clipped = lines[1:min(length(lines), max_lines)]
    return map(clipped) do line
        textwidth(line) <= width ? line : truncate_text(line, width)
    end
end

function truncate_text(text::AbstractString, width::Int)
    width <= 0 && return ""
    return first(String(text), width)
end

function draw_text_lines!(buf, area::Tachikoma.Rect, lines::Vector{String}; style=Tachikoma.tstyle(:text))
    for (idx, line) in enumerate(lines)
        y = area.y + idx - 1
        y > Tachikoma.bottom(area) && break
        Tachikoma.set_string!(buf, area.x, y, truncate_text(line, area.width), style)
    end
end

function board_positions_for_row(row::Int)
    positions = collect(row * 10 + 1:row * 10 + 10)
    isodd(row) && reverse!(positions)
    return positions
end

function cell_marker(game::Game, pos::Int)
    occupants = [string(idx) for (idx, player) in enumerate(game.players) if player.position[end] == pos]
    if !isempty(occupants)
        return join(occupants, ""), Tachikoma.tstyle(:accent, bold=true)
    end

    for shortcut in game.board.shortcuts
        if shortcut.from == pos
            shortcut_style = shortcut isa Ladder ? Tachikoma.tstyle(:success, bold=true) : Tachikoma.tstyle(:error, bold=true)
            return shortcut isa Ladder ? "L" : "S", shortcut_style
        end
    end

    return ".", Tachikoma.tstyle(:text_dim, dim=true)
end

function number_style(game::Game, pos::Int)
    if pos == game.board.size
        return Tachikoma.tstyle(:success, bold=true)
    end
    active_index = game.is_over ? 0 : game.current_player_index
    if active_index > 0 && game.players[active_index].position[end] == pos
        return Tachikoma.tstyle(:warning, bold=true)
    end
    return Tachikoma.tstyle(:primary)
end

function draw_board!(buf, area::Tachikoma.Rect, game::Game)
    inner = Tachikoma.render(
        Tachikoma.Block(
            title="Board",
            border_style=Tachikoma.tstyle(:border),
            title_style=Tachikoma.tstyle(:title, bold=true),
        ),
        area,
        buf,
    )

    start_x = inner.x + max(0, (inner.width - 40) ÷ 2)
    for display_row in 0:9
        logical_row = 9 - display_row
        y_num = inner.y + display_row * 2
        y_mark = y_num + 1
        positions = board_positions_for_row(logical_row)

        for (cell_index, pos) in enumerate(positions)
            x = start_x + (cell_index - 1) * 4
            Tachikoma.set_string!(buf, x, y_num, lpad(string(pos), 4), number_style(game, pos))
            marker, marker_style = cell_marker(game, pos)
            Tachikoma.set_string!(buf, x, y_mark, lpad(marker, 4), marker_style)
        end
    end
end

function player_line(game::Game, player_index::Int)
    player = game.players[player_index]
    prefix = game.is_over ? " " : (player_index == game.current_player_index ? ">" : " ")
    name = rpad(player.name, 8)
    return "$(prefix) $(player_index). $(name) $(lpad(string(player.position[end]), 3))"
end

function draw_players_panel!(buf, area::Tachikoma.Rect, game::Game)
    inner = Tachikoma.render(
        Tachikoma.Block(
            title="Players",
            border_style=Tachikoma.tstyle(:border),
            title_style=Tachikoma.tstyle(:title, bold=true),
        ),
        area,
        buf,
    )

    leader = maximum(player.position[end] for player in game.players)
    winner = game.is_over ? only(filter(player -> player.position[end] == game.board.size, game.players)).name : "None"
    lines = [
        "Round: $(game.round)",
        game.is_over ? "Winner: $(winner)" : "Next: $(game.players[game.current_player_index].name)",
    ]
    append!(lines, [player_line(game, idx) for idx in eachindex(game.players)])
    draw_text_lines!(buf, Tachikoma.Rect(inner.x, inner.y, inner.width, max(1, inner.height - 1)), lines)

    gauge_y = Tachikoma.bottom(inner)
    gauge_y >= inner.y && Tachikoma.render(
        Tachikoma.Gauge(clamp(leader / game.board.size, 0, 1);
            filled_style=Tachikoma.tstyle(:success),
            empty_style=Tachikoma.tstyle(:text_dim, dim=true)),
        Tachikoma.Rect(inner.x, gauge_y, inner.width, 1),
        buf,
    )
end

function draw_last_turn_panel!(buf, area::Tachikoma.Rect, model::TerminalSnakesApp)
    inner = Tachikoma.render(
        Tachikoma.Block(
            title="Last Turn",
            border_style=Tachikoma.tstyle(:border),
            title_style=Tachikoma.tstyle(:title, bold=true),
        ),
        area,
        buf,
    )

    lines = String[]
    append!(lines, wrap_text(model.message, inner.width, max(1, inner.height - 2)))
    if !isnothing(model.last_roll)
        push!(lines, "Roll: $(model.last_roll)")
    end
    if !isnothing(model.last_shortcut)
        push!(lines, shortcut_label(model.last_shortcut))
    end

    draw_text_lines!(buf, inner, lines)
end

function draw_shortcuts_panel!(buf, area::Tachikoma.Rect, board::Board)
    inner = Tachikoma.render(
        Tachikoma.Block(
            title="Shortcuts",
            border_style=Tachikoma.tstyle(:border),
            title_style=Tachikoma.tstyle(:title, bold=true),
        ),
        area,
        buf,
    )

    lines = String["L = ladder, S = snake"]
    append!(lines, map(shortcut_label, board.shortcuts))
    draw_text_lines!(buf, inner, lines)
end

function Tachikoma.view(m::TerminalSnakesApp, f::Tachikoma.Frame)
    buf = f.buffer
    border_style = m.game.is_over ? Tachikoma.tstyle(:success) : Tachikoma.tstyle(:border)
    content = Tachikoma.render(
        Tachikoma.Block(
            title="SnakesAL Terminal",
            border_style=border_style,
            title_style=Tachikoma.tstyle(:title, bold=true),
        ),
        f.area,
        buf,
    )

    if content.width < 72 || content.height < 24
        warning = "Resize the terminal to at least 72x24."
        centered = Tachikoma.center(content, length(warning), 1)
        Tachikoma.set_string!(buf, centered.x, centered.y, warning, Tachikoma.tstyle(:warning, bold=true))
        return
    end

    rows = Tachikoma.split_layout(Tachikoma.Layout(Tachikoma.Vertical, [Tachikoma.Fill(), Tachikoma.Fixed(1)]), content)
    cols = Tachikoma.split_layout(Tachikoma.Layout(Tachikoma.Horizontal, [Tachikoma.Fixed(46), Tachikoma.Fill()]), rows[1])
    side_rows = Tachikoma.split_layout(
        Tachikoma.Layout(Tachikoma.Vertical, [Tachikoma.Fixed(8), Tachikoma.Fixed(7), Tachikoma.Fill()]),
        cols[2],
    )

    draw_board!(buf, cols[1], m.game)
    draw_players_panel!(buf, side_rows[1], m.game)
    draw_last_turn_panel!(buf, side_rows[2], m)
    draw_shortcuts_panel!(buf, side_rows[3], m.game.board)

    Tachikoma.render(
        Tachikoma.StatusBar(
            left=[
                Tachikoma.Span("  [space]/[enter] roll  ", Tachikoma.tstyle(:accent)),
                Tachikoma.Span("[r] restart  ", Tachikoma.tstyle(:success)),
            ],
            right=[Tachikoma.Span("[q] quit ", Tachikoma.tstyle(:text_dim))],
        ),
        rows[2],
        buf,
    )
end

"""
    run_terminal_frontend(; game=default_terminal_game(), fps=20)

Launch the Tachikoma-based terminal frontend for a Snakes and Ladders game.
"""
function run_terminal_frontend(; game::Game=default_terminal_game(), fps::Int=20)
    return Tachikoma.app(TerminalSnakesApp(prototype=game); fps=fps)
end
