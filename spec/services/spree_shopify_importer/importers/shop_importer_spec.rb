require 'spec_helper'

describe SpreeShopifyImporter::Importers::ShopImporter, type: :service do
  let(:resource) { "{\"id\":20513691,\"name\":\"Spree Shopify Importer Test Store\" }" }

  subject { described_class.new(resource) }

  describe '#import!' do
    context 'without existing data feed' do
      it 'creates shopify data feeds' do
        expect { subject.import! }.to change(SpreeShopifyImporter::DataFeed, :count).by(1)
      end
    end

    context 'with existing data feed' do
      let!(:shopify_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: 205_136_91,
               shopify_object_type: 'ShopifyAPI::Shop',
               data_feed: resource, spree_object: nil)
      end

      it 'does not create shopify data feeds' do
        expect { subject.import! }.not_to change(SpreeShopifyImporter::DataFeed, :count)
      end
    end
  end
end
