require_relative '../pycall_import'

pyfrom 'PIL', import: :ImageFont

module GifMaker
  # Gif font options
  class FontOptions
    attr_reader :font_path, :font_size

    WINDOWS_CONSOLAS_PATH = 'C:/Windows/Fonts/consola.ttf'.freeze

    def initialize(font_path: WINDOWS_CONSOLAS_PATH, font_size: 16)
      @font_path = font_path
      @font_size = font_size
    end
  end

  # Pillow ImageFont wrapper with character bbox caching
  class PillowFont
    attr_reader :font

    def initialize(font_options)
      @font = ImageFont.truetype(font_options.font_path, font_options.font_size)
      @char_bbox_cache = {}
    end

    def get_char_width(char)
      cache_char_bbox(char)[:width]
    end

    def get_line_width(line)
      line.chars.map { |char| get_char_width(char) }.sum
    end

    def max_char_height
      @char_bbox_cache.values.map { |bbox| bbox[:height] }.max
    end

    private

    def cache_char_bbox(char)
      @char_bbox_cache[char] ||= calculate_char_bbox(char)
    end

    def calculate_char_bbox(char)
      @font.getbbox(char).to_a.then do |_, _, width, height|
        { width: width, height: height }
      end
    end
  end
end
