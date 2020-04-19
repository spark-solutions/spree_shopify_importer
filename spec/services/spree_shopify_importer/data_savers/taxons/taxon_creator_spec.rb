require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::Taxons::TaxonCreator, type: :service do
  subject { described_class.new(shopify_data_feed) }

  before { authenticate_with_shopify }

  describe '#create!', vcr: { cassette_name: 'shopify/base_custom_collection' } do
    let(:shopify_custom_collection) { ShopifyAPI::CustomCollection.find(440_333_380) }
    let(:shopify_data_feed) { create(:shopify_data_feed, data_feed: shopify_custom_collection.to_json) }
    let(:spree_taxon) { Spree::Taxon.where.not(parent: nil).last }

    it 'creates spree taxonomy' do
      expect { subject.create! }.to change(Spree::Taxonomy, :count).by(1)
    end

    it 'creates spree taxon' do
      expect { subject.create! }.to change { Spree::Taxon.where.not(parent: nil).reload.count }.by(1)
    end

    it 'assigns shopify data feed to spree taxon' do
      subject.create!

      expect(shopify_data_feed.reload.spree_object).to eq spree_taxon
    end

    context 'taxon attributes' do
      it 'assigns correct taxon attributes' do
        subject.create!

        expect(spree_taxon.name).to eq shopify_custom_collection.title
        expect(spree_taxon.permalink).to eq "shopify-custom-collections/#{shopify_custom_collection.handle}"
        expect(spree_taxon.description).to eq shopify_custom_collection.body_html
      end
    end

    context 'associations' do
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
        subject.create!

        expect(spree_taxon.products).to contain_exactly(spree_product)
      end
    end
  end
end
