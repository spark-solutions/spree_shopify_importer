require "spec_helper"

RSpec.describe SpreeShopifyImporter::Connections::Shop, type: :model do
  subject { described_class }

  before { authenticate_with_shopify }
  describe "#call", vcr: { cassette_name: "shopify/shop/call" } do
    it "find shop settings in Shopify" do
      expect(subject.new.call.name).to eq "Spree Shopify Importer Test Store"
    end
  end
end
