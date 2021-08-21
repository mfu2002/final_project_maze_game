# frozen_string_literal: true

require_relative '../model/rect'



# @param [Hash] state Stores presenter state
def setup_depth_first_algorithm_state(state)
  state[:cell_stack] = []
  state[:generation_complete] = false
  state[:step_through_maze_generation]
end

# Runs an iteration of the algorithm.
# @param [Array] grid A n x n grid of cells for the maze
# @param [Hash] state Stores the state of the algorithm.
def step_through_depth_first_maze_generator(grid, state)
  state[:current] = grid[0][0] if state[:current].nil?
  current_cell = state[:current]
  current_cell.show_base_background = true
  next_cell = not_visited_cell_neighbour(grid, current_cell)
  if next_cell
    state[:cell_stack].push(current_cell)
    remove_walls_between_cells(current_cell, next_cell)
    state[:current] = next_cell
  elsif !state[:cell_stack].empty?
    state[:current] = state[:cell_stack].pop()
  elsif !state[:generation_complete]
    state[:generation_complete] = true
  end
end


  
# @param [Integer] cell_width Length in pixels of each column and row in the grid.
# @param [Hash] state Stores the state of the algorithm.
# @return A rect of area it is currently processing.
def depth_first_scanner_rect(cell_width, state)
  scanning_cell = state[:current]
  return Rect.new(scanning_cell.grid_x * cell_width, scanning_cell.grid_y * cell_width, cell_width, cell_width)
end
  

# @param [Cell] cell1
# @param [Cell] cell2
def remove_walls_between_cells(cell1, cell2)
  if cell1.grid_x == cell2.grid_x - 1
    cell1.right_wall = false
    cell2.left_wall = false
  end

  if cell1.grid_x == cell2.grid_x + 1
    cell1.left_wall = false
    cell2.right_wall = false
  end

  if cell1.grid_y == cell2.grid_y - 1
    cell1.bottom_wall = false
    cell2.top_wall = false
  end

  if cell1.grid_y == cell2.grid_y + 1
    cell1.top_wall = false
    cell2.bottom_wall = false
  end
end



# @param [Array] grid A n x n array of cells.
# @param [Cell] cell Cell whose neighbours need to be checked
# @return [Cell] A random neighbour that has not been visited. Nil if all neighbours are visited.
def not_visited_cell_neighbour(grid, cell)
  neighbours = []
  top = cell.grid_y.positive? ? grid[cell.grid_y - 1][cell.grid_x] : nil
  right = cell.grid_x < grid[cell.grid_y].length - 1 ? grid[cell.grid_y][cell.grid_x + 1] : nil
  bottom = cell.grid_y < grid.length - 1 ? grid[cell.grid_y + 1][cell.grid_x] : nil
  left = cell.grid_x.positive? ? grid[cell.grid_y][cell.grid_x - 1] : nil

  neighbours.push(top) if top && !top.show_base_background
  neighbours.push(right) if right && !right.show_base_background
  neighbours.push(bottom) if bottom && !bottom.show_base_background
  neighbours.push(left) if left && !left.show_base_background

  return neighbours.empty? ? nil : neighbours[rand(neighbours.length)]
end
