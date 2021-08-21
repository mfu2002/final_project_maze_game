# frozen_string_literal: true

require 'gosu'
require_relative 'maze_presenter'
require_relative 'how_to_presenter'
require_relative '../game_constants'
require_relative '../helper/general_helper'
require_relative '../model/rect'
require_relative '../model/maze_algorithm'

MAIN_MENU_BUTTON_WIDTH = 250 # pixels
MAIN_MENU_BUTTON_HEIGHT = 60 # pixels
MAIN_MENU_BUTTON_BORDER = 1 # pixels

# @param [Integer] window_width Width of the screen in pixels.
# @param [Hash] state State of the presenter.
def setup_main_menu_presenter(window_width, state)
  state[:buttons] = {
    how_to: Rect.new(window_width - 45, 5, 40 ,40),
    depth_first: Rect.new((window_width - MAIN_MENU_BUTTON_WIDTH) / 2, 240, MAIN_MENU_BUTTON_WIDTH, MAIN_MENU_BUTTON_HEIGHT),
    iterative_division: Rect.new((window_width - MAIN_MENU_BUTTON_WIDTH) / 2, 325, MAIN_MENU_BUTTON_WIDTH, MAIN_MENU_BUTTON_HEIGHT),
    quit: Rect.new((window_width - MAIN_MENU_BUTTON_WIDTH) / 2, 410, MAIN_MENU_BUTTON_WIDTH, MAIN_MENU_BUTTON_HEIGHT)
  }
end

# Graphical work must be done here.
# @param [GameWindow] window Gosu window that handles the draw to the screen.
# @param [Hash] state State of the presenter.
def draw_main_menu_presenter(window, state)
  # background
  window.draw_rect(0, 0, window.width, window.height, Gosu::Color.argb(DARK_GRAY_COLOR))

  # Game Title
  heading_font = Gosu::Font.new(80, options = {name: 'assets/fonts/hahmlet_font.ttf'})
  heading_width = heading_font.text_width(GAME_NAME.upcase)
  heading_font.draw_text(GAME_NAME.upcase,                     # Text
                          (window.width - heading_width) / 2,     # draw x
                          70,                                   # draw y
                          1,                                    # draw z
                          1,                                    # scale x
                          1,                                    # scale y
                          Gosu::Color.argb(LIGHT_GREEN_COLOR))  # color


  # buttons
  draw_button(window, '?'.encode('utf-8'), state[:buttons][:how_to], MAIN_MENU_BUTTON_BORDER, 20)
  draw_button(window, 'Depth-first', state[:buttons][:depth_first], MAIN_MENU_BUTTON_BORDER, 25)
  draw_button(window, 'Iterative Division', state[:buttons][:iterative_division], MAIN_MENU_BUTTON_BORDER, 25)
  draw_button(window, 'Quit', state[:buttons][:quit], MAIN_MENU_BUTTON_BORDER, 25)

end

# method each presenter must implement.
# @param [Integer] id Gosu button key id
def button_down_main_menu_presenter(id, window, state)
  case id
  when Gosu::MsLeft
    navigate_to(window, Presenter::HOW_TO_PRESENTER) if mouse_over_button(state[:buttons][:how_to], window.mouse_x, window.mouse_y)
    navigate_to(window, Presenter::MAZE_PRESENTER, { algorithm: MazeAlgorithm::DEPTH_FIRST}) if mouse_over_button(state[:buttons][:depth_first], window.mouse_x, window.mouse_y)
    navigate_to(window, Presenter::MAZE_PRESENTER, { algorithm: MazeAlgorithm::ITERATIVE_DIVISION}) if mouse_over_button(state[:buttons][:iterative_division], window.mouse_x, window.mouse_y)
    window.close if mouse_over_button(state[:buttons][:quit], window.mouse_x, window.mouse_y)
  end
end


