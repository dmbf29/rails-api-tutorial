require 'rails_helper'

RSpec.describe Cafe, type: :model do
  let(:cafe) { Cafe.new(title: 'cafe', address: '2-11-3 Meguro, Meguro-ku, Tokyo 153-0063') }

  describe '#initialize' do
    context 'when valid' do
      it 'returns true on #valid?' do
        expect(cafe.valid?).to eq(true)
      end
    end

    context 'without title' do
      before do
        cafe.title = nil
      end

      it 'returns false on #valid?' do
        expect(cafe.valid?).to eq(false)
      end

      it 'returns an error message' do
        cafe.valid?
        expect(cafe.errors.messages).to eq({ title: ["can't be blank"] })
      end
    end

    context 'without address' do
      before do
        cafe.address = nil
      end

      it 'returns false on #valid?' do
        expect(cafe.valid?).to eq(false)
      end

      it 'returns an error message' do
        cafe.valid?
        expect(cafe.errors.messages).to eq({ address: ["can't be blank"] })
      end
    end
  end
end
