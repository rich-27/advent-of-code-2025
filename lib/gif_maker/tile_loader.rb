require 'chunky_png'
require 'gifenc'
require 'singleton'

module GifMaker
  # Load and cache character tiles
  class TileLoader
    include Singleton

    TILE_WIDTH = 13
    TILE_HEIGHT = 18

    attr_accessor :color_table

    def initialize
      @cache = {}
      @color_table = Gifenc::ColorTable.new
    end

    def [](char)
      @cache[char] ||= if File.exist?(path = File.join(__dir__, "chars/#{char}.png"))
                         load_tile(path)
                       else
                         # Tiles are 14x18 pixels
                         Gifenc::Image.new(TILE_WIDTH, TILE_HEIGHT)
                       end
    end

    def create_palette_lookup(palette32)
      lookup = palette32.to_h { |color32| [color32, color32 >> 8] }
      @color_table.add(*lookup.select { |_, color24| @color_table.colors.index(color24).nil? }.values)
      lookup.transform_values { |color24| @color_table.colors.index(color24) }
    end

    def load_tile(path)
      image = ChunkyPNG::Image.from_file(path)
      palette_lookup = create_palette_lookup(image.palette.to_a)

      Gifenc::Image.new(image.width, image.height).tap do |frame|
        frame.replace(
          (0...image.height).map do |line_index|
            (0...image.width).map do |column_index|
              palette_lookup[image[column_index, line_index]]
            end
          end.flatten.pack('C*')
        )
      end
    end
  end
end
