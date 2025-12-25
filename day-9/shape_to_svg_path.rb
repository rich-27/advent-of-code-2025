require 'csv'

File.open(File.expand_path('./svg_path.txt', __dir__), 'wb') do |path_file|
  points = CSV.read(File.expand_path('./input.csv', __dir__), converters: :integer)
              .map { |point| point.join(' ') }

  path_file << "M #{[*points, *points[1...-1].reverse].join(' ')} Z"
end
