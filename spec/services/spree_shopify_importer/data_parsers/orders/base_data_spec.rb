require 'spec_helper'

RSpec.describe SpreeShopifyImporter::DataParsers::Orders::BaseData, type: :service do
  subject { described_class.new(shopify_order) }

  let(:shopify_order) { create(:shopify_order) }
  let(:shopify_transaction) { create(:shopify_transaction, order: shopify_order) }

  describe '#user' do
    let(:user) { create(:user) }
    let!(:shopify_data_feed) do
      create(:shopify_data_feed,
             spree_object: user,
             shopify_object_id: shopify_order.customer.id,
             shopify_object_type: 'ShopifyAPI::Customer')
    end

    it 'returns spree user' do
      expect(subject.user).to eq user
    end

    context 'where user is not imported' do
      let!(:shopify_data_feed) { nil }

      it 'raise NoUserFound error and start user import job' do
        expect { subject.user }
          .to raise_error(SpreeShopifyImporter::DataParsers::Orders::UserNotFound)
          .and enqueue_job(SpreeShopifyImporter::Importers::UserImporterJob)
      end

      context 'when customer data feed was imported but user cannot be created' do
        let!(:shopify_data_feed) do
          create(:shopify_data_feed,
                 spree_object: nil,
                 shopify_object_id: shopify_order.customer.id,
                 shopify_object_type: 'ShopifyAPI::Customer')
        end

        it 'return nil' do
          expect(subject.user).to be_nil
        end
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
        payment_total: shopify_transaction.amount.to_d,
        shipment_total: shopify_order.shipping_lines.sum { |sl| sl.price.to_d }
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
      [base_order_attributes, order_totals, order_states].inject(&:merge)
    end
    let(:states_getter) { instance_double(SpreeShopifyImporter::DataParsers::Orders::StatesGetter) }

    before do
      expect(SpreeShopifyImporter::DataParsers::Orders::StatesGetter).to receive(:new).with(shopify_order).and_return(states_getter)
      expect(states_getter).to receive(:order_state).and_return('complete')
      expect(states_getter).to receive(:payment_state).and_return('paid')
      expect(states_getter).to receive(:shipment_state).and_return('shipped')
      allow_any_instance_of(ShopifyAPI::Order).to receive(:transactions).and_return([shopify_transaction])
    end

    it 'prepare hash of order attributes' do
      expect(subject.attributes).to eq result
    end

    context 'with multiple transactions' do
      let(:shopify_order) { build_stubbed(:shopify_order) }
      let(:shopify_transaction1) { build_stubbed(:shopify_transaction, order: shopify_order) }
      let(:shopify_transaction2) { build_stubbed(:shopify_transaction, order: shopify_order) }

      before do
        expect_any_instance_of(ShopifyAPI::Order)
          .to receive(:transactions).and_return([shopify_transaction1, shopify_transaction2])
      end

      let(:order_totals) do
        {
          total: shopify_order.total_price,
          item_total: shopify_order.total_line_items_price,
          additional_tax_total: shopify_order.total_tax,
          promo_total: -shopify_order.total_discounts.to_d,
          payment_total: shopify_transaction1.amount.to_d + shopify_transaction2.amount.to_d,
          shipment_total: shopify_order.shipping_lines.sum { |sl| sl.price.to_d }
        }
      end

      it 'prepare hash of order attributes' do
        expect(subject.attributes).to eq result
      end
    end
  end

  context '#timestamps' do
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
