require 'csv'
require 'numo/narray'

require_relative '../../lib/range_merge'

module Quadrants
  TOP_LEFT = 0
  TOP_RIGHT = 1
  BOTTOM_RIGHT = 2
  BOTTOM_LEFT = 3
end

module Directions
  UP = 0
  RIGHT = 1
  DOWN = 2
  LEFT = 3
end

QUADRANTS_IN_DIRECTION = [
  [Quadrants::TOP_LEFT, Quadrants::TOP_RIGHT],
  [Quadrants::TOP_RIGHT, Quadrants::BOTTOM_RIGHT],
  [Quadrants::BOTTOM_RIGHT, Quadrants::BOTTOM_LEFT],
  [Quadrants::BOTTOM_LEFT, Quadrants::TOP_LEFT]
].map(&:to_set).freeze

QUADRANT_EDGE_DIRECTIONS = [
  [Directions::DOWN, Directions::RIGHT],
  [Directions::DOWN, Directions::LEFT],
  [Directions::UP, Directions::RIGHT],
  [Directions::UP, Directions::LEFT]
].map(&:to_set).freeze

DIRECTION_COORDINATE_SELECTORS = [
  1, # Directions::UP
  0, # Directions::RIGHT
  1, # Directions::DOWN
  0 # Directions::LEFT
].freeze

# @param [Numo::NArray] array
# @param [Integer] axis
# @param [Integer] roll_by
def roll(array, axis, roll_by)
  other_axis_filters = (1...array.shape.length).map { true }
  array.swapaxes(0, axis).then do |array_to_roll|
    array_to_roll[roll_by.., *other_axis_filters]
      .concatenate(array_to_roll[0...roll_by, *other_axis_filters])
      .swapaxes(0, axis)
  end
end

def point_quadrants_relative_to_pivot(point_x, point_y, pivot_x, pivot_y)
  [[point_x <= pivot_x && point_y >= pivot_y, Quadrants::TOP_LEFT],
   [point_x >= pivot_x && point_y >= pivot_y, Quadrants::TOP_RIGHT],
   [point_x >= pivot_x && point_y <= pivot_y, Quadrants::BOTTOM_RIGHT],
   [point_x <= pivot_x && point_y <= pivot_y, Quadrants::BOTTOM_LEFT]]
    .filter_map { |condition, quadrant| quadrant if condition }
    .to_set
end

def get_relative_quadrants(points)
  points.to_a.map(&:to_a) => [[point_x, point_y], [pivot_x, pivot_y]]

  point_quadrants_relative_to_pivot(point_x, point_y, pivot_x, pivot_y)
end

class UnreachableError < StandardError
end

def invert_quadrant(quadrant)
  case quadrant
  when Quadrants::TOP_LEFT then Quadrants::BOTTOM_RIGHT
  when Quadrants::TOP_RIGHT then Quadrants::BOTTOM_LEFT
  when Quadrants::BOTTOM_RIGHT then Quadrants::TOP_LEFT
  when Quadrants::BOTTOM_LEFT then Quadrants::TOP_RIGHT
  else raise UnreachableError, "Invalid quadrant: #{quadrant}"
  end
end

