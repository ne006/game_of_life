# frozen_string_literal: true

require_relative 'environment'

Environment.init

require 'pry' if %w[development test].include?(Environment.value)
require 'sinatra/reloader' if %w[development].include?(Environment.value)

require 'sinatra/base'

map('/web') { run Web::App }
map('/api') { run Api::App }
map('/') do
  run Sinatra.new do
    get('/') { redirect '/web' }
  end
end
