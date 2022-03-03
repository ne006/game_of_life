# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GameOfLife::World do
  subject(:the_world) { described_class.new(cells: gen0) }

  let(:gen0) do
    [[1, 1, 1, 0],
     [0, 0, 0, 0],
     [1, 0, 1, 0],
     [0, 0, 0, 0]]
  end

  let(:gen1) do
    [[0, 1, 0, 0],
     [1, 0, 1, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0]]
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

    it 'parses rulestring and set the rules' do
      expect(the_world.rules).to eql({ survive: [2, 3], birth: [3] })
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

  describe '#tick' do
    it "advances world's state" do
      the_world.tick

      expect(the_world.cells).to eql(gen1)
    end

    it "increments the world's generation" do
      expect { the_world.tick }.to change(the_world, :generation).by(1)
    end

    it 'deposits just discarded cells into geology' do
      gen0 = the_world.cells

      the_world.tick

      expect(the_world.cells(generation: 0)).to eql(gen0)
    end

    context 'when passing generation number' do
      it 'ticks the needed times' do
        init_gen_num = the_world.generation

        the_world.tick(to: 5)

        expect(the_world.generation).to eql(5 - init_gen_num)
      end
    end
  end

  describe '#cells' do
    before { the_world.tick }

    let(:current_generation) { 1 }

    context 'without generation' do
      it 'returns current generation cells' do
        expect(the_world.cells).to eql(gen1)
      end
    end

    context 'with current generation' do
      it 'returns current generation cells' do
        expect(the_world.cells(generation: current_generation)).to eql(gen1)
      end
    end

    context 'with specified generation' do
      it 'returns the specified generation cells from geology' do
        expect(the_world.cells(generation: 0)).to eql(gen0)
      end
    end
  end
end
