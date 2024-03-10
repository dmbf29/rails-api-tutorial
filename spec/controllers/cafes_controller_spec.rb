require 'rails_helper'

RSpec.describe Api::V1::CafesController, type: :controller do
  describe 'POST #create' do
    let(:address) { '2-11-3 Meguro, Meguro-ku, Tokyo 153-0063' }

    before do
      post :create, params: { cafe: { title: 'Le Wagon Tokyo', address: address } }
    end

    context 'with correct params' do
      it 'creates a cafe' do
        expect(Cafe.find_by(title: 'Le Wagon Tokyo').address).to eq('2-11-3 Meguro, Meguro-ku, Tokyo 153-0063')
      end

      it 'renders the new cafe as JSON' do
        new_cafe = JSON.parse(response.body)
        expect(new_cafe['title']).to eq('Le Wagon Tokyo')
      end
    end

    context 'with incorrect params' do
      let(:address) { nil }

      it 'skips cafe creation' do
        expect(Cafe.count).to eq(0)
      end

      it 'returns error status' do
        expect(response.status).to eq(422)
      end
    end
  end
end
