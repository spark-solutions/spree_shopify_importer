require "spec_helper"

describe SpreeShopifyImporter::Importers::ZoneImporterJob, type: :job do
  subject { described_class.new }

  describe "#perform" do
    let(:resource) { build_stubbed(:country) }
    let(:parent_object) { double("ShopifyZone") }
    let(:shipping_methods) { [build_stubbed(:shipping_method)] }

    it "calls a importer service" do
      expect(SpreeShopifyImporter::Importers::ZoneImporter).to receive(:new).and_call_original
      expect_any_instance_of(SpreeShopifyImporter::Importers::ZoneImporter).to receive(:import!)

      subject.perform([resource.to_json], parent_object.to_json, shipping_methods)
    end
  end
end
