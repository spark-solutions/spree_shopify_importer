require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::Zones::ZoneCreator, type: :service do
  include ActiveJob::TestHelper

  subject { described_class.new(shopify_object, parent_object) }

  before { authenticate_with_shopify }

  describe '#create!' do
    context 'with country shipping_zone data feed', vcr: { cassette_name: 'shopify/base_country_zone' } do
      authenticate_with_shopify
      let(:shopify_shipping_zone) { ShopifyAPI::ShippingZone.first }
      let!(:shipping_zone_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: shopify_shipping_zone.id,
               shopify_object_type: shopify_shipping_zone.class.name,
               data_feed: shopify_shipping_zone.to_json)
      end
      let!(:zone_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: shopify_shipping_zone.countries.first.id,
               shopify_object_type: shopify_shipping_zone.countries.first.class.name,
               parent_id: shipping_zone_data_feed.id)
      end
      let!(:country) { create(:country, iso: 'HR') }
      let(:parent_object) { shopify_shipping_zone }
      let(:shopify_object) { parent_object.countries.first }
      let(:spree_zone) do
        Spree::Zone.find_by!(name: "#{parent_object.name}/#{shopify_object.name}/#{tax_category.name.split('/').first}")
      end

      let(:spree_zone_member) do
        Spree::ZoneMember.find_by!(
          zoneable_type: 'Spree::Country',
          zoneable_id: country.id,
          zone_id: spree_zone.id
        )
      end
      let!(:tax_category) { create(:tax_category, name: 'GENERAL PROFILE/18869387313') }
      let!(:shop_data_feed) do
        create(:shopify_data_feed,
               shopify_object_type: 'ShopifyAPI::Shop',
               data_feed: '{"taxes_included":true}')
      end

      it 'creates spree zone' do
        expect { subject.create! }.to change(Spree::Zone, :count).by(1)
      end

      it 'assigns shopify data feed to spree order' do
        subject.create!
        expect(zone_data_feed.reload.spree_object).to eq spree_zone
      end

      it 'creates spree zone member' do
        subject.create!
        expect(spree_zone.members.first).to eq spree_zone_member
      end
    end
  end
end
