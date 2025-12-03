battery_joltages = File.readlines("../input.txt", chomp: true).map { |line| line.split('').map(&:to_i) }

powered_count = 2

output_joltages = battery_joltages.map do |bank_joltages|
  puts "Calculating #{bank_joltages.join('')}..."

  candidates = bank_joltages.dup

  for pick in (0...powered_count)
    puts "  Pick #{pick}:"
    remaining_picks = powered_count - pick
    puts "    Candidates: #{'-' * pick}#{candidates[pick..(candidates.length - remaining_picks)].join('')}#{'-' * (remaining_picks - 1)}"
    picked_joltage = candidates[pick..(candidates.length - remaining_picks)].max
    puts "    Picked joltage: #{picked_joltage}"
    drop_count = candidates[pick..].take_while { |joltage| joltage < picked_joltage }.count
    candidates.slice!(pick, drop_count) if drop_count > 0
    puts "    Remaining bank: #{'-' * (pick + 1)}#{candidates[(pick + 1)..].join('')}"
  end

  puts "Resultant output joltage: #{candidates[0...powered_count].join('')}"
  candidates[0...powered_count].join('').to_i
end

puts "Total output joltage: #{output_joltages.sum}"