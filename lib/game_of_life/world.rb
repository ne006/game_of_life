# frozen_string_literal: true

module GameOfLife
  class World
    attr_reader :cells, :width, :height, :generation

    MIN_NEIGHBOURS = 2
    MAX_NEIGHBOURS = 3
    NEEDED_FOR_BIRTH = 3

    def initialize(cells:)
      @cells = cells
      @generation = 0

      validate_cells
      set_borders
    end

    def peek(x, y)
      validate_coords(x, y)

      cells.at(y)&.at(x)
    end

    def tick
      new_cells = []

      cells.each_with_index do |col, y|
        new_cells.push []
        col.each_with_index do |_row, x|
          new_cells[y][x] = advance_cell x, y
        end
      end

      @cells = new_cells
      @generation += 1
    end

    protected

    def advance_cell(x, y)
      neighbours_count = cell_neighbours(x, y).reduce(:+)
      cell_state = peek(x, y)
      new_cell_state = cell_state

      if cell_state == 1
        new_cell_state = 0 if neighbours_count < MIN_NEIGHBOURS || neighbours_count > MAX_NEIGHBOURS
      elsif neighbours_count >= NEEDED_FOR_BIRTH
        new_cell_state = 1
      end

      new_cell_state
    end

    def cell_neighbours(x, y) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      validate_coords(x, y)

      matrix = []
      radii = Math.sqrt(2)

      (0..7).each do |a|
        coords = overflow_coords(
          x + (Math.cos(a * Math::PI / 4) * radii).round(0),
          y - (Math.sin(a * Math::PI / 4) * radii).round(0)
        )
        matrix.push coords
      rescue ArgumentError
        next
      end

      matrix.map { |coords| peek(*coords) }.compact
    end

    def validate_coords(x, y)
      raise ArgumentError, "x should be <= #{width}" unless x >= 0 && x <= width
      raise ArgumentError, "y should be <= #{height}" unless y >= 0 && y <= height
    end

    def overflow_coords(x, y)
      x_a = x
      y_a = y

      x_a = width + x if x.negative?
      y_a = height + y if y.negative?

      x_a = x % width if x > width
      y_a = y % height if y > height

      [x_a, y_a]
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
