require "spec_helper"

RSpec.describe SpreeShopifyImporter::Connections::ShippingZone, type: :module do
  subject { described_class }

  before { authenticate_with_shopify }

  describe ".all", vcr: { cassette_name: "shopify/zone/all" } do
    it "finds all zones in Shopify" do
      expect(subject.all.length).to eq 2
    end
  end
end
