# frozen_string_literal: true

require 'sinatra/json'
require 'sinatra/base'
require 'sinatra/content_for'

module Web
  class App < Sinatra::Application
    helpers Sinatra::WebpackHelpers

    manifest File.expand_path('../../public/assets/manifest.json', __dir__)

    set :default_content_type, :html
    set :views, File.expand_path('../../views', __dir__)
    set :public_folder, File.expand_path('../../public/', __dir__)

    get '/' do
      @world = {
        geology: [],
        generation: 0,
        width: 10,
        height: 10,
        rules: 'B3/S23'
      }
      slim :index, layout: :application
    end
  end
end
