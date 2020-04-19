require "spec_helper"

RSpec.describe SpreeShopifyImporter::DataFetchers::ShopFetcher do
  subject { described_class.new }

  before { authenticate_with_shopify }

  describe "#import!", vcr: { cassette_name: "shopify_import/data_fetchers/shop" } do
    it "enqueue a shop importer job" do
      expect { subject.import! }.to have_enqueued_job(SpreeShopifyImporter::Importers::ShopImporterJob).once
    end
  end
end
