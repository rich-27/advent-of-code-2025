require 'chunky_png'

require_relative 'tile_loader'

module GifMaker
  # ChunkyPNG wrapper
  class Frame
    attr_accessor :width, :height, :canvas

    def initialize(width, height, background_color: '#2a2a2a')
      @width = width
      @height = height
      @canvas = Gifenc::Image.new(@width, @height, color: [ChunkyPNG::Color.from_hex(background_color) >> 8].pack('C*'))
    end

    def self.from_lines(lines, background_color: '#2a2a2a')
      Frame.new(
        TileLoader::TILE_WIDTH * lines.first.length,
        TileLoader::TILE_HEIGHT * lines.length,
        background_color: background_color
      ).tap { |frame| frame.render_lines(lines) }
    end

    def render_lines(lines)
      lines.each_with_index do |line, y|
        line.chars.each_with_index do |char, x|
          tile = TileLoader.instance[char]
          @canvas.copy(src: tile, dest: [x * TileLoader::TILE_WIDTH, y * TileLoader::TILE_HEIGHT])
        end
      end
    end
  end
end
