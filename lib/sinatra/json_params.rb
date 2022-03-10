# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/json'

module Sinatra
  module JsonParams
    def json_params
      body = request.body.read
      if body.nil? || body.empty?
        {}
      else
        Base.json_encoder.decode(body)
      end
    ensure
      request.body.rewind
    end

    def params
      @params.merge! json_params
    end
  end

  helpers JsonParams
end
