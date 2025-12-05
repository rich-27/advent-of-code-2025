def parse_input(fresh_id_ranges_string)
  fresh_id_ranges_string.split("\n").map do |range_string|
    range_string.split('-').map(&:to_i).then do |range_start, range_end|
      range_start..range_end
    end
  end
end

fresh_id_ranges = parse_input(File.read('../input.txt').split("\n\n").first)

def merge_ranges(ranges_array)
  return [] if ranges_array.empty?
  ranges = ranges_array.sort_by { |range| range.begin }
  ranges[1..].reduce([ranges.first]) do |merged_ranges, range|
    if (last = merged_ranges.last).overlap?(range) || range.begin - last.end == 1
      merged_ranges.tap { merged_ranges[-1] = last.begin..[last.end, range.end].max }
    else
      merged_ranges << range
    end
  end
end

puts "Fresh id count: #{merge_ranges(fresh_id_ranges).map(&:size).sum}"
