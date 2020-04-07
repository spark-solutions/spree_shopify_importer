require 'spec_helper'

describe SpreeShopifyImporter::Importers::ImageImporter, type: :service do
  subject { described_class.new(resource, parent_feed, spree_product) }

  let(:resource) { shopify_image.to_json }
  let(:parent_feed) { create(:shopify_data_feed) }
  let(:spree_product) { create(:product) }
  let(:shopify_image) { create(:shopify_image, sku: 'random-sku', src: valid_src) }
  let(:valid_src) { 'https://cdn.shopify.com/s/files/1/2051/3691/products/Screenshot_2017-03-03_14.45.16_29b97e8b-f008-460f-8733-b33d551d7140.png?v=1496631699' }

  describe '#import!', vcr: { cassette_name: 'shopify_import/importers/image_importer' } do
    before do
      parent_feed
    end

    it 'creates shopify data feeds' do
      expect { subject.import! }.to change(SpreeShopifyImporter::DataFeed, :count).by(1)
    end

    it 'creates spree variant' do
      expect { subject.import! }.to change(Spree::Image, :count).by(1)
    end

    context 'with existing data feed' do
      let(:shopify_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: shopify_image.id,
               shopify_object_type: shopify_image.class.to_s,
               data_feed: resource,
               spree_object: spree_object)
      end
      let(:spree_object) { nil }

      before do
        shopify_data_feed
      end

      it 'does not create shopify data feeds' do
        expect { subject.import! }.not_to change(SpreeShopifyImporter::DataFeed, :count)
      end

      it 'creates spree image' do
        expect { subject.import! }.to change(Spree::Image, :count).by(1)
      end

      context 'and image' do
        let(:spree_object) { create(:image) }

        it 'does not create shopify data feeds' do
          expect { subject.import! }.not_to change(SpreeShopifyImporter::DataFeed, :count)
        end

        it 'does not create spree image' do
          expect { subject.import! }.not_to change(Spree::Image, :count)
        end
      end
    end
  end
end
