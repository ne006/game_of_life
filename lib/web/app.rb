# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/content_for'

module Web
  class App < Sinatra::Application
    set :default_content_type, :html
    set :views, File.expand_path('../../views', __dir__)

    get '/' do
      slim :index, layout: :application
    end
  end
end
