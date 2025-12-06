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

access_grid = input_grid.map.with_index do |line, row_index|
  line.split('').map.with_index do |char, column_index|
    if char != '@'
      char
    else
      adjacent_rolls = get_surrounds(input_grid, row_index, column_index).count { |char| char == '@' }
      adjacent_rolls < 4 ? 'x' : char
    end
  end
end

access_grid.each { |row| puts row.join('') }

puts "Forklift accessible position count: #{access_grid.flatten.count { |char| char == 'x' }}"
