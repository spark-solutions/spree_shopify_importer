require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::StockLocations::StockLocationUpdater, type: :service do
  subject { described_class.new(stock_location_data_feed, spree_stock_location) }
  before do
    authenticate_with_shopify
    expect(ShopifyAPI::Location).to receive(:new).with(data_feed).and_return(shopify_location)
    expect(SpreeShopifyImporter::DataParsers::StockLocations::BaseData).to receive(:new).with(shopify_location).and_return(stock_location_parser)
    expect(shopify_location).to receive(:inventory_levels).and_return([])
  end

  let(:stock_location_data_feed) do
    create(:shopify_data_feed, shopify_object_type: 'ShopifyAPI::Location', spree_object: spree_stock_location, data_feed: shopify_location.to_json)
  end
  let(:spree_stock_location) { create(:stock_location, name: 'Shopify') }
  let(:shopify_location) { build_stubbed(:shopify_location) }
  let(:attributes) do
    {
      name: "#{shopify_location.name}/#{shopify_location.id}",
      address1: shopify_location.address1,
      address2: shopify_location.address2,
      city: shopify_location.city,
      zipcode: shopify_location.zip,
      phone: shopify_location.phone,
      country: country,
      state: state,
      active: shopify_location.active
    }
  end
  let(:country) { build_stubbed(:country, iso: 'CA', name: 'Canada') }
  let(:state) { build_stubbed(:state) }

  let(:stock_location_parser) { instance_double(SpreeShopifyImporter::DataParsers::StockLocations::BaseData, attributes: attributes) }
  let(:data_feed) { JSON.parse(stock_location_data_feed.data_feed) }

  describe '#update!' do
    it 'does not create spree stock_location' do
      expect { subject.update! }.not_to change(Spree::StockLocation, :count)
    end

    it 'updates spree stock location' do
      expect(stock_location_data_feed.reload.spree_object.name).to eq 'Shopify'
      subject.update!
      expect(stock_location_data_feed.reload.spree_object.name).to eq attributes[:name]
    end
  end
end
