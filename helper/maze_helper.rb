# frozen_string_literal: true

require 'gosu'
# draws the cell and its status (harbouring player or goal position) onto the screen.
# @param [Gosu::Window] window Screen where the cell need to be drawn.
# @param [Cell] cell Cell that needs to be drawn.
# @param [Boolean] is_player Does this cell harbour the player.
# @param [Integer] grid_length Number of cols and rows in the maze.
def draw_cell(window, cell, is_player, grid_length)
  cell_width = window.width / grid_length
  cell_draw_x = cell.grid_x * cell_width
  cell_draw_y = cell.grid_y * cell_width


  window.draw_rect(cell_draw_x, cell_draw_y, cell_width, cell_width, Gosu::Color.argb(DARK_GRAY_COLOR)) if cell.show_base_background

  if cell.grid_y == grid_length - 1 && cell.grid_x == grid_length - 1
    window.draw_rect(cell_draw_x + PLATFORM_MARGIN,
                     cell_draw_y + PLATFORM_MARGIN,
                     cell_width - + PLATFORM_MARGIN * 2,
                     cell_width - PLATFORM_MARGIN * 2,
                     Gosu::Color.argb(LIGHT_GREEN_COLOR))
  end

  if is_player
    window.draw_rect(cell_draw_x + PLAYER_MARGIN,
                     cell_draw_y + PLAYER_MARGIN,
                     cell_width - PLAYER_MARGIN * 2,
                     cell_width - PLAYER_MARGIN * 2,
                     Gosu::Color.argb(PLAYER_COLOR))
  end

  draw_cell_walls(window, cell, cell_width, MAZE_WALL_THICKNESS, Gosu::Color.argb(LIGHT_GRAY_COLOR))

end

# @param [GameWindow] window Gosu game window
# @param [Cell] cell Cell whose walls need to be drawn
# @param [Integer] cell_width Width of each cell in pixels
def draw_cell_walls(window, cell, cell_width, wall_thickness, wall_color)
  cell_draw_x = cell.grid_x * cell_width
  cell_draw_y = cell.grid_y * cell_width

  window.draw_rect(cell_draw_x, cell_draw_y - wall_thickness / 2, cell_width, wall_thickness, wall_color) if cell.top_wall
  window.draw_rect(cell_draw_x + cell_width - wall_thickness / 2, cell_draw_y, wall_thickness, cell_width, wall_color) if cell.right_wall
  window.draw_rect(cell_draw_x, cell_draw_y + cell_width - wall_thickness / 2, cell_width, wall_thickness, wall_color) if cell.bottom_wall
  window.draw_rect(cell_draw_x - wall_thickness / 2, cell_draw_y, wall_thickness, cell_width, wall_color) if cell.left_wall
end

# Moves the player up a cell if possible.
# @param [Array] grid An n x n Array of cell (maze)
# @param [Cell] player Current player location.
# @return [Cell] New position of the player. Nil is move unsuccessful
def move_player_up(grid, player)
  return if player.grid_y.zero?
  return if player.top_wall

  return grid[player.grid_y - 1][player.grid_x]
end

# Moves the player right a cell if possible.
# @param [Array] grid An n x n Array of cell (maze)
# @param [Cell] player Current player location.
# @return [Cell] New position of the player. Nil is move unsuccessful
def move_player_right(grid, player)
  return if player.grid_x == grid[player.grid_y].length - 1
  return if player.right_wall

  return grid[player.grid_y][player.grid_x + 1]
end

# Moves the player down a cell if possible.
# @param [Array] grid An n x n Array of cell (maze)
# @param [Cell] player Current player location.
# @return [Cell] New position of the player. Nil is move unsuccessful
def move_player_down(grid, player)
  return if player.grid_y == grid.length - 1
  return if player.bottom_wall

  return grid[player.grid_y + 1][player.grid_x]
end

# Moves the player left a cell if possible.
# @param [Array] grid An n x n Array of cell (maze)
# @param [Cell] player Current player location.
# @return [Cell] New position of the player. Nil is move unsuccessful
def move_player_left(grid, player)
  return if player.grid_x.zero?
  return if player.left_wall

  return grid[player.grid_y][player.grid_x - 1]
end