require "spec_helper"

feature "end to end import" do
  include ActiveJob::TestHelper

  subject do
    SpreeShopifyImporter::Invoker.new(
      credentials: {
        api_key: "0a9445b7b067719a0af024610364ee34", password: "800f97d6ea1a768048851cdd99a9101a",
        shop_domain: "spree-shopify-importer-test-store.myshopify.com", api_version: "2019-10"
      }
    )
  end

  let(:country) do
    create(:country,
           name: "Croatia",
           iso_name: "CROATIA",
           iso: "HR",
           iso3: "HRV")
  end

  describe "import!" do
    before do
      country
    end

    it "imports successfully" do
      perform_enqueued_jobs do
        subject.import!
      end

      aggregate_failures "items creation" do
        expect(Spree::StockLocation.count).to eq 2
        expect(Spree::Product.count).to eq 2
        expect(Spree::Variant.count).to eq 4
        expect(Spree::TaxCategory.count).to eq 1
        expect(Spree.user_class.count).to eq 3
        expect(Spree::Taxonomy.count).to eq 1
        expect(Spree::Taxon.count).to eq 3
        expect(Spree::Order.count).to eq 1
        expect(Spree::LineItem.count).to eq 2
        expect(Spree::Payment.count).to eq 1
        expect(Spree::Shipment.count).to eq 3
        expect(Spree::ShippingRate.count).to eq 3
        expect(Spree::InventoryUnit.count).to eq 8
        expect(Spree::Address.count).to eq 8
        expect(Spree::ReturnAuthorization.count).to eq 1
        expect(Spree::ReturnItem.count).to eq 1
        expect(Spree::CustomerReturn.count).to eq 1
        expect(Spree::Reimbursement.count).to eq 1
        expect(Spree::Refund.count).to eq 1
        expect(Spree::Zone.count).to eq 2
        expect(Spree::TaxRate.count).to eq 2
        expect(Spree::ShippingCategory.count).to eq 2
        expect(Spree::ShippingMethod.count).to eq 4
      end
    end

    it "multiple imports successfully" do
      perform_enqueued_jobs do
        subject.import!
        subject.import!
      end

      aggregate_failures "items creation" do
        expect(Spree::StockLocation.count).to eq 2
        expect(Spree::Product.count).to eq 2
        expect(Spree::Variant.count).to eq 4
        expect(Spree::TaxCategory.count).to eq 1
        expect(Spree.user_class.count).to eq 3
        expect(Spree::Taxonomy.count).to eq 1
        expect(Spree::Taxon.count).to eq 3
        expect(Spree::Order.count).to eq 1
        expect(Spree::LineItem.count).to eq 2
        expect(Spree::Payment.count).to eq 1
        expect(Spree::Shipment.count).to eq 3
        expect(Spree::ShippingRate.count).to eq 3
        expect(Spree::InventoryUnit.count).to eq 8
        expect(Spree::Address.count).to eq 8
        expect(Spree::ReturnAuthorization.count).to eq 1
        expect(Spree::ReturnItem.count).to eq 1
        expect(Spree::CustomerReturn.count).to eq 1
        expect(Spree::Reimbursement.count).to eq 1
        expect(Spree::Refund.count).to eq 1
        expect(Spree::Zone.count).to eq 2
        expect(Spree::TaxRate.count).to eq 2
        expect(Spree::ShippingCategory.count).to eq 2
        expect(Spree::ShippingMethod.count).to eq 4
      end
    end
  end
end
