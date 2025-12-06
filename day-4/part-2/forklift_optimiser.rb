require_relative '../../lib/gif_maker'

input_grid = File.readlines(File.expand_path('../input.txt', __dir__), chomp: true)

def get_surrounds(grid, row_index, column_index)
  (-1..1).flat_map do |row_offset|
    adjacent_row_index = row_index + row_offset
    next unless (0...grid.length).cover?(adjacent_row_index)

    (-1..1).filter_map do |column_offset|
      next if row_offset.zero? && column_offset.zero?

      adjacent_column_index = column_index + column_offset
      next unless (0...grid[row_index].length).cover?(adjacent_column_index)

      grid[adjacent_row_index][adjacent_column_index]
    end
  end
end

access_grids = [input_grid]
loop do
  changed = false

  new_grid = access_grids[-1].map.with_index do |line, row_index|
    line.split('').map.with_index do |char, column_index|
      if char != '@'
        char
      else
        adjacent_rolls = get_surrounds(access_grids[-1], row_index, column_index)
        if adjacent_rolls.count { |char| char == '@' } < 4
          changed = true
          'x'
        else
          char
        end
      end
    end.join('')
  end

  break unless changed

  access_grids << new_grid
end

access_grids[-1].each { |line| puts line }

puts "Forklift accessible position count: #{access_grids[-1].map { |line| line.count 'x' }.sum}"

puts "Making gif:"

frame_data_stub = { '#ffffff': '@', '#609ad8': 'x' }

grid_to_frame_data = lambda do |grid|
  frame_data_stub.transform_values do |filter_char|
    grid.map { |line| line.chars.map { |char| char == filter_char ? char : ' ' }.join }
  end
end

GifMaker.from_frames_data(
  access_grids.map(&grid_to_frame_data),
  delay: 15
).save(File.expand_path('forklift_access.gif', __dir__))

puts "Done"
