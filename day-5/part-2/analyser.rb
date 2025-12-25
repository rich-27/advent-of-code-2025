require_relative '../../lib/range_merge'

def parse_input(fresh_id_ranges_string)
  fresh_id_ranges_string.split("\n").map do |range_string|
    range_string.split('-').map(&:to_i).then do |range_start, range_end|
      range_start..range_end
    end
  end
end

fresh_id_ranges = parse_input(File.read(File.expand_path('../input.txt', __dir__)).split("\n\n").first)

puts "Fresh id count: #{RangeMerge.merge(*fresh_id_ranges).map(&:size).sum}"
