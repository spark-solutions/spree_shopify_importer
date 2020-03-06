require 'spec_helper'

RSpec.describe SpreeShopifyImporter::DataSavers::Variants::VariantCreator, type: :service do
  include ActiveJob::TestHelper

  let(:spree_product) { create(:product) }
  let(:shopify_variant) { create(:shopify_variant, sku: '1234') }
  let(:option_type) { create(:option_type) }
  let(:shopify_data_feed) do
    create(:shopify_data_feed,
           shopify_object_type: 'ShopifyAPI::Variant',
           shopify_object_id: shopify_variant.id,
           data_feed: shopify_variant.to_json)
  end
  let!(:f_option_value) do
    create(:option_value, name: shopify_variant.option1.strip.downcase, option_type: option_type)
  end
  let!(:s_option_value) do
    create(:option_value, name: shopify_variant.option2.strip.downcase, option_type: option_type)
  end
  let!(:t_option_value) do
    create(:option_value, name: shopify_variant.option3.strip.downcase, option_type: option_type)
  end

  subject { described_class.new(shopify_data_feed, spree_product) }

  before  do
    spree_product.option_types << option_type
  end

  describe '#create!!' do
    it 'creates spree variant' do
      expect { subject.create! }.to change(Spree::Variant, :count).by(1)
    end

    it 'assigns new variant to product' do
      expect { subject.create! }.to change { spree_product.variants.reload.count }.by(1)
    end

    it 'assings new variant to data feed' do
      subject.create!

      expect(shopify_data_feed.reload.spree_object).to eq Spree::Variant.last
    end

    it 'assigns option values to product' do
      subject.create!

      variant = Spree::Variant.last
      expect(variant.option_values).to contain_exactly(f_option_value, s_option_value, t_option_value)
    end

    context 'base variant attributes' do
      let(:spree_variant) { Spree::Variant.last }

      before { subject.create! }

      it 'saves variant sku' do
        expect(spree_variant.sku).to eq shopify_variant.sku
      end

      it 'saves variant price' do
        expect(spree_variant.price).to eq shopify_variant.price
      end

      it 'saves variant weight' do
        expect(spree_variant.weight).to eq shopify_variant.grams
      end
    end

    context 'variant stock' do
      context 'track inventory' do
        let(:spree_variant) { Spree::Variant.last }

        before { subject.create! }

        context 'resource in shopify was tracking inventory' do
          let(:shopify_variant) { create(:shopify_variant, inventory_management: 'shopify') }

          it 'then it is tracking inventory' do
            expect(spree_variant).to be_track_inventory
          end
        end

        context 'resource in shopify was not tracking inventory' do
          let(:shopify_variant) { create(:shopify_variant, inventory_management: 'not_shopify') }

          it 'then it is not tracking inventory' do
            expect(spree_variant).not_to be_track_inventory
          end
        end
      end

      context 'images', vcr: { cassette_name: 'shopify_import/creators/variant_creator/image' } do
        let(:shopify_image) { create(:shopify_image, src: valid_path) }
        let(:valid_path) do
          'https://cdn.shopify.com/s/files/1/2051/3691/'\
          'products/Screenshot_2017-03-03_14.45.16_29b97e8b-f008-460f-8733-b33d551d7140.png?v=1496631699'
        end

        subject { described_class.new(shopify_data_feed, spree_product, shopify_image.to_json) }

        it 'creates spree image' do
          expect do
            perform_enqueued_jobs do
              subject.create!
            end
          end.to change(Spree::Image, :count).by(1)
        end
      end
    end
  end
end
