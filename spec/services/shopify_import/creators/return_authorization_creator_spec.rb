require 'spec_helper'

describe ShopifyImport::Creators::ReturnAuthorizationCreator, type: :service do
  let(:shopify_refund) { create(:shopify_refund) }
  let(:spree_order) { create(:order) }
  let(:shopify_data_feed) do
    create(:shopify_data_feed,
           shopify_object_id: shopify_refund.id,
           shopify_object_type: 'ShopifyAPI::Refund',
           data_feed: shopify_refund.to_json)
  end

  subject { described_class.new(shopify_data_feed, spree_order) }

  describe '#save!' do
    context 'with base shopify_refund data feed' do
      let(:return_authorization) { subject.spree_return_authorization }

      it 'creates return authorization' do
        expect { subject.save! }.to change(Spree::ReturnAuthorization, :count).by(1)
      end

      it 'assigns return authorization to data feed' do
        subject.save!

        expect(shopify_data_feed.reload.spree_object).to eq return_authorization
      end

      context 'sets return authorization attributes' do
        before { subject.save! }

        it 'state' do
          expect(return_authorization.state).to eq 'authorized'
        end

        it 'memo' do
          expect(return_authorization.memo).to eq shopify_refund.note
        end
      end

      context 'sets return authorization associations' do
        let(:stock_location) { Spree::StockLocation.find_by!(name: I18n.t(:shopify)) }
        let(:reason) { Spree::ReturnAuthorizationReason.find_by!(name: I18n.t(:shopify)) }

        before { subject.save! }

        it 'order' do
          expect(return_authorization.order).to eq spree_order
        end

        it 'stock location' do
          expect(return_authorization.stock_location).to eq stock_location
        end

        it 'reason' do
          expect(return_authorization.reason).to eq reason
        end
      end

      context 'sets return authorization timestamps' do
        before { subject.save! }

        it 'created_at' do
          expect(return_authorization.created_at).to eq shopify_refund.created_at.to_datetime
        end

        it 'updated_at' do
          expect(return_authorization.updated_at).to eq shopify_refund.created_at.to_datetime
        end
      end
    end
  end
end
