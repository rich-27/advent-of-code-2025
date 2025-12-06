apply_operation = lambda do |(operation, operands)|
  case operation
  when '*'
    operands.reduce(1, :*)
  when '+'
    operands.sum
  end
end

operation_to_s = lambda do |(operation, operands)|
  [operands, operation].join(' ')
end

operations = File.readlines('../input.txt').map { |line| line.chomp.split(' ').map(&:chomp) }.then do |lines|
  operands = lines[0...-1].map { |line| line.map(&:to_i) }
  lines.last.zip(operands[0].zip(*operands[1..]))
end

operation_results = operations.map(&apply_operation)
operations.map(&operation_to_s).zip(operation_results).each do |label, result|
  puts "#{label}: #{result}"
end

puts "Total: #{operation_results.sum}"
