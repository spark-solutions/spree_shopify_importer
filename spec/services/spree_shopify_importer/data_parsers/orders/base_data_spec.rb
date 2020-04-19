require 'spec_helper'

RSpec.describe SpreeShopifyImporter::DataParsers::Orders::BaseData, type: :service do
  subject { described_class.new(shopify_order) }

  let(:shopify_order) { build_stubbed(:shopify_order) }

  describe '#user' do
    context 'when data_feed was imported' do
      let(:shopify_data_feed) do
        create(:shopify_data_feed,
               spree_object: user,
               shopify_object_id: shopify_order.customer.id,
               shopify_object_type: 'ShopifyAPI::Customer')
      end
      let(:user) { create(:user) }

      before do
        shopify_data_feed
      end

      context 'when user is imported' do
        it 'returns spree user' do
          expect(subject.user).to eq user
        end
      end

      context 'when user cannot be created' do
        let(:user) { nil }

        it 'returns nil' do
          expect(subject.user).to be_nil
        end
      end
    end

    context 'where user is not imported' do
      let(:shopify_data_feed) { nil }

      it 'raises NoUserFound error and start user import job' do
        expect { subject.user }
          .to raise_error(SpreeShopifyImporter::DataParsers::Orders::UserNotFound)
          .and enqueue_job(SpreeShopifyImporter::Importers::UserImporterJob)
      end
    end
  end

  describe '#attributes' do
    let(:base_order_attributes) do
      {
        number: shopify_order.order_number,
        email: shopify_order.email,
        channel: I18n.t('shopify'),
        currency: shopify_order.currency,
        confirmation_delivered: shopify_order.confirmed,
        last_ip_address: shopify_order.browser_ip,
        item_count: shopify_order.line_items.sum(&:quantity)
      }
    end

    let(:order_totals) do
      {
        total: shopify_order.total_price,
        item_total: shopify_order.total_line_items_price,
        additional_tax_total: shopify_order.total_tax,
        promo_total: -shopify_order.total_discounts.to_d,
        payment_total: payment_total,
        shipment_total: shopify_order.shipping_lines.sum { |shipping_line| shipping_line.price.to_d }
      }
    end

    let(:order_states) do
      {
        state: 'complete',
        payment_state: 'paid',
        shipment_state: 'shipped'
      }
    end

    let(:result) do
      [
        base_order_attributes,
        order_totals,
        order_states
      ].inject(&:merge)
    end

    let(:states_getter) { instance_double(SpreeShopifyImporter::DataParsers::Orders::StatesGetter) }

    before do
      expect(SpreeShopifyImporter::DataParsers::Orders::StatesGetter).to receive(:new).with(shopify_order).and_return(states_getter)
      expect(states_getter).to receive(:order_state).and_return('complete')
      expect(states_getter).to receive(:payment_state).and_return('paid')
      expect(states_getter).to receive(:shipment_state).and_return('shipped')
    end

    context 'when single transaction' do
      let(:shopify_transaction) { build_stubbed(:shopify_transaction, order: shopify_order) }
      let(:payment_total) { shopify_transaction.amount.to_d }

      before do
        expect_any_instance_of(ShopifyAPI::Order).to receive(:transactions).and_return([shopify_transaction])
      end

      it 'prepare hash of order attributes' do
        expect(subject.attributes).to eq result
      end
    end

    context 'with multiple transactions' do
      let(:first_shopify_transaction) { build_stubbed(:shopify_transaction, order: shopify_order) }
      let(:second_shopify_transaction) { build_stubbed(:shopify_transaction, order: shopify_order) }
      let(:payment_total) { first_shopify_transaction.amount.to_d + second_shopify_transaction.amount.to_d }

      before do
        expect_any_instance_of(ShopifyAPI::Order)
          .to receive(:transactions).and_return([first_shopify_transaction, second_shopify_transaction])
      end

      it 'prepare hash of order attributes' do
        expect(subject.attributes).to eq result
      end
    end
  end

  describe '#timestamps' do
    let(:order_timestamps) do
      {
        completed_at: shopify_order.created_at,
        created_at: shopify_order.created_at,
        updated_at: shopify_order.updated_at
      }
    end

    it 'prepare hash of order timestamps' do
      expect(subject.timestamps).to eq order_timestamps
    end
  end
end
