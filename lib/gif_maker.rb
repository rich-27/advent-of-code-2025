require_relative 'gif_maker/gif'

# Create a GIF from ASCII grids
module GifMaker
  # Create GIF from frames_data
  # frames_data: array of hashes, each hash maps color hex to array of lines
  # Example: [{ '#ff0000' => ['@ @', ' @ ', '@ @'], '#00ff00' => [' x ', 'x x', ' x '] }]
  def self.from_frames_data(frames_data, delay: 10, rendering_options: RenderingOptions.new)
    Gif.new(delay, rendering_options).tap { |gif| gif.render(frames_data) }
  end
end
