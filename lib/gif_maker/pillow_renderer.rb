require 'gifenc'
require_relative 'pillow_font'
require_relative 'pillow_image'

module GifMaker
  # Gif rendering options
  class RenderingOptions
    attr_reader :line_spacing, :background_color, :font_options

    def initialize(line_spacing: 0, background_color: '#2a2a2a', font_options: FontOptions.new)
      @line_spacing = line_spacing
      @background_color = background_color
      @font_options = font_options
    end
  end

  # Pillow-based multi-color frame generator
  class PillowRenderer
    attr_reader :color_table

    def initialize(rendering_options)
      @pillow_font = PillowFont.new(rendering_options.font_options)
      @rendering_options = rendering_options
      @color_table = Gifenc::ColorTable.new
      @palette_lookup = {}
    end

    # frames_data: array of hashes, each hash maps color hex to array of lines
    # Example: [{ '#ff0000' => ['@ @', ' @ ', '@ @'], '#00ff00' => [' x ', 'x x', ' x '] }]
    def render_frames(frames_data)
      return [] if frames_data.empty?

      print '  Rendering frames'
      pil_images = frames_data.map do |frame_data|
        PillowImage.from_frame_data(frame_data, @pillow_font, @rendering_options).tap { print '.' }
      end
      puts ''

      puts '  Building global colour table...'
      build_global_color_table(pil_images.map(&:palette))

      print '  Converting images'
      pil_images.map do |image|
        image.to_gifenc_image(@palette_lookup).tap { print '.' }
      end.tap { puts '' }
    end

    private

    def build_global_color_table(all_palettes)
      [hex_to_int(@rendering_options.background_color), *all_palettes.flatten(1).uniq].each do |color|
        next if @palette_lookup.key?(color)

        @color_table.add(color) unless @color_table.colors.index(color)
        @palette_lookup[color] = @color_table.colors.index(color)
      end
    end

    def hex_to_int(hex)
      (hex[1..2].to_i(8) << 16) | (hex[3..4].to_i(8) << 8) | hex[5..6].to_i(8)
    end
  end
end
