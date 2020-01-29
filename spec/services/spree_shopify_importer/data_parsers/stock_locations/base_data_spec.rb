require 'spec_helper'

RSpec.describe SpreeShopifyImporter::DataParsers::StockLocations::BaseData, type: :service do
  subject { described_class.new(shopify_location) }
  before do
    expect(Spree::Country).to receive(:find_by).with(iso: 'CA', name: 'Canada').and_return(country)
    expect(Spree::State).to receive(:find_by).with(country_id: country.id, abbr: 'AB').and_return(state)
  end

  let(:shopify_location) { build_stubbed(:shopify_location) }
  let!(:country) { build_stubbed(:country, iso: 'CA', name: 'Canada') }
  let!(:state) { build_stubbed(:state, country: country, abbr: 'AB') }

  describe '#attributes' do
    let(:result) do
      {
        name: "#{shopify_location.name}/#{shopify_location.id}",
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
