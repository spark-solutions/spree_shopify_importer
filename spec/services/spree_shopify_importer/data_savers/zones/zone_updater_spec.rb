require "spec_helper"

describe SpreeShopifyImporter::DataSavers::Zones::ZoneUpdater, type: :service do
  include ActiveJob::TestHelper

  subject { described_class.new(shopify_object, parent_object, spree_zone, shipping_methods) }

  before { authenticate_with_shopify }

  describe "#update!" do
    context "with country shipping_zone data feed", vcr: { cassette_name: "shopify/base_country_zone" } do
      let(:shopify_shipping_zone) { ShopifyAPI::ShippingZone.first }
      let(:shipping_zone_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: shopify_shipping_zone.id,
               shopify_object_type: shopify_shipping_zone.class.name,
               data_feed: shopify_shipping_zone.to_json)
      end
      let(:old_zone_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: 516_252_868,
               shopify_object_type: "ShopifyAPI::Country",
               parent_id: shipping_zone_data_feed.id)
      end
      let(:country) { create(:country, iso: "HR") }
      let(:spree_zone) { create(:zone, name: "Domestic/Croatia/GENERAL PROFILE", kind: "country") }
      let(:old_spree_zone_member) { create(:zone_member, zoneable: country, zone: spree_zone) }
      let(:parent_object) { shopify_shipping_zone }
      let(:shopify_object) { parent_object.countries.first }
      let(:new_spree_zone_member) do
        Spree::ZoneMember.find_by!(
          zoneable_type: "Spree::Country",
          zoneable_id: country.id,
          zone_id: spree_zone.id
        )
      end

      let(:tax_category) { create(:tax_category, name: "GENERAL PROFILE/18869387313") }
      let(:shop_data_feed) do
        create(:shopify_data_feed,
               shopify_object_type: "ShopifyAPI::Shop",
               data_feed: '{"taxes_included":true}')
      end
      let(:shipping_methods) { [create(:shipping_method, zones: [])] }

      before do
        shop_data_feed
        tax_category
        old_spree_zone_member
        spree_zone
        country
        old_zone_data_feed
      end

      it "does not create spree zone" do
        expect { subject.update! }.not_to change(Spree::Zone, :count)
      end

      it "updates spree zone" do
        expect(spree_zone.description).not_to eq("Shopify shipping to #{shopify_object.name}")
        subject.update!
        expect(spree_zone.description).to eq("Shopify shipping to #{shopify_object.name}")
      end

      it "destroys old spree zone member" do
        subject.update!
        expect(spree_zone.members.count).to eq 1
        expect(new_spree_zone_member).not_to eq(old_spree_zone_member)
      end

      it "creates spree zone member" do
        subject.update!
        expect(spree_zone.members.count).to eq 1
        expect(spree_zone.reload.members.first).to eq new_spree_zone_member
      end

      it "creates or updates tax rate" do
        subject.update!
        expect(tax_category.tax_rates.first.zone).to eq spree_zone
      end

      it "assigns zone to shipping methods" do
        subject.update!
        expect(shipping_methods.first.zones.last).to eq spree_zone
      end
    end
  end
end
