# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GameOfLife::World do
  subject(:the_world) do
    described_class.new(
      cells: [[1, 1, 1, 0],
              [0, 0, 0, 0],
              [1, 0, 1, 0],
              [0, 0, 0, 0]]
    )
  end

  describe '#initialize' do
    it "returns a #{described_class.name}" do
      expect(the_world).not_to be_nil
    end

    it 'sets width of the world' do
      expect(the_world.width).to be(4)
    end

    it 'sets height of the world' do
      expect(the_world.height).to be(4)
    end

    context 'with invalid cells' do
      subject(:the_world) do
        described_class.new(
          cells: [[1, 0, 1, 0],
                  [0, 0, 1],
                  [0, 0, 0, 0],
                  [1, 0, 0, 0]]
        )
      end

      it 'raises an ArgumentError' do
        expect { the_world }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#peek' do
    context 'with living cell coords' do
      it 'returns 1' do
        expect(the_world.peek(1, 0)).to be(1)
      end
    end

    context 'with dead cell coords' do
      it 'returns 0' do
        expect(the_world.peek(3, 1)).to be(0)
      end
    end

    context 'with an out of bounds cell coords' do
      it 'raises ArgumentError' do
        expect { the_world.peek(the_world.width + 1, 1) }.to raise_error(ArgumentError)
      end
    end
  end
end
