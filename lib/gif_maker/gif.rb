require 'gifenc'
require_relative 'pillow_renderer'

module GifMaker
  # GIF wrapper
  class Gif
    def initialize(delay, rendering_options)
      @delay = delay
      @renderer = PillowRenderer.new(rendering_options)
    end

    # frames_data: array of hashes, each hash maps color hex to array of lines
    # Example: [{ '#ff0000' => ['@ @', ' @ ', '@ @'], '#00ff00' => [' x ', 'x x', ' x '] }]
    def render(frames_data)
      @frames = @renderer.render_frames(frames_data)
    end

    def save(file_path)
      return if @frames.nil? || @frames.empty?

      size = [@frames.map(&:width).max, @frames.map(&:height).max]
      Gifenc::Gif.new(*size, gct: @renderer.color_table, delay: @delay).tap do |gif|
        puts '  Appending frames to gif...'
        @frames.each do |frame|
          gif.images << frame.tap { |img| img.delay ||= @delay }
        end
      end.tap { puts '  Saving gif...' }.save(file_path)
    end
  end
end