# Check whether the rectilinear edges projected from a point towards another point
# leave the bounds of the enclosed shape
class BoundsChecker
  # @param [Numo::NArray] points
  def initialize(points)
    @points = points
    @edges = Numo::NArray.column_stack(
      [(index_range = 0...points.shape[0]),
       roll(Numo::NArray[index_range], 0, 1)]
    ).to_a
    @cache = {}
  end

  def lookup_quadrant_bounds(pivot_index)
    @cache[pivot_index] ||= calculate_quadrant_bounds(@points[pivot_index, true])
  end

  def get_corner_quadrants(corner_indices)
    relative_quadrant = get_relative_quadrants(@points[corner_indices, true]).first

    Numo::NArray[relative_quadrant, invert_quadrant(relative_quadrant)]
  end

  def check_point_bounds(corner_indices, relative_quadrants)
    corner_indices => [corner_index, opposing_corner_index]
    relative_quadrants => [relative_quadrant, opposing_quadrant]

    filter_bounds = ->((direction, quadrant), bound) { [direction, bound] if quadrant == opposing_quadrant }

    bounds_lookup = lookup_quadrant_bounds(corner_index).filter_map(&filter_bounds).to_h.transform_keys do |direction|
      DIRECTION_COORDINATE_SELECTORS[direction]
    end

    get_relative_quadrants(
      [@points[opposing_corner_index, true],
       [bounds_lookup[0], bounds_lookup[1]]]
    ).include?(relative_quadrant)
  end

  #   ┌───┐            ┌───┐            ┌───┐
  # ┌─┘  ┌┘ ┌───┐ -> ┌─◉  ┌┘ ┌───┐ -> ┌─◉━━┱┘ ┌─┱─┐  For each driving corner, calculate bounds towards the other corner.
  # │    └──┘  ┌┘ -> │    └──┘  ┌┘ -> │ ┃  └──┘ ┃┌┘  For each relevant bound, if it is less than the relevant coordinate
  # └┐  ┌──┐  ┌┘  -> └┐  ┌──┐  ◉┘  -> ┗┯╋━┯━━┯━━◉┘   of the other corner then the edge goes outside the enclosed space.
  #  └──┘  └──┘       └──┘  └──┘       └┺─┘  └──┘
  def check_rectangle_bounds(corner_indices)
    # Any pair of valid opposing quadrants for the corners will do
    # (set size > 1 for rectangles with one or more dimensions == 1)
    relative_quadrants = get_corner_quadrants(corner_indices)

    to_sort_key = ->(bool) { bool ? 0 : 1 }

    [[0, 1], [1, 0]]
      .map { |order| [corner_indices[order].to_a, relative_quadrants[order].to_a] }
      .sort_by { |(_, corner_index), _| to_sort_key.call(@cache.include?(corner_index)) }
      .each { |indices, quadrants| return false unless check_point_bounds(indices, quadrants) }

    true
  end

  private

  def make_quadrant_lookup(pivot_point)
    Numo::NArray
      .column_stack([@points.expand_dims(1), pivot_point.tile(@points.shape[0]).reshape(nil, 1, 2)])
      .each_over_axis(0).map { |points| get_relative_quadrants(points) }
  end

  def get_relevant_directions(edge, quadrant_lookup)
    edge_quadrant_sets = edge.map { |point_index| quadrant_lookup[point_index] }
    return [] unless edge_quadrant_sets.any?(&:one?)

    edge_quadrant_superset = edge_quadrant_sets.reduce(&:|)

    QUADRANTS_IN_DIRECTION.filter_map.with_index do |quadrant_set, direction_index|
      direction_index if (edge_quadrant_superset & quadrant_set).length == 2
    end
  end

  def get_intersections_for_edge(point_index, quadrant_lookup, relevant_directions)
    quadrants = quadrant_lookup[point_index]
    return [] unless quadrants.one?

    relevant_directions.map do |direction_index|
      [[direction_index, quadrants.first].freeze,
       @points[point_index, DIRECTION_COORDINATE_SELECTORS[direction_index]]]
    end
  end

  def raycast_from_pivot(pivot_point)
    quadrant_lookup = make_quadrant_lookup(pivot_point)

    all_intersecting_edges = @edges.reject do |start_index, end_index|
      (quadrant_lookup[start_index] ^ quadrant_lookup[end_index]).empty?
    end

    all_intersecting_edges.flat_map do |edge|
      next if (relevant_directions = get_relevant_directions(edge, quadrant_lookup)).empty?

      edge.flat_map do |point_index|
        get_intersections_for_edge(point_index, quadrant_lookup, relevant_directions)
      end.compact
    end
  end

  def bounds_to_intersections(quadrant, direction_index, pivot_point, intersections)
    key = [direction_index, quadrant].freeze

    bounds = intersections.filter_map do |(intersection_index, intersection_value)|
      intersection_value if intersection_index == key
    end

    relevant_pivot_coordinate = pivot_point[DIRECTION_COORDINATE_SELECTORS[direction_index]]

    if bounds.empty?
      [key, relevant_pivot_coordinate]
    else
      [key, bounds[(Numo::NArray[bounds] - relevant_pivot_coordinate).abs.sort_index[0]]]
    end
  end

  def calculate_quadrant_bounds(pivot_point)
    intersections = raycast_from_pivot(pivot_point)

    QUADRANTS_IN_DIRECTION.flat_map.with_index do |quadrant_set, direction_index|
      quadrant_set.map do |quadrant|
        bounds_to_intersections(quadrant, direction_index, pivot_point, intersections)
      end
    end.to_h
  end
end

def corner_points_to_path(corner_points)
  corner_points.to_a => [[left, top], [right, bottom]]
  "M #{left} #{top} L #{right} #{top} L #{right} #{bottom} L #{left} #{bottom} Z"
end

points = Numo::Int32.cast(CSV.read(File.expand_path('../input.csv', __dir__), converters: :integer))
quadrant_bounds_lookup = BoundsChecker.new(points)

corner_pairs = Numo::NArray.column_stack(
  [(indices1 = (point_indices = Numo::NArray[0...points.shape[0]]).repeat(point_indices.size)),
   (indices2 = point_indices.tile(point_indices.size))]
)[indices1 < indices2, true]

areas = ((points[corner_pairs[true, 0], true] - points[corner_pairs[true, 1], true]).abs + 1).prod(axis: 1)

# For each candidate box, test whether all edges fall within enclosed space
areas.sort_index.reverse.each_with_index do |area_index, iteration_index|
  corner_indices = corner_pairs[area_index, true]
  next unless quadrant_bounds_lookup.check_rectangle_bounds(corner_indices)

  puts "Processed #{iteration_index + 1} candidate rectangles"
  puts "Biggest red square: #{areas[area_index]} (#{corner_points_to_path(points[corner_indices, true])})"
  break
end
