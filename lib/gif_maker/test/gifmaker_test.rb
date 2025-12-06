require_relative '../../gif_maker'

GifMaker.from_frames_data(
  [{
    '#ffffff': [
      '@ @',
      ' @ ',
      '@ @'
    ],
    '#609ad8': [
      ' x ',
      'x x',
      ' x '
    ]
  }]
).save('gifmaker_test.gif')
