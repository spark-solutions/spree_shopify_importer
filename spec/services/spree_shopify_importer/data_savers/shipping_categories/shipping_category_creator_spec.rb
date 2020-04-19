require "spec_helper"

describe SpreeShopifyImporter::DataSavers::ShippingCategories::ShippingCategoryCreator, type: :service do
  let(:tax_category) { create(:tax_category) }

  subject { described_class.new(tax_category) }

  describe "#call" do
    it "creates shipping category" do
      expect { subject.call }.to change(Spree::ShippingCategory, :count).by(1)
    end

    context "sets attribute" do
      before { subject.call }

      let(:shipping_category) { Spree::ShippingCategory.last }

      it "name" do
        expect(shipping_category.name).to eq tax_category.name
      end
    end
  end
end
