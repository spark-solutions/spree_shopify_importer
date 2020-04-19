require "spec_helper"

describe SpreeShopifyImporter::Importers::OrderImporter, type: :service do
  subject { described_class.new(resource) }

  before { authenticate_with_shopify }

  after { ShopifyAPI::Base.clear_session }

  describe "#import!", vcr: { cassette_name: "shopify_import/importers/order_importer" } do
    let(:resource) { shopify_order.to_json }
    let(:shopify_order) { ShopifyAPI::Order.find(5_182_437_124) }
    let(:user) { create(:user) }
    let(:user_data_feed) do
      create(:shopify_data_feed,
             spree_object: user,
             shopify_object_id: shopify_order.customer.id,
             shopify_object_type: "ShopifyAPI::Customer")
    end

    before do
      user_data_feed
      shopify_order.line_items.each do |line_item|
        create(:shopify_data_feed,
               spree_object: create(:variant),
               shopify_object_type: "ShopifyAPI::Variant",
               shopify_object_id: line_item.variant_id)
      end
    end

    it "creates shopify data feeds" do
      expect { subject.import! }.to change(SpreeShopifyImporter::DataFeed, :count).by(5)
    end

    it "creates spree orders" do
      expect { subject.import! }.to change(Spree::Order, :count).by(1)
    end
  end
end
