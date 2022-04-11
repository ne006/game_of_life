# frozen_string_literal: true

require 'singleton'

class Store
  include Singleton

  attr_accessor :store, :expirations

  def initialize
    @store = {}
    @expirations = {}
  end

  def fetch(key)
    return store if key.nil? || key == ''

    path = parse_key(key)

    get_entry(path).first
  ensure
    remove_expired_keys
  end

  def expire(key, time)
    expirations[key] = time
  end

  def put(key, value)
    if key.nil? || key == ''
      old_value = store
      self.store = value

      return old_value
    end

    path = parse_key(key)

    old_value, parent = get_entry(path)

    raise ArgumentError, "key \"#{key}\" does not exist" if parent.nil?

    terminal_key = path.last
    terminal_key = terminal_key.to_i if parent.is_a?(Array)

    parent[terminal_key] = value

    old_value
  ensure
    remove_expired_keys
  end

  def drop(key)
    if key.nil? || key == ''
      old_value = store
      self.store = nil

      return old_value
    end

    path = parse_key(key)

    old_value, parent = get_entry(path)

    return nil if parent.nil?

    terminal_key = path.last

    if parent.is_a?(Array)
      parent.delete_at(terminal_key.to_i)
    else
      parent.delete(terminal_key)
    end

    expirations.delete(key)

    old_value
  end

  protected

  def parse_key(key)
    key.split('.').map! do |v|
      case v
      when ~/^\d+$/ then v.to_i
      else v
      end
    end
  end

  def get_entry(path)
    path.each_with_index.reduce([nil, store]) do |value_with_parent, key_with_index|
      value, parent = value_with_parent
      key, index = key_with_index
      key = key.to_i if parent.is_a?(Array)

      break [value, parent] if parent.nil?

      value = parent[key]

      break [value, parent] if value.nil? && index.zero?
      break [value, parent] if index == path.size - 1

      [value, value]
    end
  end

  def remove_expired_keys
    expirations.each do |key, time|
      next if Time.now <= time

      expirations.delete key
      drop key
    end
  end
end
