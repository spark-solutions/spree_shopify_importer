require "spec_helper"

describe SpreeShopifyImporter::DataParsers::Taxons::BaseData, type: :service do
  subject { described_class.new(shopify_custom_collection) }

  let(:shopify_custom_collection) { build_stubbed(:shopify_custom_collection) }

  describe "#attributes" do
    let(:result) do
      {
        name: shopify_custom_collection.title,
        permalink: shopify_custom_collection.handle,
        description: shopify_custom_collection.body_html
      }
    end

    it "returns hash of attributes" do
      expect(subject.attributes).to eq result
    end
  end

  describe "#product_ids" do
    let(:shopify_product) { build_stubbed(:shopify_product) }
    let(:spree_product) { build_stubbed(:product) }

    let(:shopify_data_feed) do
      create(:shopify_data_feed,
             spree_object: spree_product,
             shopify_object_id: shopify_product.id,
             shopify_object_type: shopify_product.class.to_s)
    end

    before do
      shopify_data_feed
      expect(shopify_custom_collection).to receive(:products).and_return([shopify_product])
    end

    it "returns array of products ids" do
      expect(subject.product_ids).to contain_exactly(spree_product.id)
    end
  end

  describe "#taxonomy" do
    context "when taxonomy is not exists" do
      it "creates spree taxonomy" do
        expect { subject.taxonomy }.to change(Spree::Taxonomy, :count).by(1)
      end
    end

    context "when taxonomy already exists" do
      it "assigns proper name to taxonomy" do
        expect(subject.taxonomy.name).to eq I18n.t("shopify_custom_collections")
      end
    end
  end
end
