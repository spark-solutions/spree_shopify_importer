require 'spec_helper'

describe SpreeShopifyImporter::Importers::ShopifyZoneImporterJob, type: :job do
  subject { described_class.new }

  describe '#perform' do
    let(:resource) { double('Zone') }

    it 'calls a importer service' do
      expect(SpreeShopifyImporter::Importers::ShopifyZoneImporter).to receive(:new).and_call_original
      expect_any_instance_of(SpreeShopifyImporter::Importers::ShopifyZoneImporter).to receive(:import!)

      subject.perform(resource)
    end
  end
end
