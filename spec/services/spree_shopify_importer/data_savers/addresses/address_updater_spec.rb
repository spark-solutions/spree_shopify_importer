require "spec_helper"

describe SpreeShopifyImporter::DataSavers::Addresses::AddressUpdater, type: :service do
  subject { described_class.new(shopify_data_feed, spree_address) }

  let(:shopify_data_feed) do
    build_stubbed(:shopify_data_feed,
                  shopify_object_id: shopify_address.id,
                  shopify_object_type: "ShopifyAPI::Address",
                  data_feed: shopify_address.to_json)
  end
  let(:spree_address) { create(:address) }

  describe "#update!" do
    let(:shopify_address) { build_stubbed(:shopify_address) }
    let(:parser) { instance_double(SpreeShopifyImporter::DataParsers::Addresses::BaseData) }
    let(:state) { build_stubbed(:state) }
    let(:country) { build_stubbed(:country) }
    let(:attributes) do
      {
        firstname: shopify_address.first_name,
        lastname: shopify_address.last_name,
        address1: shopify_address.address1,
        address2: shopify_address.address2,
        company: shopify_address.company,
        phone: shopify_address.phone,
        city: shopify_address.city,
        zipcode: shopify_address.zip,
        state: state,
        country: country
      }
    end

    before do
      expect(ShopifyAPI::Address).to receive(:new).with(JSON.parse(shopify_address.to_json)).and_return(shopify_address)
      expect(SpreeShopifyImporter::DataParsers::Addresses::BaseData).to receive(:new).with(shopify_address).and_return(parser)
      expect(parser).to receive(:attributes).and_return(attributes)
    end

    it "sets correct attributes" do
      subject.update!

      expect(spree_address.firstname).to eq shopify_address.first_name
      expect(spree_address.lastname).to eq shopify_address.last_name
      expect(spree_address.address1).to eq shopify_address.address1
      expect(spree_address.address2).to eq shopify_address.address2
      expect(spree_address.company).to eq shopify_address.company
      expect(spree_address.city).to eq shopify_address.city
      expect(spree_address.phone).to eq shopify_address.phone
      expect(spree_address.zipcode).to eq shopify_address.zip
      expect(spree_address.state.id).to eq state.id
      expect(spree_address.country.id).to eq country.id
    end
  end
end
