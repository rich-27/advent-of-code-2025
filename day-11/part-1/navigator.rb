node_lookup = File.readlines(File.expand_path('../input.txt', __dir__), chomp: true).map do |line|
  # line.split(' ').tap { |node_names| node_names.first.sub!(':', '') } => [node_name, *output]
  source, *output = line.split(' ').tap { |node_names| node_names.first.sub!(':', '') }
  [name = source.sub(':', ''), { name:, connected_nodes: output }]
end.to_h

# We want to complete the access of the values array first to avoid 'can't add a new key into hash during iteration'
node_lookup.values.each { |node| node[:connected_nodes]&.map! { |name| node_lookup[name] ||= { name: } } } # rubocop:disable Style/HashEachMethods

def walk(node, path: '')
  append_node = ->(name) { "#{path}->#{name}" }

  case node
  in { name:, connected_nodes: }
    connected_nodes.flat_map do |node|
      walk(node, path: append_node.call(name))
    end
  in { name: }
    append_node.call(name).tap { |path| puts path }
  end
end

paths = walk(node_lookup['you'])

puts "Number of paths: #{paths.length}"
