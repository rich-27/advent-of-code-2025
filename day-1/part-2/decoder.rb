dial_position = 50
zero_count = 0

input_data = File.read('../input.txt').split.map { |line| { direction: line[0], amount: line[1..].to_i } }

input_data.map { |operation| operation.values_at(:direction, :amount) }.each do |direction, amount|
  zero_pass_count = amount / 100
  amount %= 100

  case direction
  when 'L'
    dial_position += 100 if dial_position.zero?
    dial_position -= amount
  when 'R'
    dial_position += amount
  end

  zero_pass_count += 1 unless (0..100).include?(dial_position)
  dial_position %= 100

  zero_count += zero_pass_count
  zero_count += 1 if dial_position.zero?

  puts [
    "Dial moved #{direction}#{amount} to position #{dial_position}",
    ("(passed zero #{zero_pass_count} times)" if zero_pass_count.positive?).to_s
  ].compact.join(' ')
end

puts "Password is: #{zero_count}"
