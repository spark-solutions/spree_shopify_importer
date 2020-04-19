require "spec_helper"

RSpec.describe SpreeShopifyImporter::DataFetchers::StockLocationsFetcher do
  subject { described_class.new }

  describe "#import!" do
    it "enqueue a stock_location importer job" do
      expect { subject.import! }.to have_enqueued_job(SpreeShopifyImporter::Importers::StockLocationImporterJob).once
    end
  end
end
