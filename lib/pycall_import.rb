ENV['PYTHON'] = File.expand_path('../.venv/Scripts/python.exe', __dir__)
ENV['PYTHONPATH'] = File.expand_path('../.venv/lib/site-packages', __dir__)

require 'pycall/import'

include PyCall::Import # rubocop:disable Style/MixinUsage
