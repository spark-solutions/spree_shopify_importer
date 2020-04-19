require "spec_helper"

describe SpreeShopifyImporter::DataSavers::StockLocations::StockLocationCreator, type: :service do
  subject { described_class.new(stock_location_data_feed) }

  before { authenticate_with_shopify }

  let(:spree_stock_location) { create(:stock_location) }
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
  let(:country) { build_stubbed(:country, iso: "CA", name: "Canada") }
  let(:state) { build_stubbed(:state) }
  let(:shopify_location) { build_stubbed(:shopify_location) }
  let(:stock_location_parser) { instance_double(SpreeShopifyImporter::DataParsers::StockLocations::BaseData, attributes: attributes) }
  let(:data_feed) { JSON.parse(stock_location_data_feed.data_feed) }
  let(:stock_location_data_feed) do
    build_stubbed(:shopify_data_feed, shopify_object_type: "ShopifyAPI::Location", spree_object: nil, data_feed: shopify_location.to_json)
  end

  describe "#create!" do
    before do
      expect(ShopifyAPI::Location).to receive(:new).with(data_feed).and_return(shopify_location)
      expect(SpreeShopifyImporter::DataParsers::StockLocations::BaseData).to receive(:new).with(shopify_location).and_return(stock_location_parser)
    end

    context "when create stock_location" do
      it "creates spree stock location" do
        expect(stock_location_data_feed).to receive(:update!)
        expect(shopify_location).to receive(:inventory_levels).and_return([])
        expect { subject.create! }.to change(Spree::StockLocation, :count).by(1)
      end
    end

    context "when update shopify_data_feed" do
      let(:stock_location_data_feed) do
        create(:shopify_data_feed, shopify_object_type: "ShopifyAPI::Location", spree_object: nil, data_feed: shopify_location.to_json)
      end

      it "assigns shopify data feed to spree stock location" do
        expect(Spree::StockLocation).to receive(:create!).with(attributes).and_return(spree_stock_location)
        expect(shopify_location).to receive(:inventory_levels).and_return([])
        subject.create!
        expect(stock_location_data_feed.reload.spree_object_id).to eq spree_stock_location.id
        expect(stock_location_data_feed.reload.spree_object_type).to eq spree_stock_location.class.name
      end
    end

    context "when update stock item" do
      let(:inventory_levels) { [build_stubbed(:shopify_inventory_level)] }
      let(:stock_item_attributes) do
        {
          stock_location_id: spree_stock_location.id,
          variant_id: variant.id
        }
      end
      let(:variant) { create(:variant) }
      let(:stock_item_parser) do
        instance_double(SpreeShopifyImporter::DataParsers::StockItems::BaseData,
                        stock_item_attributes: stock_item_attributes,
                        count_on_hand: 1,
                        backorderable?: true)
      end
      let(:stock_items) { Spree::StockItem.where(variant: variant, stock_location: spree_stock_location) }

      it "assigns data to spree stock items" do
        expect(Spree::StockLocation).to receive(:create!).with(attributes).and_return(spree_stock_location)
        expect(stock_location_data_feed).to receive(:update!)
        expect(shopify_location).to receive(:inventory_levels).and_return(inventory_levels)
        expect(SpreeShopifyImporter::DataParsers::StockItems::BaseData)
          .to receive(:new)
          .with(spree_stock_location, inventory_levels.first)
          .and_return(stock_item_parser).thrice
        subject.create!
        expect(stock_items.count).to eq 1
      end
    end
  end
end
