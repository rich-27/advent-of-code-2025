require_relative 'connection_finder'

points, connections = ConnectionFinder.new(File.expand_path('../input.csv', __dir__)).then do |connection_finder|
  [connection_finder.points, connection_finder.connections]
end

puts "Number of junctions: #{points.length}"

puts "Number of connections: #{connections.length}"

find_first_connection = lambda do |index|
  connections
    .find_index { |connection| connection.include?(index) }
    .then { |connection_index| [connection_index, connections[connection_index]] }
end

last_unconnected_connection_pair =
  (0...points.length)
  .map(&find_first_connection)
  .max_by { |connection_index, _| connection_index }
  .then { |_, pair| pair }

all_connected = false
last_connection_pair = nil

connect_pairs = lambda do |acc, pair|
  return acc unless last_connection_pair.nil?

  acc.tap do
    groups = pair.map { |item| acc.select { |set| set.include?(item) }[0] }.compact

    if groups.empty?
      acc << pair.to_set
    elsif groups.length < 2 || groups[0] != groups[1]
      if !all_connected || acc.length > 2
        case groups.length
        when 1
          groups[0].merge(pair)
        when 2
          groups[0].merge(groups[1])
          acc.delete(groups[1])
        end
      else
        last_connection_pair = pair
      end
    end

    all_connected = true if pair == last_unconnected_connection_pair
  end
end

puts "Circuits: #{
  connections
    .reduce([], &connect_pairs)
    .map(&:to_a)
    .map(&:length)
    .sort
    .reverse
    .inspect
}"

puts 'Last two junction boxes:'
last_connection_pair.each { |index| puts "  #{index}: #{points[index].inspect}" }

puts "Multiplied X coordinates: #{
  last_connection_pair.map { |index| points[index][0] }.reduce(&:*)
}"
