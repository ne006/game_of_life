# frozen_string_literal: true

module GameOfLife
  class World # rubocop:disable Metrics/ClassLength
    attr_reader :width, :height, :generation, :rules, :geology, :state

    def initialize(cells:, rules: 'B3/S23')
      @geology = []
      @history = []
      @cells = cells
      @generation = 0
      @state = 'alive'

      validate_cells
      set_borders
      assign_rules(rules)
    end

    def cells(generation: self.generation)
      if generation == self.generation
        @cells
      elsif generation >= 0 && generation < self.generation
        @geology[generation]
      else
        raise ArgumentError, "generation should be >= 0 and <= #{self.generation}"
      end
    end

    def history(generation: self.generation)
      unless generation >= 0 && generation <= self.generation
        raise ArgumentError,
              "generation should be >= 0 and <= #{self.generation}"
      end

      @history.first(generation)
    end

    def peek(x, y)
      validate_coords(x, y)

      cells.at(y)&.at(x)
    end

    def run
      tick until end_times?
    end

    def tick(to: generation + 1)
      (to - generation).times do
        @geology.push @cells
        @history.push state

        new_cells = []

        cells.each_with_index do |col, y|
          new_cells.push []
          col.each_with_index do |_row, x|
            new_cells[y][x] = advance_cell x, y
          end
        end

        @cells = new_cells
        @generation += 1

        set_state
      end

      self
    end

    def rulestring
      rules.map { |type, nums| "#{type[0].upcase}#{nums.sort.join}" }.join('/')
    end

    protected

    def advance_cell(x, y)
      neighbours_count = cell_neighbours(x, y).reduce(:+)
      cell_state = peek(x, y)
      new_cell_state = cell_state

      if cell_state == 1 && !rules[:survive].include?(neighbours_count)
        new_cell_state = 0
      elsif rules[:birth].include?(neighbours_count)
        new_cell_state = 1
      end

      new_cell_state
    end

    def cell_neighbours(x, y) # rubocop:disable Metrics/AbcSize
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
      raise ArgumentError, 'cells is nil' if cells.nil?
      raise ArgumentError, 'cells should be a matrix' unless cells.map(&:size).uniq.size == 1
    end

    def set_borders
      @width = cells.first.size
      @height = cells.size
    end

    def assign_rules(rulestring)
      match = rulestring.match(%r{B(?<birth>\d+)/S(?<survive>\d+)})

      raise ArgumentError, 'rules should be a string like "B3/S23"' unless match

      @rules = match.named_captures.transform_values { |v| v.chars.map(&:to_i).uniq }
                    .transform_keys(&:to_sym)
    end

    def set_state
      @state = if check_for_death
                 'dead'
               elsif check_for_loops
                 'looped'
               else
                 'alive'
               end
    end

    def end_times?
      %w[dead looped].include?(state)
    end

    def check_for_death
      cells.all? { |row| row.all?(&:zero?) }
    end

    def check_for_loops # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      return false if @geology.size < 2
      return false if @geology.uniq.size == @geology.size

      repetitions = @geology.each_with_index.each_with_object({}) do |p, r|
        r[p.first] ||= []
        r[p.first].push p.last
      end

      cycles = repetitions.values.yield_self { |r| r.first.zip(*r.last(r.length - 1)) }

      # Check if last cycle is complete
      return false unless cycles.last.none?(&:nil?)

      # Check if cycles are continuos
      return false unless cycles.flatten.compact == (0...generation).to_a

      # Check if cycles are actually repeating at least 2 times
      cycles.length >= 2
    end
  end
end
