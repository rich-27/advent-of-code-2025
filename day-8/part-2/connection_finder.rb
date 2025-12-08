require 'csv'
require 'numo/narray'
require 'rb_heap'

# Read a point cloud from a CSV and find all connections
class ConnectionFinder
  attr_reader :points, :connections

  def initialize(filepath)
    @points = (points = Numo::Int64.cast(CSV.read(filepath, converters: :integer))).to_a

    @connections =
      find_connections(points)
      .to_a
      .sort_by { |item| item[:distance] }
      .map { |item| [item[:a_index], item[:b_index]] }
  end

  def save_connections(filepath)
    CSV.open(filepath, 'wb') { |csv| @connections.each { |connection| csv << connection } }
  end

  private

  def make_maxheap
    Heap.new { |a, b| a[:distance] > b[:distance] }
  end

  def get_square_distance(point, others)
    diff = Numo::UInt64.cast((point - others).abs)
    (diff * diff).sum(1).to_a
  end

  def find_connections(points)
    make_maxheap.tap do |distance_heap|
      points[0...-1, true].each_over_axis(0).each_with_index do |row, a_index|
        get_square_distance(
          row, points[(a_index + 1).., true]
        ).each_with_index.sort_by { |distance, _| distance }.each do |distance, b_index|
          distance_heap << { distance: distance, a_index: a_index, b_index: a_index + b_index + 1 }
        end
      end
    end
  end
end
