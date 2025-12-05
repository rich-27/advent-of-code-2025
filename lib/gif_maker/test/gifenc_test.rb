require 'chunky_png'
require 'gifenc'

image = ChunkyPNG::Image.from_file('../chars/@.png')
palette = image.palette.to_a
color_table = Gifenc::ColorTable.new(palette.map { |color| color >> 8 })
Gifenc::Gif.new(image.width, image.height, gct: color_table).tap do |gif|
  gif.images << Gifenc::Image.new(image.width, image.height).tap do |frame|
    frame.replace(
      (0...image.height).map do |line_index|
        (0...image.width).map do |column_index|
          palette.index(image[column_index, line_index])
        end
      end.flatten.pack('C*')
    )
  end
end.save('gifenc_test.gif')
