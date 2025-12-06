def parse_input(fresh_id_ranges_string, available_ids_string)
  [
    fresh_id_ranges_string.split("\n").map do |range_string|
      range_string.split('-').map(&:to_i).then do |range_start, range_end|
        range_start..range_end
      end
    end,
    available_ids_string.split("\n").map(&:to_i)
  ]
end

fresh_id_ranges, available_ids = parse_input(*File.read(File.expand_path('../input.txt', __dir__)).split("\n\n"))

puts "Fresh id count: #{available_ids.select do |id|
  fresh_id_ranges.any? { |fresh_id_range| fresh_id_range.cover?(id) }
end.count}"
