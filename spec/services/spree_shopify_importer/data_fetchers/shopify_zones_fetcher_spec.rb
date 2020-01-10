require 'spec_helper'

RSpec.describe SpreeShopifyImporter::DataFetchers::ShopifyZonesFetcher do
  subject { described_class.new }

  before { authenticate_with_shopify }

  describe '#import!', vcr: { cassette_name: 'shopify_import/shipping_zones_importer/import' } do
    it 'enqueue a zone importer job' do
      expect { subject.import! }.to have_enqueued_job(SpreeShopifyImporter::Importers::ShopifyZoneImporterJob).twice
    end
  end
end
