require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::ReturnItems::ReturnItemsCreator, type: :service do
  subject { described_class.new(shopify_refund_line_item, shopify_refund, spree_return_authorization, spree_order) }

  let(:spree_return_authorization) { create(:return_authorization) }
  let(:spree_order) { create(:order_with_line_items) }

  before  { authenticate_with_shopify }
  after   { ShopifyAPI::Base.clear_session }

  describe '#create' do
    let(:variant) do
      create(:shopify_data_feed,
             shopify_object_id: shopify_refund_line_item.line_item.variant_id,
             shopify_object_type: 'ShopifyAPI::Variant',
             spree_object: spree_order.line_items.first.variant)
    end

    before do
      variant
    end

    context 'with base refund data', vcr: { cassette_name: 'shopify/base_refund' } do
      let(:shopify_refund) { ShopifyAPI::Refund.find(225_207_300, params: { order_id: 5_182_437_124 }) }
      let(:shopify_refund_line_item) { shopify_refund.refund_line_items.first }
      let(:quantity) { shopify_refund_line_item.quantity }

      it 'creates return items' do
        expect { subject.create }.to change(Spree::ReturnItem, :count).by(1)
      end
    end
  end
end
