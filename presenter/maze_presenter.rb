require 'gosu'
require_relative '../helper/maze_helper'
require_relative 'game_over_presenter'
require_relative '../business_logic/depth_first_algorithm'
require_relative '../business_logic/iterative_division_algorithm'
require_relative '../model/player_movement_direction'

module GameState
  CREATING_MAZE, GAME_STARTED = *0..1
end

# Constructor function for the maze presenter.
def setup_maze_presenter(algorithm, state)
  state[:current_grid_length] = INITIAL_MAZE_GRID_LENGTH
  state[:remaining_time] = TIME_LIMIT
  state[:algorithm] = algorithm
  state[:needs_reset] = true
  state[:footsteps] = []
  state[:level_record] = []
  state[:algorithm_state] = {}
  state[:pop_sound] = Gosu::Sample.new('assets/music/pop.ogg')
  state[:warning_sound] = Gosu::Sample.new('assets/music/warning.ogg')
end


# Graphical work must be done here.
# @param [GameWindow] window Gosu Window that handles the draw to the screen
# @param [Hash] state State of the presenter.
def draw_maze_presenter(window, state)
  grid = state[:grid]
  game_state = state[:game_state]
  player = state[:player]
  remaining_time = state[:remaining_time]

  grid.each do |grid_row|
    grid_row.each do |cell|
      next unless game_state == GameState::CREATING_MAZE || player_near_cell?(player, cell, VISIBLE_ZONE)

      # Only draws the cell if the game is not running (i.e. maze is being created or game finished)
      # or if the cell is close to the player
      draw_cell(window, cell, cell == player, grid.length)
    end
  end
  cell_width = window.width / grid.length

  scanner_rect = if state[:algorithm] == MazeAlgorithm::DEPTH_FIRST
                   depth_first_scanner_rect(cell_width, state[:algorithm_state])
                 else
                   iterative_division_scanner_rect(cell_width, state[:algorithm_state])
                 end
  if game_state == GameState::CREATING_MAZE
    window.draw_rect(scanner_rect.x_pos,
                     scanner_rect.y_pos,
                     scanner_rect.width,
                     scanner_rect.height,
                     Gosu::Color.argb(SCANNER_COLOR))
  end

  Gosu::Font.new(20).draw_text(remaining_time.floor,
                               window.width - 30,                     # draw x
                               5,                                     # draw Y
                               1,                                     # draw Z
                               1,                                     # scale x
                               1,                                     # scale y
                               Gosu::Color.argb(LIGHT_GREEN_COLOR))
end

# Calculation work must be done here.
# @param [GameWindow] window Gosu window that called the update
# @param [Hash] state State of the presenter.
def update_maze_presenter(window, state)

  if state[:needs_reset]
    reset_grid(state)
    state[:needs_reset] = false
  end

  grid = state[:grid]
  player = state[:player]

  step_through_maze_generator(grid, state)

  state[:game_state] = GameState::GAME_STARTED if state[:algorithm_state][:generation_complete]

  update_remaining_time(window, state)

  last_row = grid[grid.length - 1]
  last_cell = last_row[last_row.length - 1]
  level_maze_up(window, state) if player == last_cell
end

# decrements the countdown while playing a warning music if the remaining time is below 10seconds.
# Game will be set to game over if the timer reaches zero.
# @param [GameWindow] window Gosu window that called the update
# @param [Hash] state State of the presenter.
def update_remaining_time(window, state)
  state[:remaining_time] -= window.update_interval / 1000 if state[:game_state] == GameState::GAME_STARTED
  remaining_time = state[:remaining_time]
  return if remaining_time > 10

  state[:warning_sound].play if (Gosu.milliseconds / 100 % 10).zero?
  return if remaining_time.positive?

  level_record = state[:level_record]
  level_record.push([state[:grid], state[:footsteps]])
  navigate_to(window, Presenter::GAME_OVER_PRESENTER, { player_level_record: level_record, win: false })

end

