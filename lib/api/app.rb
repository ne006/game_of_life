# frozen_string_literal: true

require 'sinatra/json'

module Api
  class App < Sinatra::Application
    helpers Sinatra::JsonParams

    set :default_content_type, :json

    post '/world' do
      @world = GameOfLife::World.new(cells: params['cells'], rules: params['rules'])
      @world.tick(to: params.fetch('generations', @world.generation + 1).to_i)

      json({
             world: {
               geology: @world.geology,
               generation: @world.generation,
               width: @world.width,
               height: @world.height,
               rules: @world.rulestring
             }
           })
    rescue StandardError => e
      json({
             error: e.message
           })
    end
  end
end
