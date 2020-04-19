require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::Images::ImageCreator, type: :service do
  subject { described_class.new(shopify_data_feed, spree_object) }

  let(:shopify_data_feed) do
    create(:shopify_data_feed,
           shopify_object_type: 'ShopifyAPI::Image',
           shopify_object_id: shopify_image.id,
           data_feed: shopify_image.to_json)
  end
  let(:spree_object) { create(:product) }

  let(:spree_image) { subject.create! }

  describe '#save!', vcr: { cassette_name: 'shopify_import/creators/image_creator' } do
    let(:shopify_image) do
      create(:shopify_image,
             src: 'https://cdn.shopify.com/s/files/1/2051/3691/'\
                   'products/Screenshot_2017-03-03_14.45.16_29b97e8b-f008-460f-8733-b33d551d7140.png?v=1496631699')
    end

    context 'with spree product' do
      it_behaves_like 'create spree image'

      context 'sets associations' do
        it 'viewable object' do
          expect(spree_image.viewable).to eq spree_object.master
        end
      end
    end

    context 'with spree variant' do
      let(:spree_object) { create(:variant) }

      it_behaves_like 'create spree image'

      context 'sets associations' do
        it 'viewable object' do
          expect(spree_image.viewable).to eq spree_object
        end
      end
    end
  end
end
