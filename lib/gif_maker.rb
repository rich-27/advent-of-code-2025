require_relative 'gif_maker/frame'
require_relative 'gif_maker/gif'

# Create a GIF from ASCII grids
module GifMaker
  # Create GIF from frames, each consisting of an array of equal length lines
  def self.from_line_arrays(line_arrays, delay: 10)
    Gif.from_frame(Frame.from_lines(line_arrays.first), delay: delay).tap do |gif|
      line_arrays[1..].each do |lines|
        gif.add_frame(Frame.from_lines(lines))
      end
    end
  end
end
