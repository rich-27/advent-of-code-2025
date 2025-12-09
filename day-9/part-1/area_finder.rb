require 'csv'
require 'numo/narray'

points = Numo::Int64.cast(CSV.read(File.expand_path('../input.csv', __dir__), converters: :integer))

CSV.open(File.expand_path('./areas.csv', __dir__), 'wb') do |csv|
  points.each_over_axis(0) do |point|
    Numo::NArray.hstack(
      [
        Numo::NArray.vstack([point] * points.shape[0]),
        points,
        Numo::UInt64.cast((point - points).abs + 1)
          .then { |diff| (diff[true, 0] * diff[true, 1]) }
          .expand_dims(1)
      ]
    ).each_over_axis(0) do |row|
      csv << row.to_a
    end
  end
end

areas = Numo::UInt64.cast(CSV.read(File.expand_path('areas.csv', __dir__), converters: :integer))[true, -1]

print "Biggest red square: #{areas.max}"
