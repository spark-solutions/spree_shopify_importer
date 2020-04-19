require "spec_helper"

RSpec.describe SpreeShopifyImporter::DataParsers::Orders::StatesGetter, type: :service do
  subject { described_class.new(shopify_order) }

  describe "#order_state" do
    context "when shopify order financial status refunded" do
      let(:shopify_order) { build_stubbed(:shopify_order, financial_status: "refunded") }

      it "returns correct order state" do
        expect(subject.order_state).to eq("returned")
      end
    end

    context "when payment state pending and shipment state shipped" do
      let(:shopify_order) { build_stubbed(:shopify_order, financial_status: "pending", fulfillment_status: "fulfilled") }

      it "returns complete order state" do
        expect(subject.order_state).to eq("complete")
      end
    end
  end

  describe "#payment_state" do
    let(:shopify_order) { build_stubbed(:shopify_order, financial_status: "partially_refunded") }

    it "returns correct payment state by mapping" do
      expect(subject.payment_state).to eq("paid")
    end
  end

  describe "#shipment_state" do
    context "when paid unfulfilled order" do
      let(:shopify_order) { build_stubbed(:shopify_order, fulfillment_status: nil, financial_status: "paid") }

      it "returns correct shipment state for unfulfilled paid shopify order" do
        expect(subject.shipment_state).to eq("ready")
      end
    end

    context "when pending unfulfilled order" do
      let(:shopify_order) { build_stubbed(:shopify_order, fulfillment_status: nil, financial_status: "pending") }

      it "returns correct shipment state for unfulfilled paid shopify order" do
        expect(subject.shipment_state).to eq("pending")
      end
    end
  end
end
