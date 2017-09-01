require 'spec_helper'

describe ShopifyImport::DataParsers::ReturnAuthorizations::BaseData, type: :service do
  let(:shopify_refund) { create(:shopify_refund) }
  let(:spree_order) { create(:order) }
  subject { described_class.new(shopify_refund, spree_order) }

  describe '#number' do
    let(:result) { "SRA#{shopify_refund.id}" }

    it 'returns authorization number' do
      expect(subject.number).to eq result
    end
  end

  describe '#attributes' do
    let(:stock_location) { Spree::StockLocation.last }
    let(:reason) { Spree::ReturnAuthorizationReason.last }
    let(:result) do
      {
        state: :authorized,
        memo: shopify_refund.note,
        stock_location: stock_location,
        order: spree_order,
        reason: reason
      }
    end

    it 'creates a stock location' do
      expect { subject.attributes }.to change(Spree::StockLocation, :count).by(1)
    end

    it 'creates a return authorization reason' do
      expect { subject.attributes }.to change(Spree::ReturnAuthorizationReason, :count).by(1)
    end

    it 'returns hash of return authorization attributes' do
      expect(subject.attributes).to eq result
    end
  end

  describe '#timestamps' do
    let(:result) do
      {
        created_at: '2017-01-05T15:40:07-05:00'.to_datetime,
        updated_at: '2017-01-05T15:40:07-05:00'.to_datetime
      }
    end

    it 'returns hash of return authorization timestamps' do
      expect(subject.timestamps).to eq result
    end
  end
end
