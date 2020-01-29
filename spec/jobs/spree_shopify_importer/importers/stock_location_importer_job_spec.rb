require 'spec_helper'

describe SpreeShopifyImporter::Importers::StockLocationImporterJob, type: :job do
  subject { described_class.new }

  describe '#perfrom' do
    let(:resource) { double('ShopifyLocation') }

    it 'calls a importer service' do
      expect(SpreeShopifyImporter::Importers::StockLocationImporter).to receive(:new).and_call_original
      expect_any_instance_of(SpreeShopifyImporter::Importers::StockLocationImporter).to receive(:import!)

      subject.perform(resource)
    end
  end
end