# chooses the appropriate algorithm and steps through it.
# @param [Array] grid A 2D array depicting the maze
# @param [Hash] state State of the presenter.
def step_through_maze_generator(grid, state)
  case state[:algorithm]
  when MazeAlgorithm::DEPTH_FIRST
    step_through_depth_first_maze_generator(grid, state[:algorithm_state])
  when MazeAlgorithm::ITERATIVE_DIVISION
    step_through_iterative_division_maze_generator(grid, state[:algorithm_state])
  end
end

# @param [GameWindow] window Gosu window that is being viewed on the screen.
# @param [Hash] state State of the presenter.
def level_maze_up(window, state)
  state[:level_record].push([state[:grid], state[:footsteps]])
  state[:current_grid_length] += MAZE_GRID_INCREMENT_SIZE
  navigate_to(window, Presenter::GAME_OVER_PRESENTER, {player_level_record: state[:level_record], win: true}) if state[:current_grid_length] >= GAME_WIN_LIMIT
  state[:remaining_time] += LEVEL_UP_TIME_BOOST
  state[:needs_reset] = true
end

# @param [Hash] state State of the presenter.
def reset_grid(state)
  initial_walls = state[:algorithm] == MazeAlgorithm::DEPTH_FIRST
  state[:algorithm_state].clear
  case state[:algorithm]
  when MazeAlgorithm::DEPTH_FIRST
    setup_depth_first_algorithm_state(state[:algorithm_state])
  when MazeAlgorithm::ITERATIVE_DIVISION
    setup_iterative_division_algorithm_state(state[:current_grid_length], state[:algorithm_state])
  end

  state[:grid] = create_cell_grid(state[:current_grid_length], initial_walls)
  state[:footsteps] = []
  state[:game_state] = GameState::CREATING_MAZE
  state[:player] = state[:grid][0][0]
end

# @param [Integer] id Gosu button id
# @param [Hash] state State of the presenter.
def button_down_maze_presenter(id, state)
  return unless state[:game_state] == GameState::GAME_STARTED

  grid = state[:grid]
  player = state[:player]
  case id
  when Gosu::KbUp
    move_maze_player(PlayerMovementDirection::UP, grid, player, state)
  when Gosu::KbDown
    move_maze_player(PlayerMovementDirection::DOWN, grid, player, state)
  when Gosu::KbRight
    move_maze_player(PlayerMovementDirection::RIGHT, grid, player, state)
  when Gosu::KbLeft
    move_maze_player(PlayerMovementDirection::LEFT, grid, player, state)
  end
end

# @param [PlayerMovementDirection] direction The direction the player wants to move.
# @param [Array] grid A n x n Array of the maze.
# @param [Cell] player Location of the player
# @param [Hash] state State of the presenter.
def move_maze_player(direction, grid, player, state)
  next_tile = nil
  case direction
  when PlayerMovementDirection::UP
    next_tile = move_player_up(grid, player)
  when PlayerMovementDirection::DOWN
    next_tile = move_player_down(grid, player)
  when PlayerMovementDirection::RIGHT
    next_tile = move_player_right(grid, player)
  when PlayerMovementDirection::LEFT
    next_tile = move_player_left(grid, player)
  end
  return if next_tile.nil?

  state[:pop_sound].play
  state[:player] = next_tile
  state[:footsteps].push(direction)
end

# @param [Integer] grid_length Number of rows and columns of the grid.
# @param [Boolean] visible_walls Are all walls initially visible or hidden.
# @return [Array] Grid of populated cells
def create_cell_grid(grid_length, visible_walls)
  grid = []
  (0..grid_length - 1).each do |row_index|
    grid_row = []
    (0..grid_length - 1).each do |col_index|
      cell = Cell.new(col_index, row_index, visible_walls)
      grid_row.push(cell)
    end
    grid.push(grid_row)
  end
  return grid
end

# @param [Cell] player Cell player is harbouring
# @param [Cell] cell Cell being tested
# @param [Integer] proximity
# @return [Boolean] is cell near the player
def player_near_cell?(player, cell, proximity)
  return (player.grid_x - cell.grid_x).abs < proximity && (player.grid_y - cell.grid_y).abs < proximity
end