require 'spec_helper'

describe SpreeShopifyImporter::Importers::UserImporter, type: :service do
  subject { described_class.new(resource) }

  before  { authenticate_with_shopify }
  after   { ShopifyAPI::Base.clear_session }

  describe '#import!', vcr: { cassette_name: 'shopify_import/importers/user_importer/import' } do
    let(:shopify_customer) { ShopifyAPI::Customer.find(5_667_226_244) }
    let(:resource) { shopify_customer.to_json }

    it 'creates shopify data feeds' do
      expect { subject.import! }.to change(SpreeShopifyImporter::DataFeed, :count).by(1)
    end

    it 'creates spree users' do
      expect { subject.import! }.to change(Spree.user_class, :count).by(1)
    end

    context 'with existing data feed' do
      let(:shopify_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: shopify_customer.id,
               shopify_object_type: 'ShopifyAPI::Customer',
               data_feed: resource,
               spree_object: spree_object)
      end
      let(:spree_object) { nil }

      before do
        shopify_data_feed
      end

      it 'creates shopify data feeds' do
        expect { subject.import! }.not_to change(SpreeShopifyImporter::DataFeed, :count)
      end

      it 'creates spree users' do
        expect { subject.import! }.to change(Spree.user_class, :count).by(1)
      end

      context 'and user' do
        let(:spree_object) { create(:user) }

        it 'creates shopify data feeds' do
          expect { subject.import! }.not_to change(SpreeShopifyImporter::DataFeed, :count)
        end

        it 'does not create spree users' do
          expect { subject.import! }.not_to change(Spree.user_class, :count)
        end
      end
    end

    context 'when email is empty' do
      let(:shopify_customer) { create(:shopify_customer, email: nil) }

      it 'creates data feed' do
        expect { subject.import! }.to change(SpreeShopifyImporter::DataFeed, :count).by(1)
      end

      it 'does not create spree users' do
        expect { subject.import! }.not_to change(Spree.user_class, :count)
      end
    end
  end
end
