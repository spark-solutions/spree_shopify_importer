require 'spec_helper'

describe SpreeShopifyImporter::Importers::PaymentImporter, type: :service do
  subject { described_class.new(transaction, parent_feed, spree_order) }

  let(:transaction) { shopify_order.transactions.first }
  let(:parent_feed) { create(:shopify_data_feed) }
  let(:spree_order) { create(:order) }

  before  { authenticate_with_shopify }
  after   { ShopifyAPI::Base.clear_session }

  describe '#import!', vcr: { cassette_name: 'shopify/base_order' } do
    let(:shopify_order) { ShopifyAPI::Order.find(5_182_437_124) }

    before do
      parent_feed
    end

    it 'creates shopify data feeds' do
      expect { subject.import! }.to change(SpreeShopifyImporter::DataFeed, :count).by(1)
    end

    it 'creates spree payment' do
      expect { subject.import! }.to change(Spree::Payment, :count).by(1)
    end

    context 'with existing data feed' do
      let(:shopify_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: transaction.id,
               shopify_object_type: 'ShopifyAPI::Transaction',
               data_feed: transaction.to_json)
      end

      before do
        shopify_data_feed
      end

      it 'creates shopify data feeds' do
        expect { subject.import! }.not_to change(SpreeShopifyImporter::DataFeed, :count)
      end

      it 'creates spree payment' do
        expect { subject.import! }.to change(Spree::Payment, :count).by(1)
      end
    end
  end
end
