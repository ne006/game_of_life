# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/json'

module Sinatra
  module WebpackHelpers
    def self.included(base)
      class << base
        def manifest(value = nil)
          if value
            @manifest = value
          else
            @manifest
          end
        end
      end
    end

    def asset_url(asset_name)
      manifest[asset_name]
    end

    def manifest(reload: false) # rubocop:disable Metrics/AbcSize
      raise "#{self.class.manifest} doesn't exist" unless File.exist?(self.class.manifest.to_s)

      if reload
        @manifest = Base.json_encoder.decode(File.read(self.class.manifest.to_s))
      else
        @manifest ||= Base.json_encoder.decode(File.read(self.class.manifest.to_s))
      end
    end
  end

  helpers WebpackHelpers
end
