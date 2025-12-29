require 'numo/narray'
require_relative '../machine'

machines =
  File
  .readlines(File.expand_path('../input.txt', __dir__), chomp: true)
  .map { |line| Machine.new(*line.split(' ')) }

machines.each(&:print_info)

puts "Fewest presses: #{machines.map(&:minimal_presses).sum}"
