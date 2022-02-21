# frozen_string_literal: true

module GameOfLife
  class World
    attr_reader :cells, :width, :height, :generation

    def initialize(cells:)
      @cells = cells
      @generation = 0

      validate_cells
      set_borders
    end

    def peek(x, y) # rubocop:disable Naming/MethodParameterName
      validate_coords(x, y)

      cells.at(y)&.at(x)
    end

    protected

    def validate_coords(x, y) # rubocop:disable Naming/MethodParameterName
      raise ArgumentError, "x should be <= #{width}" unless x >= 0 && x <= width
      raise ArgumentError, "y should be <= #{height}" unless y >= 0 && y <= height
    end

    def validate_cells
      raise ArgumentError, 'cells should be a matrix' unless cells.map(&:size).uniq.size == 1
    end

    def set_borders
      @width = cells.first.size
      @height = cells.size
    end
  end
end
