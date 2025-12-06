require_relative '../pycall_import'

pyfrom 'PIL', import: :Image
pyfrom 'PIL', import: :ImageDraw

require 'gifenc'

module GifMaker
  # Pillow image wrapper
  class PillowImage
    attr_reader :image, :palette

    def initialize(image, pillow_font, rendering_options)
      @image = image
      @pillow_font = pillow_font
      @line_spacing = rendering_options.line_spacing
      @background_color = rendering_options.background_color
      @draw = ImageDraw.Draw(@image)
    end

    def self.from_frame_data(frame_data, pillow_font, rendering_options)
      return new(Image.new('RGB', [0, 0]), pillow_font, rendering_options) if frame_data.values.all?(&:empty?)

      image_size = calculate_image_size(frame_data, pillow_font, rendering_options.line_spacing)
      pil_image = Image.new('RGB', image_size, rendering_options.background_color)
      new(pil_image, pillow_font, rendering_options).tap do |image|
        frame_data.each do |color, lines|
          image.render_text_layer(color, lines)
        end
        image.palettize
      end
    end

    def self.calculate_image_size(frame_data, font, line_spacing)
      calculate_lines_height = ->(lines) { lines.length * font.max_char_height + (lines.length - 1) * line_spacing }
      [
        frame_data.values.flat_map do |lines|
          lines.map { |line| font.get_line_width(line) }
        end.max,
        frame_data.values.map(&calculate_lines_height).max
      ]
    end

    def rgb_to_int(rgb)
      ((rgb[0].to_i & 0xff) << 16) | ((rgb[1].to_i & 0xff) << 8) | rgb[2].to_i & 0xff
    end

    def render_text_layer(color, lines)
      y_position = 0
      line_height = @pillow_font.max_char_height

      lines.each do |line|
        @draw.text([0, y_position], line, font: @pillow_font.font, fill: color)
        y_position += line_height + @line_spacing
      end
    end

    def palettize
      @image = @image.convert('P', palette: Image.ADAPTIVE, colors: 256)
      @palette = @image.getpalette.each_slice(3).map(&method(:rgb_to_int))
    end

    def to_gifenc_image(palette_lookup)
      Gifenc::Image.new(@image.width, @image.height).tap do |frame|
        frame.replace(@image.tobytes.bytes.map do |index|
          palette_lookup[@palette[index]]
        end.pack('C*'))
      end
    end
  end
end
