require_relative 'connection_finder'

ConnectionFinder
  .new(File.expand_path('../input.csv', __dir__))
  .save_connections(File.expand_path('./connections.csv', __dir__))
