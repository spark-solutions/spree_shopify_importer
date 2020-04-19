require "spec_helper"

describe SpreeShopifyImporter::Importers::UserImporterJob, type: :job do
  subject { described_class.new }

  describe "#perfrom" do
    let(:resource) { double("ShopifyCustomer") }

    it "calls a importer service" do
      expect(SpreeShopifyImporter::Importers::UserImporter).to receive(:new).and_call_original
      expect_any_instance_of(SpreeShopifyImporter::Importers::UserImporter).to receive(:import!)

      subject.perform(resource)
    end
  end
end
