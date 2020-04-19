require "spec_helper"

RSpec.describe SpreeShopifyImporter::Connections::CustomCollection, type: :model do
  subject { described_class }

  let(:credentials) do
    { api_key: "api_key", password: "password", shop_domain: "shop_domain.myshopify.com", api_version: "2019-10" }.freeze
  end

  before { authenticate_with_shopify }

  describe ".count", vcr: { cassette_name: "shopify/custom_collection/count" } do
    let(:result) { { "count" => 2 } }

    it "returns number of products in shopify base" do
      expect(subject.count).to eq result
    end
  end

  describe ".all", vcr: { cassette_name: "shopify/custom_collection/all" } do
    it "find all products in shopify" do
      expect(subject.all.length).to eq 2
    end
  end
end
