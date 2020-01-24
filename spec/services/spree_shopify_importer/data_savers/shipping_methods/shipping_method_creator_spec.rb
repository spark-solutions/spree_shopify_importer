require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::ShippingMethods::ShippingMethodCreator, type: :service do
  let(:shopify_rate) { shopify_shipping_zone.weight_based_shipping_rates.first }
  let(:delivery_profile_id) { shopify_shipping_zone.profile_id.split('/').last }
  let!(:shipping_category) { create(:shipping_category, name: 'GENERAL PROFILE/18869387313') }
  let!(:calculator) { create(:shipping_calculator) }
  before { authenticate_with_shopify }

  subject { described_class.new(shopify_rate, delivery_profile_id) }

  describe '#call', vcr: { cassette_name: 'shopify/base_country_zone' } do
    let(:shopify_shipping_zone) { ShopifyAPI::ShippingZone.first }

    context 'without existed shipping method' do
      it 'creates shipping category' do
        expect { subject.call }.to change(Spree::ShippingMethod, :count).by(1)
      end
    end

    context 'with existed shipping method' do
      let!(:shipping_method) do
        create(:shipping_method,
               name: 'Standard Shipping',
               display_on: 'both',
               admin_name: 'GENERAL PROFILE',
               shipping_categories: [shipping_category],
               calculator: calculator)
      end

      it 'does not create shipping category' do
        expect { subject.call }.not_to change(Spree::ShippingMethod, :count)
      end
      it 'finds existed shipping method' do
        expect(subject.call).to eq shipping_method
      end
    end
  end
end
