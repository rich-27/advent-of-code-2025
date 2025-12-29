# Parse machine data and calculate minimal button presses
class Machine
  attr_reader :minimal_presses

  def initialize(pattern_string, *button_strings, _)
    @pattern_string = pattern_string
    @button_strings = button_strings
    @pattern = parse_pattern(pattern_string)
    @buttons = button_strings.map(&method(:parse_button))
    calculate_presses
  end

  def print_info
    puts "#{@pattern_string}: #{@minimal_presses}"
    puts "  #{@press_combos.map(&:inspect).join(', ')}"
  end

  private

  def parse_pattern(pattern_string)
    Numo::NArray[pattern_string[1...-1].chars].eq('#')
  end

  def parse_button(button_string)
    @pattern.copy.fill(0).tap do |button|
      button[button_string[1...-1].split(',').map(&:to_i)] ^= 1
    end
  end

  def calculate_presses
    @press_combos = Set[]
    calculate_next_presses([], @pattern.copy.fill(0))
    @minimal_presses = @press_combos.map(&:length).min
  end

  def toggle_button(state, button)
    state.tap { state[button] ^= 1 }
  end

  def calculate_next_presses(pressed_buttons, state)
    if @pattern == state
      @press_combos << pressed_buttons
      return
    end

    @buttons
      .each_with_index
      .select { |_, index| pressed_buttons.empty? || index > pressed_buttons.last }
      .each do |button, index|
      calculate_next_presses([*pressed_buttons, index], state ^ button)
    end
  end
end