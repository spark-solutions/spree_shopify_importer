require 'spec_helper'

describe SpreeShopifyImporter::DataParsers::TaxRates::BaseData, type: :service do
  subject { described_class.new(spree_zone, shopify_object) }

  describe '#attributes' do
    let(:shopify_object) { build_stubbed(:shopify_country) }
    let(:spree_zone) { build_stubbed(:zone, name: 'Domestic/Poland/GENERAL PROFILE') }
    let(:tax_category) { create(:tax_category, name: 'GENERAL PROFILE/18869387313') }
    let(:calculator) { Spree::Calculator::ShopifyTax.last }
    let(:shop_data_feed) do
      create(:shopify_data_feed,
             shopify_object_type: 'ShopifyAPI::Shop',
             data_feed: '{"taxes_included":true}')
    end
    let(:result) do
      {
        name: "Shopify/#{shopify_object.name}/#{tax_category.name.split('/').first}",
        amount: shopify_object.tax,
        zone: spree_zone,
        tax_category: tax_category,
        included_in_price: JSON.parse(shop_data_feed.data_feed)['taxes_included'],
        show_rate_in_label: false
      }
    end

    before do
      tax_category
      shop_data_feed
    end

    it 'returns hash of tax rate attributes' do
      expect(subject.attributes).to eq result
    end
  end
end
