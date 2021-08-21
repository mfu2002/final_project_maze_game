# Adds new line in the string to wrap the text if it exceeds the max width.
# @param [String] string String that is being wrapped.
# @param [Gosu::Font] font Font being used to draw the string.
# @param [Integer] max_width Max width the text can cover.
def wrap_string(string, font, max_width)
  words = string.split()
  lines = 1
  return_string = ''
  words.each do |word|
    if font.text_width("#{return_string}#{word} ") > max_width
      return_string += "\n"
      lines += 1
    end
    return_string += "#{word} "
  end
  return [return_string, lines]
end
# @param [Rect] button_rect Rect describing position and size of the button
# @param [Integer] mouse_x X location of the mouse
# @param [Integer] mouse_y Y location of the mouse
# @return [Boolean] Is the mouse of the button
def mouse_over_button(button_rect, mouse_x, mouse_y)
  return (mouse_x > button_rect.x_pos && mouse_x < button_rect.x_pos + button_rect.width) && # X direction
    (mouse_y > button_rect.y_pos && mouse_y < button_rect.y_pos + button_rect.height)   # Y direction
end

# @param [GameWindow] window
# @param [String] text button text
# @param [Rect] button_rect Rect describing button location and size
# @param [Integer] font_size height of the text
def draw_button(window, text, button_rect, border_size, font_size)

  # button border rect
  if mouse_over_button(button_rect, window.mouse_x, window.mouse_y)
    window.draw_rect(button_rect.x_pos,
                     button_rect.y_pos,
                     button_rect.width,
                     button_rect.height,
                     Gosu::Color.argb(LIGHT_GREEN_COLOR))
  end
  # button background rect
  window.draw_rect(button_rect.x_pos + border_size,
                   button_rect.y_pos + border_size,
                   button_rect.width -  border_size * 2,
                   button_rect.height - border_size * 2,
                   Gosu::Color.argb(GRAY_COLOR))

  font = Gosu::Font.new(font_size)
  text_width = font.text_width(text, 1)
  font.draw_text(text,
                 button_rect.x_pos + (button_rect.width - text_width) / 2,
                 button_rect.y_pos + (button_rect.height - font_size) / 2,
                 1)
end

# draws an array of string onto the screen.
# @param [Array] instructions Array of string harbouring the instructions.
# @param [Integer] start_x X position on the screen where the text board should start.
# @param [Integer] start_y Y position on the screen where the text board should start.
# @param [Integer] max_width Max width the text could cover. (Wraps the text if greater)
def draw_string_array(instructions, start_x, start_y, max_width)
  draw_string_y = start_y
  string_height = 20
  instructions_font = Gosu::Font.new(string_height)
  instructions.each do |instruction|
    wrapped_instruction = wrap_string(instruction, instructions_font, max_width)
    instructions_font.draw_text(wrapped_instruction[0],
                                start_x,
                                draw_string_y,
                                1)
    draw_string_y += string_height * (wrapped_instruction[1] + 1)
  end
end

# @param [GameWindow] window
# @param [Presenter] presenter Presenter value that signifies which view to display
# @param [Hash] args Optional hash to containing values the presenter setup may require.
def navigate_to(window, presenter, args = {})
  presenter_state = {}
  case presenter
  when Presenter::MAIN_MENU_PRESENTER
    setup_main_menu_presenter(window.width, presenter_state)
  when Presenter::MAZE_PRESENTER
    setup_maze_presenter(args[:algorithm], presenter_state)
  when Presenter::HOW_TO_PRESENTER
    setup_how_to_presenter(presenter_state)
  when Presenter::GAME_OVER_PRESENTER
    setup_game_over_presenter(args[:player_level_record], args[:win], presenter_state)
  when Presenter::GAME_REPLAY_PRESENTER
    setup_game_replay_presenter(args[:player_level_record], presenter_state)
  end
  window.presenter_state_stack.push(presenter_state)
  window.presenter_stack.push(presenter)
end


# @param [GameWindow] window Gosu window that handles all the required GUI queries (Update, Draw etc.).
def navigate_back(window)
  window.presenter_stack.pop
  window.presenter_state_stack.pop
end

# Pops all views back to the destination presenter. Process is exclusive.
# i.e. The destination presenter will not be popped.
# @param [GameWindow] window Gosu window that handles all the required GUI queries (Update, Draw etc.).
# @param [Presenter] presenter Presenter value that signifies which view to display.
def navigate_back_to(window, presenter)
  until window.presenter_stack.last == presenter
    window.presenter_stack.pop
    window.presenter_state_stack.pop
  end
end
