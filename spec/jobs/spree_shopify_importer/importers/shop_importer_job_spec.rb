require "spec_helper"

describe SpreeShopifyImporter::Importers::ShopImporterJob, type: :job do
  subject { described_class.new }

  describe "#perfrom" do
    let(:resource) { double("ShopifyAPI::Shop") }

    it "calls a importer service" do
      expect(SpreeShopifyImporter::Importers::ShopImporter).to receive(:new).and_call_original
      expect_any_instance_of(SpreeShopifyImporter::Importers::ShopImporter).to receive(:import!)

      subject.perform(resource)
    end
  end
end
