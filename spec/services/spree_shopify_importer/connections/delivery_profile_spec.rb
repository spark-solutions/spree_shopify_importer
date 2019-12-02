require 'spec_helper'

authenticate_with_shopify

describe SpreeShopifyImporter::Connections::DeliveryProfile, type: :module do
  subject { described_class.new(product_variant.id) }

  let(:graphql_client) { instance_double(ShopifyAPI::GraphQL) }
  let(:graphql_response) { instance_double(GraphQL::Client::Response, data: "data") }
  let(:product_variant) { instance_double("spree_variant", id: 3, delivery_profile: "delivery_profile") }

  describe "#call" do
    before do
      expect(ShopifyAPI::GraphQL).to receive(:new).and_return(graphql_client)
      expect(graphql_client).to receive(:query).and_return(graphql_response)
      expect(graphql_response.data).to receive(:product_variant).and_return(product_variant)
    end

    it "calls correct query to graphql endpoint" do
      expect(subject.call).to eq("delivery_profile")
    end
  end
end
