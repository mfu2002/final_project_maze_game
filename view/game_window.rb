require 'gosu'
require_relative '../presenter/main_menu_presenter'
require_relative '../model/cell'
require_relative '../game_constants'

module Presenter
  MAIN_MENU_PRESENTER, MAZE_PRESENTER, HOW_TO_PRESENTER, GAME_OVER_PRESENTER, GAME_REPLAY_PRESENTER = *0..5
end

class GameWindow < Gosu::Window

  attr_reader :presenter_state_stack, :presenter_stack

  # @param [Integer] width width of the window.
  # @param [Integer] height height of the window
  # @param [Array] args Additional gosu args
  def initialize(width, height, *args)
    super
    self.caption = GAME_NAME
    @presenter_state_stack = []
    @presenter_stack = []
    navigate_to(self, Presenter::MAIN_MENU_PRESENTER)
  end

  # Gosu function
  # method each presenter must implement.
  def update()
    presenter_state = @presenter_state_stack.last
    case @presenter_stack.last
    when Presenter::MAZE_PRESENTER
      update_maze_presenter(self, presenter_state)
    when Presenter::GAME_REPLAY_PRESENTER
      update_game_replay_presenter(presenter_state)
    end
  end

  # Gosu function
  # Graphical work must be done here.
  def draw()
    presenter_state = @presenter_state_stack.last
    case @presenter_stack.last
    when Presenter::MAIN_MENU_PRESENTER
      draw_main_menu_presenter(self, presenter_state)
    when Presenter::MAZE_PRESENTER
      draw_maze_presenter(self, presenter_state)
    when Presenter::HOW_TO_PRESENTER
      draw_how_to_presenter(self, presenter_state)
    when Presenter::GAME_OVER_PRESENTER
      draw_game_over_presenter(self, presenter_state)
    when Presenter::GAME_REPLAY_PRESENTER
      draw_game_replay_presenter(self, presenter_state)
    end
  end

  # Gosu function
  # @param [Integer] id Gosu button id
  def button_down(id)
    presenter_state = @presenter_state_stack.last
    case @presenter_stack.last
    when Presenter::MAIN_MENU_PRESENTER
      button_down_main_menu_presenter(id, self, presenter_state)
    when Presenter::MAZE_PRESENTER
      button_down_maze_presenter(id, presenter_state)
    when Presenter::HOW_TO_PRESENTER
      button_down_how_to_presenter(id, self)
    when Presenter::GAME_OVER_PRESENTER
      button_down_game_over_presenter(id, self, presenter_state)
    when Presenter::GAME_REPLAY_PRESENTER
      button_down_game_replay_presenter(id, self, presenter_state)
    end
    super
  end

end

GameWindow.new(WINDOW_LENGTH, WINDOW_LENGTH).show