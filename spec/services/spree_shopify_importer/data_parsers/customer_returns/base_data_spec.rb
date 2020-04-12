require 'spec_helper'

describe SpreeShopifyImporter::DataParsers::CustomerReturns::BaseData, type: :service do
  subject { described_class.new(shopify_refund) }

  let(:shopify_refund) { create(:shopify_refund) }

  describe '#number' do
    it 'returns customer return number' do
      expect(subject.number).to eq "SCR#{shopify_refund.id}"
    end
  end

  describe '#attributes' do
    let(:stock_location) { Spree::StockLocation.find_by!(name: I18n.t(:shopify)) }
    let(:result) do
      {
        stock_location: stock_location
      }
    end

    it 'returns hash of customer return attributes' do
      expect(subject.attributes).to eq result
    end
  end

  describe '#timestamps' do
    let(:result) do
      {
        created_at: shopify_refund.created_at.to_datetime,
        updated_at: shopify_refund.processed_at.to_datetime
      }
    end

    it 'return hash of customer return timestamps' do
      expect(subject.timestamps).to eq result
    end
  end
end
