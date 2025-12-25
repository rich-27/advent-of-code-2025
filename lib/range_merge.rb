# Provides utilities for merging overlapping or adjacent ranges.
#
# This module refines the Range class to add instance-level merge functionality
# and provides a class method to merge multiple ranges at once.
#
# @example Merging multiple ranges
#   RangeMerge.merge(1..5, 3..8, 10..15)
#   # => [1..8, 10..15]
#
# @example Using the refined instance method
#   using RangeMerge
#   (1..5).merge(3..8)
#   # => 1..8
module RangeMerge
  refine Range do
    def merge(other)
      first, second = [self, other].sort_by(&:begin)
      return unless first.overlap?(second) || second.begin - first.end == 1

      first.begin..[first.end, second.end].max
    end
  end

  using RangeMerge

  def self.merge(*ranges_array)
    return if ranges_array.empty?

    ranges_array.sort_by(&:begin).reduce do |range_or_merged_ranges, range|
      Array(range_or_merged_ranges).tap do |merged_ranges|
        if (merged = merged_ranges.last.merge(range))
          merged_ranges[-1] = merged
        else
          merged_ranges << range
        end
      end
    end
  end
end
