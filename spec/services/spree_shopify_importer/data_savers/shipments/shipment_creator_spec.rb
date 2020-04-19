require "spec_helper"

describe SpreeShopifyImporter::DataSavers::Shipments::ShipmentCreator, type: :service do
  subject { described_class.new(shopify_data_feed, parent_data_feed, spree_order) }
  before  { authenticate_with_shopify }
  after   { ShopifyAPI::Base.clear_session }

  describe "#create!", vcr: { cassette_name: "shopify/base_order" } do
    let(:shopify_order) { ShopifyAPI::Order.find(5_182_437_124) }
    let(:shopify_fulfillment) { shopify_order.fulfillments.first }
    let(:spree_order) { create(:order) }
    let(:parent_data_feed) do
      create(:shopify_data_feed,
             shopify_object_id: shopify_order.id,
             shopify_object_type: "ShopifyAPI::Order",
             spree_object: spree_order,
             data_feed: shopify_order.to_json)
    end
    let(:shopify_data_feed) do
      create(:shopify_data_feed,
             shopify_object_id: shopify_fulfillment.id,
             shopify_object_type: "ShopifyAPI::Fulfillment",
             data_feed: shopify_fulfillment.to_json)
    end
    let(:spree_shipment) { Spree::Shipment.last }

    it "creates spree shipment" do
      expect { subject.create! }.to change(Spree::Shipment, :count).by(1)
    end

    context "sets shipment attributes" do
      before { subject.create! }

      it "number" do
        expect(spree_shipment.number).to eq "SH#{shopify_fulfillment.id}"
      end

      it "state" do
        expect(spree_shipment.state).to eq "shipped"
      end

      it "tracking" do
        expect(spree_shipment.tracking).to eq "21123123123213"
      end
    end

    context "sets associations" do
      let(:stock_location) { Spree::StockLocation.find_by(name: I18n.t(:shopify)) }
      let(:spree_shipping_rate) { Spree::ShippingRate.last }
      let(:spree_invetory_units) { Spree::InventoryUnit.all }

      before { subject.create! }

      it "spree order" do
        expect(spree_shipment.order).to eq spree_order
      end

      it "stock location" do
        expect(spree_shipment.stock_location).to eq stock_location
      end

      it "inventory units" do
        expect(spree_shipment.inventory_units).to match_array(spree_invetory_units)
      end

      it "shipping rates" do
        expect(spree_shipment.shipping_rates).to contain_exactly(spree_shipping_rate)
      end
    end
  end
end
