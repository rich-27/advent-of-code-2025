require 'gif'

module GifMaker

  # GIF wrapper
  class Gif
    # delay: 10 = 1/100 sec per frame
    def initialize(width, height, delay: 10)
      @width = width
      @height = height
      @delay = delay
      @gif = Gifenc::Gif.new(@width, @height, gct: TileLoader.instance.color_table, delay: @delay)
    end

    def self.from_frame(frame, delay: 10)
      Gif.new(frame.width, frame.height, delay: delay).tap { |gif| gif.add_frame(frame) }
    end

    def add_frame(frame)
      @gif.images << frame.canvas.tap { |image| image.delay ||= @delay }
    end

    def save(file_path)
      @gif.save(file_path)
    end
  end
end
