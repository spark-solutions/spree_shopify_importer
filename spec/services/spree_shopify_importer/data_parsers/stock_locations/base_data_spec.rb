require 'spec_helper'

RSpec.describe SpreeShopifyImporter::DataParsers::StockLocations::BaseData, type: :service do
  let(:shopify_location) { build_stubbed(:shopify_location) }
  subject { described_class.new(shopify_location) }
  let!(:country) { create(:country, iso: 'CA', name: 'Canada') }
  let!(:state) { create(:state, country: country, abbr: 'AB') }

  describe '#attributes' do
    let(:result) do
      {
        name: shopify_location.name,
        address1: shopify_location.address1,
        address2: shopify_location.address2,
        city: shopify_location.city,
        zipcode: shopify_location.zip,
        phone: shopify_location.phone,
        country: country,
        state: state,
        active: shopify_location.active
      }
    end

    it 'returns hash of attributes' do
      expect(subject.attributes).to eq result
    end
  end
end
