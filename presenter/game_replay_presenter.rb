# frozen_string_literal: true

require_relative '../helper/maze_helper'
require_relative '../model/player_movement_direction'
require_relative '../game_constants'

# constructor function for Game Replay Presenter.
# @param [Array] player_record Information on the grid of each level and how the user navigated it.
# @param [Hash] state State of the presenter.
def setup_game_replay_presenter(player_record, state)
  state[:player_record] = player_record
  state[:level] = 0
  state[:player_movement_index] = 0
  state[:player] = player_record[0][0][0][0]
end

# Graphical work must be done here.
# @param [GameWindow] window Gosu Window that handles the draw on the screen.
# @param [Hash] state State of the presenter.
def draw_game_replay_presenter(window, state)
  state[:player_record][state[:level]][0].each do |grid_row|
    grid_row.each do |cell|
      draw_cell(window, cell, cell == state[:player], grid_row.length)
    end
  end

  instructions = 'Press Space to navigate back. Use ← → keys to go back and forth levels.'
  instructions_font = Gosu::Font.new(18, options={italic: true})
  instructions_width = instructions_font.text_width(instructions)
  instructions_font.draw_text(instructions, (window.width - instructions_width) / 2, 10, 1, 1, 1, Gosu::Color.argb(LIGHT_GREEN_COLOR))
 end


# Calculation work must be done here.
# Reruns the actions of the user.
# @param [Hash] state State of the presenter.
def update_game_replay_presenter(state)
  sleep(0.1)
  next_player = move_replay_player(state[:player_record][state[:level]], state[:player], state[:player_movement_index])
  if next_player.nil?
    state[:replay_finished] = !level_up(state)
  else
    state[:player] = next_player
    state[:player_movement_index] += 1
  end
end

# method each presenter must implement.
# @param [Integer] id Gosu button id
# @param [GameWindow] window Gosu window that passed the user input.
# @param [Hash] state State of the presenter.
def button_down_game_replay_presenter(id, window, state)
  if id == Gosu::KbSpace
   navigate_back(window) if id == Gosu::KbSpace
  end
  level_up(state) if id == Gosu::KbRight
  level_down(state) if id == Gosu::KbLeft
end

# @param [Array] current_level_info A two element array containing the maze grid and the
# movements of the user, respectively.
# @param [Cell] player Current player location
# @param [Integer] current_movement_index Index of the movement in the current_level_info movement array.
# @return [Cell] The next cell the player should be moved to. Nil if the player did not move after this point
# (usually level ended.)
def move_replay_player(current_level_info, player, current_movement_index)
  return if current_level_info[1].length == current_movement_index

  next_move_direction = current_level_info[1][current_movement_index]
  case next_move_direction
  when PlayerMovementDirection::UP
    next_tile = move_player_up(current_level_info[0], player)
  when PlayerMovementDirection::DOWN
    next_tile = move_player_down(current_level_info[0], player)
  when PlayerMovementDirection::RIGHT
    next_tile = move_player_right(current_level_info[0], player)
  when PlayerMovementDirection::LEFT
    next_tile = move_player_left(current_level_info[0], player)
  end
  return next_tile

end

# Resets the view and steps up the level index to replay the next level's movement
# @param [Hash] state State of the presenter.
# @return [Boolean] Success of increment. Returns false if there is no higher level.
def level_up(state)
  return false if state[:level] == state[:player_record].length - 1

  state[:player_movement_index] = 0
  state[:level] += 1
  state[:player] = state[:player_record][state[:level]][0][0][0]
  return true
end

# Resets the view and steps down the level index to replay the prev level's movement or replays the current
# @param [Hash] state State of the presenter.
# level if there is no lower level.
def level_down(state)
  state[:replay_finished] = false
  state[:player_movement_index] = 0
  state[:level] -= 1 unless state[:level].zero?
  state[:player] = state[:player_record][state[:level]][0][0][0]
end
