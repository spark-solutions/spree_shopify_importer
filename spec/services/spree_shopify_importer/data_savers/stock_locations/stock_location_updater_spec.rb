require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::StockLocations::StockLocationUpdater, type: :service do
  subject { described_class.new(shopify_data_feed, spree_stock_location) }

  before { authenticate_with_shopify }

  describe '#update!', vcr: { cassette_name: 'shopify/base_stock_location' } do
    let(:shopify_location) { ShopifyAPI::Location.first }
    let!(:shopify_data_feed) do
      create(:shopify_data_feed,
             shopify_object_id: shopify_location.id,
             shopify_object_type: shopify_location.class.name,
             data_feed: shopify_location.to_json,
             spree_object: spree_stock_location)
    end
    let(:spree_stock_location) { create(:stock_location) }

    it 'does not create spree stock_location' do
      expect { subject.update! }.not_to change(Spree::StockLocation, :count)
    end

    it 'updates spree stock location' do
      subject.update!
      expect(shopify_data_feed.reload.spree_object).to eq spree_stock_location
    end
  end
end
