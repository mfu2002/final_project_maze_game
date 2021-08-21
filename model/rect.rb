# frozen_string_literal: true

# Data class to store data of a rectangle.
class Rect
  attr_accessor :x_pos, :y_pos, :width, :height

  def initialize(x, y, width, height)
    @x_pos = x
    @y_pos = y
    @width = width
    @height = height
  end
end