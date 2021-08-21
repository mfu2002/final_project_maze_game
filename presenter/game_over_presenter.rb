# frozen_string_literal: true

require_relative 'game_replay_presenter'

# constructor function for game over presenter
# @param [Array] player_level_record Data on the grid on each level and how the player navigated it.
# @param [Boolean] win did the user win?
# @param [Hash] state State of the presenter.
def setup_game_over_presenter(player_level_record, win, state)
  state[:player_level_record] = player_level_record
  state[:win] = win
end

# Graphical work must be done here.
# @param [GameWindow] window Gosu window that handles the draw on the screen.
# @param [Hash] state State of the presenter.
def draw_game_over_presenter(window, state)
  # background
  window.draw_rect(0, 0, window.width, window.height, Gosu::Color.argb(DARK_GRAY_COLOR))

  # Game Title
  heading_font_size = 80
  heading_font = Gosu::Font.new(heading_font_size, options = {:name => 'assets/fonts/hahmlet_font.ttf'})
  heading = state[:win] ? 'YOU WIN!!!' : 'YOU LOST :('
  heading_width = heading_font.text_width(heading)
  heading_font.draw_text(heading,                                       # Text
                          (window.width - heading_width) / 2,           # draw x
                          (window.height - heading_font_size) / 2 - 40, # draw y
                          1,                                            # draw z
                          1,                                            # scale x
                          1,                                            # scale y
                          Gosu::Color.argb(LIGHT_GREEN_COLOR))          # color

  # Navigation Information
  subheading = "Press spacebar to return to main menu.\nPress R to view your maze navigation."
  subheading_font = Gosu::Font.new(20)
  subheading_width = subheading_font.text_width(subheading)
  subheading_font.draw_text(subheading,
                            (window.width - subheading_width) / 2,
                            window.height / 2 + 40,
                            1)

end

# @param [Integer] id Gosu button id.
# @param [GameWindow] window Gosu window that handles the button down callback.
# @param [Hash] state State of the presenter.
def button_down_game_over_presenter(id, window, state)

  navigate_back_to(window, Presenter::MAIN_MENU_PRESENTER) if id == Gosu::KbSpace
  navigate_to(window,Presenter::GAME_REPLAY_PRESENTER, {player_level_record: state[:player_level_record]}) if id == Gosu::KB_R
end
