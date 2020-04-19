require "spec_helper"

RSpec.describe SpreeShopifyImporter::Connections::Location, type: :model do
  subject { described_class }

  before { authenticate_with_shopify }

  describe ".all", vcr: { cassette_name: "shopify/location/all" } do
    it "find all locations in Shopify" do
      expect(subject.all.length).to eq 1
    end
  end
end
