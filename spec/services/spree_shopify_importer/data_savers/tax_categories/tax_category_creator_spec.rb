require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::TaxCategories::TaxCategoryCreator, type: :service do
  subject { described_class.new(delivery_profile) }

  let(:delivery_profile) { OpenStruct.new(name: "electronics", default: true) }

  describe "#call" do
    it "creates new tax_category by received from graphql endpoint record" do
      subject.call

      expect(Spree::TaxCategory.count).to eq(1)
      expect(Spree::TaxCategory.last.name).to eq("electronics")
    end
  end
end
