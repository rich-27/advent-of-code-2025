battery_joltages = File.readlines('../input.txt', chomp: true).map { |line| line.split('').map(&:to_i) }

powered_count = 12

output_joltages = battery_joltages.map do |bank_joltages|
  candidates = bank_joltages.dup

  (0...powered_count).each do |pick|
    remaining_picks = powered_count - pick
    picked_joltage = candidates[pick..(candidates.length - remaining_picks)].max
    drop_count = candidates[pick..].take_while { |joltage| joltage < picked_joltage }.count
    candidates.slice!(pick, drop_count) if drop_count.positive?
  end

  candidates[0...powered_count].join('').to_i
end

battery_joltages.zip(output_joltages).each do |bank_joltages, output_joltage|
  puts "Bank #{bank_joltages.join('')} yields #{output_joltage}"
end

puts "Total output joltage: #{output_joltages.sum}"
