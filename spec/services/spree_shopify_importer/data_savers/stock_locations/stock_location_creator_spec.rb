require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::StockLocations::StockLocationCreator, type: :service do
  subject { described_class.new(shopify_data_feed) }

  before { authenticate_with_shopify }

  describe '#create!', vcr: { cassette_name: 'shopify/base_stock_location' } do
    let(:shopify_location) { ShopifyAPI::Location.first }
    let(:shopify_data_feed) do
      create(:shopify_data_feed,
             shopify_object_id: shopify_location.id,
             shopify_object_type: shopify_location.class.name,
             data_feed: shopify_location.to_json,
             spree_object: nil)
    end
    let(:spree_stock_location) { Spree::StockLocation.last }

    it 'creates spree stock_location' do
      expect { subject.create! }.to change(Spree::StockLocation, :count).by(1)
    end

    it 'assigns shopify data feed to spree stock location' do
      subject.create!
      expect(shopify_data_feed.reload.spree_object).to eq spree_stock_location
    end
  end
end
