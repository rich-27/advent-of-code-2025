bad_ids = []

for range in File.read("../input.txt").chomp.split(',')
  bad_ids << Set[]
  
  range_start, range_end = range.split('-')
  for repeat_count in 2..range_end.length
    # Determine the repeating pattern to check for in the id
    get_prefix = ->(num_str) { num_str[0...(num_str.length / repeat_count)].to_i }

    # Gets the smallest and biggest IDs for a given id length
    smallest_id = ->(num_digits) { "1#{'0' * (num_digits - 1)}".to_i }
    biggest_id = ->(num_digits) { ('9' * num_digits).to_i }

    # The smallest and largest repeating pattern to consider based on the range boundaries
    start_prefix = (range_start.length % repeat_count == 0 \
      ? get_prefix.call(range_start)
      : smallest_id.call((range_start.length + 1) / repeat_count))
    end_prefix = (range_end.length % repeat_count == 0 \
      ? get_prefix.call(range_end)
      : biggest_id.call((range_end.length - 1) / repeat_count))

    # Determine the smallest and largest repeating pattern for a given id length, bounded by the range prefixes
    make_start = ->(num_digits) { [smallest_id.call(num_digits / repeat_count), start_prefix].max }
    make_end = ->(num_digits) { [biggest_id.call(num_digits / repeat_count), end_prefix].min }
    
    for num_digits in (range_start.length..range_end.length).select { |n| n % repeat_count == 0 }
      for prefix in (make_start.call(num_digits)..make_end.call(num_digits))
        id = (prefix.to_s * repeat_count).to_i
        bad_ids[-1] << id if id.between?(range_start.to_i, range_end.to_i)
      end
    end
  end

  puts "Bad IDs for range #{range}: #{bad_ids[-1].to_a.sort.join(',')}" if bad_ids[-1].any?
  puts "No bad IDs for range #{range}" if bad_ids[-1].empty?
end

puts "Bad ID sum: #{bad_ids.map(&:to_a).flatten.sum}"