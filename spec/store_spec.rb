# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Store do
  subject(:store) { described_class.instance }

  let(:initial_state) do
    {
      'full_name' => 'John Appleseed',
      'phone' => [
        { 'type' => 'mobile', 'number' => '0000000000' },
        { 'type' => 'work', 'number' => '0000000001' }
      ],
      'org' => {
        'name' => 'ACME'
      }
    }
  end

  shared_examples 'fetches value' do
    it 'returns the value' do
      expect(store.fetch(key)).to eql(value)
    end
  end

  before { store.store = initial_state }

  describe '#fetch' do
    context 'with nil or empty string key' do
      let(:key) { '' }
      let(:value) { initial_state }

      include_examples 'fetches value'
    end

    context 'with simple string key' do
      let(:key) { 'full_name' }
      let(:value) { 'John Appleseed' }

      include_examples 'fetches value'
    end

    context 'with simple integer key' do
      let(:initial_state) { [1, 2, 3] }

      let(:key) { '0' }
      let(:value) { 1 }

      include_examples 'fetches value'
    end

    context 'with nested key' do
      context 'with only string keys' do
        let(:key) { 'org.name' }
        let(:value) { 'ACME' }

        include_examples 'fetches value'
      end

      context 'with string and integer keys' do
        let(:key) { 'phone.1.type' }
        let(:value) { 'work' }

        include_examples 'fetches value'
      end

      context 'with non-terminal path' do
        let(:key) { 'phone.1' }
        let(:value) { { 'type' => 'work', 'number' => '0000000001' } }

        include_examples 'fetches value'
      end
    end

    context 'with key to be expired' do
      let(:key) { 'phone.0' }

      before { store.expire(key, Time.now - 30) }

      it 'expires the key' do
        store.fetch(key)

        expect(store.fetch(key.split('.')[0..-2].join('.')).size).to be(1)
      end

      it 'removes the expiration record' do
        store.fetch(key)

        expect(store.expirations.key?(key)).to be false
      end
    end
  end

  shared_examples 'puts value' do
    it 'puts new value' do
      store.put(key, new_value)
      expect(store.fetch(key)).to eql(new_value)
    end

    it 'returns old value' do
      expect(store.put(key, new_value)).to eql(old_value)
    end
  end

  describe '#put' do
    context 'with nil or empty string key' do
      let(:key) { '' }
      let(:old_value) { initial_state }
      let(:new_value) { { 'a' => 'b' } }

      include_examples 'puts value'
    end

    context 'with simple string key' do
      let(:key) { 'full_name' }
      let(:old_value) { 'John Appleseed' }
      let(:new_value) { 'Tom Kovalsky' }

      include_examples 'puts value'
    end

    context 'with simple integer key' do
      let(:initial_state) { [1, 2, 3] }

      let(:key) { '0' }
      let(:old_value) { 1 }
      let(:new_value) { 'smth' }

      include_examples 'puts value'
    end

    context 'with nested key' do
      context 'with only string keys' do
        let(:key) { 'org.name' }
        let(:old_value) { 'ACME' }
        let(:new_value) { 'Generic Inc.' }

        include_examples 'puts value'
      end

      context 'with string and integer keys' do
        let(:key) { 'phone.1.type' }
        let(:old_value) { 'work' }
        let(:new_value) { 'personal' }

        include_examples 'puts value'
      end

      context 'with non-terminal path' do
        let(:key) { 'phone.1' }
        let(:old_value) { { 'type' => 'work', 'number' => '0000000001' } }
        let(:new_value) { { 'type' => 'personal', 'number' => '0000000002' } }

        include_examples 'puts value'
      end

      context 'with key containing non-existing fragments' do
        let(:key) { 'org.competitors.4.name' }
        let(:new_value) { 'Evil LLC' }

        it 'raises error' do
          expect { store.put(key, new_value) }.to raise_error("key \"#{key}\" does not exist")
        end
      end
    end
  end

  shared_examples 'drops value' do
    it 'drops the value' do # rubocop:disable RSpec/MultipleExpectations
      if key.split('.').last =~ /^\d+$/
        expect { store.drop(key) }.to change { store.fetch(key.split('.')[0..-2].join('.')).size }.by(-1)
      else
        expect { store.drop(key) }.to change { store.fetch(key) }.to(nil)
      end
    end

    it 'returns old value' do
      value = store.fetch(key)
      expect(store.drop(key)).to eql(value)
    end
  end

  describe '#drop' do
    context 'with nil or empty string key' do
      let(:key) { '' }
      let(:value) { initial_state }

      include_examples 'drops value'
    end

    context 'with simple string key' do
      let(:key) { 'full_name' }
      let(:value) { 'John Appleseed' }

      include_examples 'drops value'
    end

    context 'with simple integer key' do
      let(:initial_state) { [1, 2, 3] }

      let(:key) { '0' }
      let(:value) { 1 }

      include_examples 'drops value'
    end

    context 'with nested key' do
      context 'with only string keys' do
        let(:key) { 'org.name' }
        let(:value) { 'ACME' }

        include_examples 'drops value'
      end

      context 'with string and integer keys' do
        let(:key) { 'phone.1.type' }
        let(:value) { 'work' }

        include_examples 'drops value'
      end

      context 'with non-terminal path' do
        let(:key) { 'phone.1' }
        let(:value) { { 'type' => 'work', 'number' => '0000000001' } }

        include_examples 'drops value'
      end
    end
  end

  describe '#expire' do
    let(:key) { 'phone.0' }
    let(:expire) { Time.now - 30 }

    it 'stores the expiration Time of the key' do
      store.expire(key, expire)

      expect(store.expirations[key]).to eql expire
    end
  end
end
