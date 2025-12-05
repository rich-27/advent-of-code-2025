require_relative '../tile_loader'

image = GifMaker::TileLoader.instance['@']
Gifenc::Gif.new(
  image.width,
  image.height,
  gct: GifMaker::TileLoader.instance.color_table
).tap { |gif| gif.images << image }.save('tile_loader_test.gif')
