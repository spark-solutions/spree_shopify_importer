require 'spec_helper'

RSpec.describe SpreeShopifyImporter::DataParsers::Zones::BaseData do
  subject { described_class.new(shopify_object, parent_object, spree_zone_kind) }
  let(:parent_object) { build_stubbed(:shopify_shipping_zone) }
  let(:shopify_object) { build_stubbed(:shopify_country) }
  let(:spree_zone_kind) { 'country' }

  describe '#attributes' do
    context 'with sample shopify_shipping_zone' do
      let(:zone_attributes) do
        {
          name: "#{parent_object.name}/#{parent_object.profile_id.split('/').last}/#{shopify_object.name}",
          kind: spree_zone_kind,
          description: "shopify shipping to #{shopify_object.name}"
        }
      end

      it 'prepares hash of attributes' do
        expect(subject.attributes).to eq(zone_attributes)
      end
    end
  end
end
