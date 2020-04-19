require "spec_helper"

describe SpreeShopifyImporter::DataSavers::LineItems::LineItemCreator, type: :service do
  subject { described_class.new(shopify_line_item, shopify_order, spree_order) }

  let(:spree_order) { create(:order) }

  before { authenticate_with_shopify }

  after { ShopifyAPI::Base.clear_session }

  describe "#create", vcr: { cassette_name: "shopify/base_order" } do
    let(:shopify_order) { ShopifyAPI::Order.find(5_182_437_124) }
    let(:shopify_line_item) { shopify_order.line_items.first }
    let(:variant) { create(:variant) }
    let(:data_feed) do
      create(:shopify_data_feed,
             spree_object: variant,
             shopify_object_id: shopify_line_item.variant_id,
             shopify_object_type: "ShopifyAPI::Variant")
    end
    let(:line_item) { Spree::LineItem.find_by(variant_id: variant.id) }

    before do
      data_feed
    end

    it "creates spree line item" do
      expect { subject.create }.to change(Spree::LineItem, :count).by(1)
    end

    it "sets correct associations" do
      subject.create

      expect(line_item.variant).to eq variant
      expect(line_item.order).to eq spree_order
    end

    it "sets correct attributes" do
      subject.create

      expect(line_item.quantity).to eq shopify_line_item.quantity
      expect(line_item.price).to eq shopify_line_item.price.to_d
      expect(line_item.currency).to eq shopify_order.currency
      expect(line_item.adjustment_total).to eq(- shopify_line_item.total_discount.to_d)
    end
  end
end
