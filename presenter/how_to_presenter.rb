require 'gosu'
require_relative '../game_constants'
require_relative '../helper/maze_helper'


# Constructor function for the how to presenter.
# @param [Hash] state State of the presenter.
def setup_how_to_presenter(state)
  state[:instructions] = [
    '• Select a maze algorithm: Depth first, Iterative division',
    '• Tip: Depth first generated algorithms are easier to complete than iterative division',
    '• Watch a unique maze being generated in real time',
    '• Navigate the maze from top-left to bottom right to complete the level',
    '• Complete the entire game before the countdown in the top-right corner reaches zero',
    "• You will initially have #{TIME_LIMIT} seconds. Each level up will award you additional #{LEVEL_UP_TIME_BOOST} seconds.",
  ]
end

# Graphical work must be done here.\
# @param [GameWindow] window Gosu Window that handles the draw on the screen.
# @param [Hash] state State of the presenter.
def draw_how_to_presenter(window, state)

  # background
  window.draw_rect(0, 0, window.width, window.height, Gosu::Color.argb(DARK_GRAY_COLOR))

  # Game Title
  heading = 'How to play?'
  heading_font =   Gosu::Font.new(80, options = {:name => 'assets/fonts/hahmlet_font.ttf'})
  heading_width = heading_font.text_width(heading)
  heading_font.draw_text(heading,                     # Text
                          (window.width - heading_width) / 2,     # draw x
                          50,                                   # draw y
                          1,                                    # draw z
                          1,                                    # scale x
                          1,                                    # scale y
                          Gosu::Color.argb(LIGHT_GREEN_COLOR))  # color
  card_width = 400
  card_height = 400
  card_start_x = (window.width - card_width) / 2
  card_start_y = 140
  window.draw_rect(card_start_x,
                   card_start_y,
                   card_width,
                   card_height,
                   Gosu::Color.argb(GRAY_COLOR))

  draw_string_array(state[:instructions], card_start_x + 10, card_start_y + 10, card_width - 20)

  main_menu_string = 'Press space to navigate back'
  main_menu_font = Gosu::Font.new(20, options={italic: true})
  main_menu_width = main_menu_font.text_width(main_menu_string)
  main_menu_font.draw_text(main_menu_string,
                           (window.width - main_menu_width) / 2,
                           card_start_y + card_height + 10,
                           1 ,
                           1 ,
                           1 ,
                           Gosu::Color.argb(LIGHT_GREEN_COLOR))

end

# @param [Integer] id Gosu button key id
# @param [GameWindow] window Gosu window that passed the user input.
def button_down_how_to_presenter(id, window)
  navigate_back(window) if id == Gosu::KbSpace
end

