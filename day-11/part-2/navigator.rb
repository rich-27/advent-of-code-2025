node_lookup = File.readlines(File.expand_path('../input.txt', __dir__), chomp: true).map do |line|
  line.split(' ').tap { |node_names| node_names.first.sub!(':', '') } => [source, *output]
  [name = source.sub(':', ''), { name:, connected_nodes: output }]
end.to_h

# We want to complete the access of the values array first to avoid 'can't add a new key into hash during iteration'
node_lookup.values.each { |node| node[:connected_nodes]&.map! { |name| node_lookup[name] ||= { name: } } } # rubocop:disable Style/HashEachMethods

def count_paths(nodes)
  { dac: 0, fft: 0, both: 0, neither: 0 }.tap do |path_counts|
    nodes.each do |node|
      sum_counts = ->(*keys) { keys.map { |key| node[:path_counts][key] || 0 }.sum }

      node => { name: }
      case name
      when 'dac'
        path_counts[:both] += sum_counts.call(:both, :fft)
        path_counts[:dac] += sum_counts.call(:dac, :neither)
      when 'fft'
        path_counts[:both] += sum_counts.call(:both, :dac)
        path_counts[:fft] += sum_counts.call(:fft, :neither)
      else
        node[:path_counts].each { |key, value| path_counts[key] += value }
      end
    end
  end
end

def walk(node)
  node.tap do
    node => { name: }
    node[:path_counts] ||=
      if name == 'out'
        { neither: 1 }
      else
        node => { connected_nodes: }
        count_paths(connected_nodes.tap { |node_| node_.each(&method(:walk)) })
      end
  end
end

node = node_lookup['svr']

walk(node)

node_lookup.each_value do |node|
  node => { name:, path_counts: }
  puts "#{name}: #{path_counts.inspect}"
end

puts "Number of paths: #{node[:path_counts][:both]}"
