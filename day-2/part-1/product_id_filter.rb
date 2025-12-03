bad_ids = []

# Gets the smallest and biggest IDs for a given id length
def smallest_id(num_digits)
  10**(num_digits - 1)
end

def biggest_id(num_digits)
  (10**num_digits) - 1
end

File.read('../input.txt').chomp.split(',').each do |range|
  bad_ids << []

  range_start, range_end = range.split('-')

  # The smallest and largest repeating pattern to consider based on the range boundaries
  start_prefix = [
    range_start[0...(range_start.length.to_f / 2).floor].to_i,
    smallest_id((range_start.length.to_f / 2).ceil)
  ].max
  end_prefix = [
    range_end[0...(range_end.length.to_f / 2).ceil].to_i,
    biggest_id((range_end.length.to_f / 2).floor)
  ].min

  (range_start.length..range_end.length).select(&:even?).each do |num_digits|
    # Determine the smallest and largest repeating pattern for a given id length, bounded by the full range prefixes
    section_start = [smallest_id(num_digits / 2), start_prefix].max
    section_end = [biggest_id(num_digits / 2), end_prefix].min

    (section_start..section_end).each do |prefix|
      id = "#{prefix}#{prefix}".to_i
      bad_ids[-1] << id if id.between?(range_start.to_i, range_end.to_i)
    end
  end

  puts "Bad IDs for range #{range}: #{bad_ids[-1].join(',')}" if bad_ids[-1].any?
  puts "No bad IDs for range #{range}" if bad_ids[-1].empty?
end

puts "Bad ID sum: #{bad_ids.flatten.sum}"
