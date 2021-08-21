# frozen_string_literal: true

# Data class to store cell location and wall data.
class Cell
  attr_accessor :grid_x, :grid_y, :top_wall, :right_wall, :bottom_wall, :left_wall, :show_base_background

  def initialize(i, j, initial_wall)
    @grid_x = i
    @grid_y = j
    @top_wall = @right_wall = @bottom_wall = @left_wall = initial_wall
    @show_base_background = false
  end
end
