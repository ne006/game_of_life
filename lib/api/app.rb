# frozen_string_literal: true

require 'sinatra/json'

module Api
  class App < Sinatra::Application
    helpers Sinatra::JsonParams

    set :default_content_type, :json

    get '/world/:uuid/?:generation?' do
      @world = Store.instance.fetch("game_of_life.worlds.#{params['uuid']}")

      raise StandardError, "World with UUID #{params['uuid']} not found" unless @world

      generation = @world.generation

      @world.tick(to: (params.fetch('generation') || @world.generation).to_i)

      store(@world, params['uuid']) if generation != @world.generation

      json({
             world: {
               geology: @world.geology,
               generation: @world.generation,
               width: @world.width,
               height: @world.height,
               rules: @world.rulestring
             },
             uuid: params['uuid']
           })
    rescue StandardError => e
      json({ error: e.message })
    end

    post '/world' do
      @world = GameOfLife::World.new(cells: params['cells'], rules: params['rules'])
      @world.tick(to: params.fetch('generations', @world.generation + 1).to_i)

      @uuid = store(@world)

      json({
             world: {
               geology: @world.geology,
               generation: @world.generation,
               width: @world.width,
               height: @world.height,
               rules: @world.rulestring
             },
             uuid: @uuid
           })
    rescue StandardError => e
      json({ error: e.message })
    end

    protected

    def store(world, uuid = nil)
      uuid ||= SecureRandom.uuid
      Store.instance.put('game_of_life', Store.instance.fetch('game_of_life') || {})
      Store.instance.put('game_of_life.worlds', Store.instance.fetch('game_of_life.worlds') || {})
      Store.instance.put("game_of_life.worlds.#{uuid}", world)
      Store.instance.expire("game_of_life.worlds.#{uuid}", Time.now + (60 * 60))

      uuid
    end
  end
end
