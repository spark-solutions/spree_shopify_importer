require 'spec_helper'

describe SpreeShopifyImporter::Importers::DeliveryProfileImporter do
  subject { described_class.new(spree_variant, shopify_variant) }

  let(:spree_variant) { build_stubbed(:variant) }
  let(:shopify_variant) { build_stubbed(:shopify_variant) }
  before { authenticate_with_shopify }

  describe "#call", vcr: { cassette_name: 'shopify/base_delivery_profile' } do
    let(:delivery_profile_connection) { instance_double(SpreeShopifyImporter::Connections::DeliveryProfile) }
    let(:tax_categories_saver) { instance_double(SpreeShopifyImporter::DataSavers::TaxCategories::TaxCategoryCreator) }
    let(:delivery_profile) { instance_double("delivery_profile") }
    let(:tax_category) { build_stubbed(:tax_category) }

    before do
      expect(SpreeShopifyImporter::Connections::DeliveryProfile).to receive(:new).with(shopify_variant.admin_graphql_api_id).and_return(delivery_profile_connection)
      expect(delivery_profile_connection).to receive(:call).and_return(delivery_profile)
      expect(SpreeShopifyImporter::DataSavers::TaxCategories::TaxCategoryCreator).to receive(:new).with(delivery_profile).and_return(tax_categories_saver)
      expect(tax_categories_saver).to receive(:call).and_return(tax_category)
    end

    it "retrieves delivery_profiles from shopify and save to spree tax_categories" do
      expect(spree_variant).to receive(:update!).with(tax_category: tax_category)

      subject.call
    end
  end
end
