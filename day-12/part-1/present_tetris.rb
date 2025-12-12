# @param [String] present_strings
def make_presents_lookup(present_strings)
  present_strings.map do |present_string|
    present_string.split(/:?\n/) => [index, *lines]

    dimensions = [lines.map(&:length).max, lines.length]
    tile_count = lines.map(&:chars).flatten.count { |char| char == '#' }

    [index.to_i, { shape: lines, dimensions:, tile_count: }]
  end.to_h
end

# @param [String] spaces_string
# @param [Hash<Integer>] presents_lookup
def make_spaces(spaces_string, presents_lookup:)
  spaces_string.split("\n").map do |space_string|
    space_string.split(/:? /) => [dimensions_string, *present_counts]

    dimensions = dimensions_string.split('x').map(&:to_i)
    presents =
      present_counts
      .map(&:to_i)
      .each_with_index.reject { |count, _| count.zero? }
      .flat_map { |present_count, index| [presents_lookup[index]] * present_count }

    { dimensions:, presents: }
  end
end

# @param [String] input_string
def parse_input(input_string)
  input_string.split("\n\n") => [*present_strings, spaces_string]

  [presents_lookup = make_presents_lookup(present_strings),
   make_spaces(spaces_string, presents_lookup:)]
end

presents_lookup, spaces = parse_input(
  File.read(File.expand_path('../input.txt', __dir__))
)

presents_lookup.each_value { |present| puts "index: #{present.inspect}" }
puts

def print_results(results)
  results => { successes:, failures: }
  puts "#{successes} trivial successes" if successes
  puts "#{failures} trivial failures" if failures
end

print_results(spaces.inject({ successes: nil, failures: nil }) do |tracker, space|
  tracker => { successes:, failures: }
  space => { dimensions:, presents: }
  if (area = dimensions.map { |value| (value / 3) * 3 }.inject(&:*)) >= (bounding_box_areas_sum = presents.length * 9)
    successes ||= 0
    successes += 1
    { successes:, failures: }
  elsif area < (counts_sum = presents.map { |present| present[:tile_count] }.sum)
    failures ||= 0
    failures += 1
    { successes:, failures: }
  else
    print_results(tracker)
    puts "#{dimensions} => area: #{area}, presents:"
    puts "  bounding box areas sum: #{bounding_box_areas_sum},"
    puts "  counts sum: #{counts_sum}"
    { successes: nil, failures: nil }
  end
end)
