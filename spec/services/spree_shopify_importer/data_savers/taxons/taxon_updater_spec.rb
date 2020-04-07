require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::Taxons::TaxonUpdater, type: :service do
  subject { described_class.new(shopify_data_feed, spree_taxon) }

  before { authenticate_with_shopify }

  describe '#update!', vcr: { cassette_name: 'shopify/base_custom_collection' } do
    let(:shopify_custom_collection) { ShopifyAPI::CustomCollection.find(440_333_380) }
    let(:shopify_data_feed) { create(:shopify_data_feed, data_feed: shopify_custom_collection.to_json) }
    let(:taxonomy) { create(:taxonomy, name: I18n.t('shopify_custom_collections')) }

    let!(:spree_taxon) { create(:taxon, taxonomy: taxonomy, parent: taxonomy.root) }

    it 'does not create spree taxon' do
      expect { subject.update! }.not_to change { Spree::Taxon.where.not(parent: nil).reload.count }
    end

    context 'taxon attributes' do
      before { subject.update! }

      it 'name' do
        expect(spree_taxon.name).to eq shopify_custom_collection.title
      end

      it 'permalink' do
        expect(spree_taxon.permalink).to eq shopify_custom_collection.handle
      end

      it 'description' do
        expect(spree_taxon.description).to eq shopify_custom_collection.body_html
      end
    end

    context 'associations' do
      context 'products' do
        let(:spree_product) { create(:product) }
        let(:product_data_feed) do
          create(:shopify_data_feed,
                 shopify_object_type: 'ShopifyAPI::Product',
                 shopify_object_id: '11055169028',
                 spree_object: spree_product)
        end

        before do
          product_data_feed
        end

        it 'assigns products to spree_taxon' do
          subject.update!

          expect(spree_taxon.products).to contain_exactly(spree_product)
        end
      end
    end
  end
end
