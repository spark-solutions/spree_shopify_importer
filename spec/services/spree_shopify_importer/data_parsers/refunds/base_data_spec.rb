require 'spec_helper'

describe SpreeShopifyImporter::DataParsers::Refunds::BaseData, type: :service do
  subject { described_class.new(shopify_refund, shopify_transaction, spree_reimbursement) }

  let(:shopify_refund) { build_stubbed(:shopify_refund) }
  let(:shopify_transaction) { build_stubbed(:shopify_transaction, parent_id: 12_345) }
  let(:spree_reimbursement) { build_stubbed(:reimbursement) }

  describe '#attributes' do
    let(:payment) { create(:payment) }

    let(:reason) { Spree::RefundReason.find_by!(name: I18n.t(:shopify)) }

    let(:shopify_data_feed) do
      create(:shopify_data_feed,
             shopify_object_id: shopify_transaction.parent_id,
             shopify_object_type: 'ShopifyAPI::Transaction',
             spree_object: payment)
    end

    let(:result) do
      {
        payment: payment,
        amount: shopify_transaction.amount,
        transaction_id: shopify_transaction.authorization,
        reason: reason,
        reimbursement: spree_reimbursement
      }
    end

    before do
      shopify_data_feed
    end

    it 'returns hash of refund attributes' do
      expect(subject.attributes).to eq result
    end
  end

  describe '#transaction_id' do
    it 'returns hash of refund attributes' do
      expect(subject.transaction_id).to eq shopify_transaction.authorization
    end
  end

  describe '#timestamps' do
    let(:result) do
      {
        created_at: shopify_refund.created_at.to_datetime,
        updated_at: shopify_refund.processed_at.to_datetime
      }
    end

    it 'returns hash of refund timestamps' do
      expect(subject.timestamps).to eq result
    end
  end
end
