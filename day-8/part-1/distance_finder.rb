require 'csv'
require 'numo/narray'
require 'rb_heap'

points = Numo::Int64.cast(CSV.read(File.expand_path('../input.csv', __dir__), converters: :integer))

distance_heap = Heap.new { |a, b| a[:distance] > b[:distance] }

points[0...-1, true].each_over_axis(0).each_with_index do |row, a_index|
  diff = Numo::UInt64.cast((row - points[(a_index + 1).., true]).abs)
  (diff * diff).sum(1).to_a.each_with_index.sort_by { |distance, _| distance }.each do |distance, b_index|
    { distance: distance, a_index: a_index, b_index: a_index + b_index + 1 }.tap do |distance_hash|
      if distance_heap.size < 1000
        distance_heap << distance_hash
      else
        distance_heap.offer(distance_hash)
      end
    end
  end
end

connect_pairs = lambda do |acc, pair|
  acc.tap do
    groups = pair.map { |item| acc.select { |set| set.include?(item) }[0] }.compact.to_set.to_a
    case groups.length
    when 0
      acc << pair.to_set
    when 1
      groups[0].merge(pair)
    when 2
      groups[0].merge(groups[1])
      acc.delete(groups[1])
    end
  end
end

puts "Circuits: #{
  distance_heap
    .to_a
    .map { |item| [item[:a_index], item[:b_index]] }
    .reduce([], &connect_pairs)
    .map(&:to_a)
    .map(&:length)
    .sort
    .reverse
    .inspect
}"

puts "Product of the three largest circuits: #{
  distance_heap
    .to_a
    .map { |item| [item[:a_index], item[:b_index]] }
    .reduce([], &connect_pairs)
    .map(&:length)
    .sort
    .reverse[0..2]
    .reduce(&:*)
}"
