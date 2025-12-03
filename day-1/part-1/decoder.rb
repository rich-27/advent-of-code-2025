dial_position = 50
zero_count = 0

input_data = File.read('../input.txt').split.map { |line| { direction: line[0], amount: line[1..].to_i } }

input_data.map { |operation| operation.values_at(:direction, :amount) }.each do |direction, amount|
  case direction
  when 'L'
    dial_position = (dial_position - amount) % 100
  when 'R'
    dial_position = (dial_position + amount) % 100
  end

  zero_count += 1 if dial_position.zero?

  puts "Dial moved #{direction}#{amount} to position #{dial_position}"
end

puts "Password is: #{zero_count}"
