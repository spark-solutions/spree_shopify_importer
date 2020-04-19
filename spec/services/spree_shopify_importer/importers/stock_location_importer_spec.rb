require "spec_helper"

describe SpreeShopifyImporter::Importers::StockLocationImporter, type: :service do
  subject { described_class.new(resource) }

  before { authenticate_with_shopify }

  describe "#import!", vcr: { cassette_name: "shopify/base_stock_location" } do
    let(:resource) { shopify_location.to_json }
    let(:shopify_location) { ShopifyAPI::Location.first }

    let(:shopify_object) { ShopifyAPI::Location.new(JSON.parse(resource)) }

    before do
      expect(ShopifyAPI::Location).to receive(:new).with(JSON.parse(resource)).and_return(shopify_object)
    end

    context "without existing data feed" do
      let(:data_feed_without_spree_object) { build_stubbed(:shopify_data_feed, spree_object_id: nil) }
      let(:data_feeds_create) { instance_double(SpreeShopifyImporter::DataFeeds::Create) }
      let(:stock_location_creator) { instance_double(SpreeShopifyImporter::DataSavers::StockLocations::StockLocationCreator) }

      it "creates shopify data feeds" do
        expect(SpreeShopifyImporter::DataFeeds::Create).to receive(:new).with(shopify_object).and_return(data_feeds_create)
        expect(data_feeds_create).to receive(:save!).and_return(data_feed_without_spree_object)
        expect(SpreeShopifyImporter::DataSavers::StockLocations::StockLocationCreator).to receive(:new).with(data_feed_without_spree_object).and_return(stock_location_creator)
        expect(stock_location_creator).to receive(:create!)

        subject.import!
      end
    end

    context "with existing data feed" do
      let(:shopify_data_feed_with_spree_object) { build_stubbed(:shopify_data_feed, spree_object: stock_location) }
      let(:stock_location) { build_stubbed(:stock_location) }
      let(:data_feeds_update) { instance_double(SpreeShopifyImporter::DataFeeds::Update) }
      let(:stock_location_updater) { instance_double(SpreeShopifyImporter::DataSavers::StockLocations::StockLocationUpdater) }

      it "does not create shopify data feeds" do
        expect(SpreeShopifyImporter::DataFeed).to receive(:find_by)
          .with(shopify_object_id: shopify_object.id, shopify_object_type: shopify_object.class.to_s)
          .and_return(shopify_data_feed_with_spree_object)
        expect(SpreeShopifyImporter::DataFeeds::Update).to receive(:new).with(shopify_data_feed_with_spree_object, shopify_object).and_return(data_feeds_update)
        expect(data_feeds_update).to receive(:update!).and_return(shopify_data_feed_with_spree_object)
        expect(SpreeShopifyImporter::DataSavers::StockLocations::StockLocationUpdater).to receive(:new)
          .with(shopify_data_feed_with_spree_object, stock_location)
          .and_return(stock_location_updater)
        expect(stock_location_updater).to receive(:update!)

        subject.import!
      end
    end
  end
end
