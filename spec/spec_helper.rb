# frozen_string_literal: true

require_relative '../environment'
Environment.init(default: 'test', autoload_paths: %w[spec])

require 'rspec'
require 'pry'
