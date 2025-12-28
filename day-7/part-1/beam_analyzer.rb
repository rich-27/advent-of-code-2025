require 'numo/narray'

diagram = Numo::NArray[*File.readlines(File.expand_path('../input.txt', __dir__)).map(&:chars)]
indices = Numo::NArray.column_stack(
  [Numo::Int32.new(length = diagram.shape[0]).seq.repeat(width = diagram.shape[1]),
   Numo::Int32.new(width).seq.tile(length)]
)

beam_splitter = indices[diagram.flatten.eq('^'), true].each_over_axis(0).filter_map do |splitter_indices|
  splitter_indices.to_a => [row_index, column_index]

  column = diagram[0...row_index, column_index]
  splitter_y_indices = Numo::Int32.new(column.shape).seq[column.eq('^')]

  has_beam = (clear_above = splitter_y_indices.empty?) && column.eq('S').any?
  puts "#{row_index}, #{column_index}: Below S" if has_beam

  unless has_beam
    start_row = clear_above ? 0 : splitter_y_indices[-1] + 1
    column_indices = [column_index - 1, column_index + 1]

    puts "#{row_index}, #{column_index}: Checking #{start_row}..#{row_index - 1}: #{
      column_indices.map { |index| "#{index}: #{diagram[start_row...row_index, index].to_a.join}" }.join(', ')
    }"

    has_beam =
      column_indices
      .reject { |index| index.negative? || index >= width }
      .filter_map { |index| true if diagram[start_row...row_index, index].eq('^').any? }
      .any?
  end

  splitter_indices if has_beam
end

puts "Beam splits #{beam_splitter.length} times"
