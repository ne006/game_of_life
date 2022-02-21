# frozen_string_literal: true

class Environment
  class << self
    attr_reader :value

    def init(default: 'development', autoload_paths: [])
      @value = ENV.fetch('RACK_ENV', default)

      dependencies autoload_paths: autoload_paths
    end

    protected

    def dependencies(autoload_paths: [])
      require 'bundler/setup'

      require 'zeitwerk'

      loader = Zeitwerk::Loader.new
      autoload_paths.each { |path| loader.push_dir(path) }
      loader.push_dir('lib')
      loader.setup
    end
  end
end
