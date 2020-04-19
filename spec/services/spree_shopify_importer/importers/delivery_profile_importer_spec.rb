require "spec_helper"

describe SpreeShopifyImporter::Importers::DeliveryProfileImporter do
  subject { described_class.new(spree_product, shopify_product) }

  let(:spree_product) { build_stubbed(:product) }
  let(:shopify_product) { build_stubbed(:shopify_product_single_variant) }

  describe "#call", vcr: { cassette_name: "shopify/base_delivery_profile" } do
    let(:delivery_profile_connection) { instance_double(SpreeShopifyImporter::Connections::DeliveryProfile) }
    let(:tax_categories_saver) { instance_double(SpreeShopifyImporter::DataSavers::TaxCategories::TaxCategoryCreator) }
    let(:shipping_categories_saver) { instance_double(SpreeShopifyImporter::DataSavers::ShippingCategories::ShippingCategoryCreator) }
    let(:delivery_profile) { instance_double("delivery_profile") }
    let(:tax_category) { build_stubbed(:tax_category) }
    let(:shipping_category) { build_stubbed(:shipping_category) }

    before do
      authenticate_with_shopify
      expect(SpreeShopifyImporter::Connections::DeliveryProfile).to receive(:new).with(shopify_product.variants.first.admin_graphql_api_id).and_return(delivery_profile_connection)
      expect(delivery_profile_connection).to receive(:call).and_return(delivery_profile)
      expect(SpreeShopifyImporter::DataSavers::TaxCategories::TaxCategoryCreator).to receive(:new).with(delivery_profile).and_return(tax_categories_saver)
      expect(tax_categories_saver).to receive(:call).and_return(tax_category)
      expect(SpreeShopifyImporter::DataSavers::ShippingCategories::ShippingCategoryCreator).to receive(:new).with(tax_category).and_return(shipping_categories_saver)
      expect(shipping_categories_saver).to receive(:call).and_return(shipping_category)
    end

    it "retrieves delivery_profiles from shopify and save to spree tax_categories and shipping_categories" do
      expect(spree_product).to receive(:update!).with(tax_category: tax_category, shipping_category: shipping_category)

      subject.call
    end
  end
end
