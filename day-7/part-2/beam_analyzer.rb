require 'numo/narray'

diagram = Numo::NArray[*File.readlines(File.expand_path('../input.txt', __dir__), chomp: true).map(&:chars)]

splitter_coords = Numo::NArray.column_stack(
  [Numo::Int32.new(length = diagram.shape[0]).seq.repeat(width = diagram.shape[1]),
   Numo::Int32.new(width).seq.tile(length)]
)[diagram.flatten.eq('^'), true]

beam_counts = Numo::UInt64.cast(diagram.map do |value|
  case value
  when 'S' then 1
  else 0
  end
end)

def get_beam_count(diagram, beam_counts, row_index, column_index)
  column = diagram[0...row_index, column_index]
  splitter_y_indices = Numo::Int32.new(column.shape).seq[column.eq('^')]

  beam_counts[
    (if splitter_y_indices.empty?
       0
     else
       splitter_y_indices[-1] + 1
     end)...row_index, column_index].sum
end

splitter_coords.each_over_axis(0) do |splitter_indices|
  splitter_indices.to_a => [row_index, column_index]

  beam_count = get_beam_count(diagram, beam_counts, row_index, column_index)

  [column_index - 1, column_index + 1].each { |index| beam_counts[row_index, index] += beam_count }
end

beam_counts.each_over_axis(1).with_index do |column, index|
  next if diagram[-2, index] == '^'
  column[-1] += get_beam_count(diagram, beam_counts, beam_counts.shape[0] - 1, index)
end

puts '['
beam_counts.each_over_axis(0) { |line| puts "  #{line.to_a.inspect}" }
puts ']'


puts "Number of timelines: #{beam_counts[-1, true].sum}"
