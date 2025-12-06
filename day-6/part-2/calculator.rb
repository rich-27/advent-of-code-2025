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

make_number = ->(chars) { chars.map(&:strip).all?(&:empty?) ? nil : chars.join('').to_i }

operations = File.readlines('../input.txt', chomp: true).map(&:chars).then do |lines|
  operation_pairs = lines.last.zip(lines[0].zip(*lines[1...-1]).map(&make_number))
  operation_pairs.reduce([[nil, []]], &lambda do |operations, (operation, operand)|
    if operation.strip.empty? && operand.nil?
      operations << [nil, []]
    else
      operations.last[0] = operation unless operation.strip.empty?
      operations.last[1] << operand
    end
    operations
  end)
end

operation_results = operations.map(&apply_operation)
operations.map(&operation_to_s).zip(operation_results).each do |label, result|
  puts "#{label}: #{result}"
end

puts "Total: #{operation_results.sum}"
