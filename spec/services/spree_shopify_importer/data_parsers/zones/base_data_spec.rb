require "spec_helper"

RSpec.describe SpreeShopifyImporter::DataParsers::Zones::BaseData do
  subject { described_class.new(shopify_object, parent_object, spree_zone_kind) }

  let(:shopify_object) { build_stubbed(:shopify_country) }
  let(:parent_object) { build_stubbed(:shopify_shipping_zone) }
  let(:spree_zone_kind) { "country" }

  describe "#attributes" do
    let(:tax_category) { create(:tax_category, name: "GENERAL PROFILE/18869387313") }

    before do
      tax_category
    end

    context "with sample shopify_shipping_zone" do
      let(:zone_attributes) do
        {
          name: "#{parent_object.name}/#{shopify_object.name}/#{tax_category.name.split("/").first}",
          kind: spree_zone_kind,
          description: "Shopify shipping to #{shopify_object.name}"
        }
      end

      it "prepares hash of attributes" do
        expect(subject.attributes).to eq(zone_attributes)
      end
    end
  end
end
