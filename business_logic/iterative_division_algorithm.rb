# frozen_string_literal: true

require_relative '../model/rect'


# A module used to decide whether to slide the grid vertically or horizontally.
module Orientation
  HORIZONTAL, VERTICAL = *0..1
end

# Data class to store Iterative Division algorithm chamber information.
class ChamberInfo
  attr_accessor :grid_x, :grid_y, :width, :height

  def initialize(i, j, width, height)
    @grid_x = i
    @grid_y = j
    @width = width
    @height = height
  end
end

# Constructor function for the Iterative Division Algorithm.
# @param [Integer] grid_length number of cols and rows in the maze.
# @param [Hash] state Stores presenter state
def setup_iterative_division_algorithm_state(grid_length, state)
  state[:todo_chamber] = []
  state[:finished_init] = false
  state[:current_chamber] = ChamberInfo.new(0, 0, grid_length, grid_length)
  state[:generation_complete] = false
end

# Runs the next iteration of the algorithm.
# @param [Array] grid A n x n array for the maze populated by cells
# @param [Hash] state Stores the state of the algorithm.
def step_through_iterative_division_maze_generator(grid, state)
  unless state[:finished_init]
    draw_canvas_border(grid)
    state[:finished_init] = true
  end
  new_chamber = divide(grid, state[:current_chamber])
  if new_chamber
    state[:current_chamber] = new_chamber[0]
    state[:todo_chamber].push(new_chamber[1])
  elsif !state[:todo_chamber].empty?
    state[:current_chamber] = state[:todo_chamber].pop
  elsif !state[:generation_complete]
    state[:generation_complete] = true
  end
end

# Draws the wall for cells on the edge.
# @param [Array] grid An n x n Array of cells.
def draw_canvas_border(grid)
  grid[0].each do |grid_cell|
    grid_cell.top_wall = true
  end
  grid[grid.length - 1].each do |grid_cell|
    grid_cell.bottom_wall = true
  end

  (0..grid.length - 1).each do |j|
    grid[j][0].left_wall = true
    grid[j][grid[j].length - 1].right_wall = true
  end
end

# @param [Integer] cell_width width of the grid cell in pixels. 
# @param [Hash] state Stores the state of the algorithm.
# @return [Rect] The section of the screen currently being processed.
def iterative_division_scanner_rect(cell_width, state)
  scanning_chamber = state[:current_chamber]
  return Rect.new(scanning_chamber.grid_x * cell_width,
                  scanning_chamber.grid_y * cell_width,
                  scanning_chamber.width * cell_width,
                  scanning_chamber.height * cell_width)
end

# Divides the chamber into two sections at a random index. 
# @param [Array] grid - 2D array of populated cells
# @param [ChamberInfo] chamber_info Chamber that needs to be divided
# @return [Array] An array of two Chambers (that were sliced from the original chamber) with their walls built
def divide(grid, chamber_info)
  return if chamber_info.width <= 1 || chamber_info.height <= 1

  orientation = choose_orientation(chamber_info.width, chamber_info.height)

  return orientation == Orientation::HORIZONTAL ? divide_horizontally(grid, chamber_info) : divide_vertically(grid, chamber_info)

end

# @param [Array] grid - 2D array of populated cells
# @param [ChamberInfo] chamber_info Chamber that needs to be divided horizontally
# @return [Array] An array of two Chambers (that were sliced from the original chamber) with their walls built
def divide_horizontally(grid, chamber_info)
  dividing_index = chamber_info.grid_x + rand(chamber_info.width - 1)
  gap_index = chamber_info.grid_y + rand(chamber_info.height)
  (0..chamber_info.height - 1).each do |k|
    next if chamber_info.grid_y + k == gap_index

    grid[chamber_info.grid_y + k][dividing_index].right_wall = true
    grid[chamber_info.grid_y + k][dividing_index + 1].left_wall = true
  end

  return [ChamberInfo.new(chamber_info.grid_x, chamber_info.grid_y, dividing_index - chamber_info.grid_x + 1, chamber_info.height),
          ChamberInfo.new(dividing_index + 1, chamber_info.grid_y, chamber_info.grid_x + chamber_info.width - dividing_index - 1, chamber_info.height)]

end

# @param [Array] grid - 2D array of populated cells
# @param [ChamberInfo] chamber_info Chamber that needs to be divided vertically
# @return [Array] An array of two Chambers (that were sliced from the original chamber) with their walls built
def divide_vertically(grid, chamber_info)
  dividing_index = chamber_info.grid_y + rand(chamber_info.height - 1)
  gap_index = chamber_info.grid_x + rand(chamber_info.width)
  (0..chamber_info.width - 1).each do |k|
    next if chamber_info.grid_x + k == gap_index

    grid[dividing_index][chamber_info.grid_x + k].bottom_wall = true
    grid[dividing_index + 1][chamber_info.grid_x + k].top_wall = true
  end

  return [ChamberInfo.new(chamber_info.grid_x, chamber_info.grid_y, chamber_info.width, dividing_index - chamber_info.grid_y + 1),
          ChamberInfo.new(chamber_info.grid_x, dividing_index + 1, chamber_info.width, chamber_info.grid_y + chamber_info.height - dividing_index - 1)]
end 
  
# @param [Integer] width Width of the chamber
# @param [Integer] height Height of the chamber
# @return [Orientation] The orientation in which the chamber should be divided. 
def choose_orientation(width, height)
  if width < height
    return Orientation::VERTICAL
  elsif height < width
    return Orientation::HORIZONTAL
  else
    return rand(2).zero? ? Orientation::HORIZONTAL : Orientation::VERTICAL
  end
end



