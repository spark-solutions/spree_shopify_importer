require "spec_helper"

RSpec.describe SpreeShopifyImporter::DataParsers::StockItems::BaseData, type: :service do
  subject { described_class.new(spree_stock_location, shopify_inventory_level) }

  let(:spree_stock_location) { build_stubbed(:stock_location) }
  let(:shopify_inventory_level) { build_stubbed(:shopify_inventory_level, inventory_item_id: shopify_variant.inventory_item_id) }
  let(:shopify_variant) { build_stubbed(:shopify_variant) }
  let(:spree_variant) { build_stubbed(:variant) }
  let(:variant_data_feed) do
    build_stubbed(:shopify_data_feed,
                  shopify_object_id: shopify_variant.id,
                  shopify_object_type: shopify_variant.class.name,
                  data_feed: shopify_variant.to_json,
                  spree_object: spree_variant)
  end

  describe "#stock_item_attributes" do
    let(:result) do
      {
        stock_location_id: spree_stock_location.id,
        variant_id: spree_variant.id
      }
    end

    before do
      expect(SpreeShopifyImporter::DataFeed).to receive_message_chain(:where, :where).and_return([variant_data_feed])
      expect(Spree::Variant).to receive(:find).with(variant_data_feed.spree_object_id).and_return(spree_variant)
    end

    it "returns hash of attributes" do
      expect(subject.stock_item_attributes).to eq result
    end
  end

  describe "#backorderable?" do
    before do
      expect(SpreeShopifyImporter::DataFeed).to receive_message_chain(:where, :where).and_return([variant_data_feed])
    end

    context "shopify variant has inventory_policy == deny" do
      let(:shopify_variant) { build_stubbed(:shopify_variant, inventory_policy: "deny") }

      it "returns false" do
        expect(subject).not_to be_backorderable
      end
    end

    context "shopify variant has inventory_policy == continue" do
      let(:shopify_variant) { build_stubbed(:shopify_variant, inventory_policy: "continue") }

      it "returns true" do
        expect(subject).to be_backorderable
      end
    end

    context "shopify variant has inventory_policy other than continue" do
      let(:shopify_variant) { build_stubbed(:shopify_variant, inventory_policy: "other") }

      it "returns true" do
        expect(subject).not_to be_backorderable
      end
    end
  end

  context "#count_on_hand" do
    it "returns current count_on_hand quantity" do
      expect(subject.count_on_hand).to eq 10
    end
  end
end
