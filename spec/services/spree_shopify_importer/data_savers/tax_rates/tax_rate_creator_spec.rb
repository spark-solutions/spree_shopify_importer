require "spec_helper"

describe SpreeShopifyImporter::DataSavers::TaxRates::TaxRateCreator, type: :service do
  subject { described_class.new(spree_zone, shopify_object) }

  let(:spree_zone) { create(:zone, name: "Domestic/Poland/GENERAL PROFILE") }
  let(:shopify_object) { build_stubbed(:shopify_country) }

  describe "#create!" do
    let(:tax_category) { create(:tax_category, name: "GENERAL PROFILE/18869387313") }
    let(:calculator) { Spree::Calculator::ShopifyTax.last }
    let(:shop_data_feed) do
      create(:shopify_data_feed,
             shopify_object_type: "ShopifyAPI::Shop",
             data_feed: '{"taxes_included":true}')
    end

    before do
      shop_data_feed
      tax_category
    end

    it "creates tax rate" do
      expect { subject.create! }.to change(Spree::TaxRate, :count).by(1)
    end

    it "creates shopify tax calculator" do
      expect { subject.create! }.to change(Spree::Calculator::ShopifyTax, :count).by(1)
    end

    context "sets a tax rate attributes" do
      before { subject.create! }
      let(:tax_rate) { Spree::TaxRate.last }

      it "name" do
        expect(tax_rate.name).to eq "Shopify/#{shopify_object.name}/#{tax_category.name.split('/').first}"
      end

      it "amount" do
        expect(tax_rate.amount).to eq shopify_object.tax
      end

      it "included_in_price" do
        expect(tax_rate.included_in_price).to eq JSON.parse(shop_data_feed.data_feed)["taxes_included"]
      end

      it "show_rate_in_label" do
        expect(tax_rate.show_rate_in_label).to eq false
      end
    end

    context "sets a tax rate associations" do
      before { subject.create! }
      let(:tax_rate) { Spree::TaxRate.last }

      it "zone" do
        expect(tax_rate.zone).to eq spree_zone
      end

      it "tax category" do
        expect(tax_rate.tax_category).to eq tax_category
      end

      it "calculator" do
        expect(tax_rate.calculator).to eq calculator
      end
    end
  end
end
