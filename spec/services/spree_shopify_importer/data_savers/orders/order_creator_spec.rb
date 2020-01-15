require 'spec_helper'

RSpec.describe SpreeShopifyImporter::DataSavers::Orders::OrderCreator, type: :service do
  subject { described_class.new(order_data_feed) }
  before  { authenticate_with_shopify }
  after   { ShopifyAPI::Base.clear_session }

  describe '#save!' do
    let!(:user) { create(:user, email: 'example@example.com') }
    let!(:user_data_feed) do
      create(:shopify_data_feed,
             spree_object: user,
             shopify_object_id: shopify_order.customer.id,
             shopify_object_type: 'ShopifyAPI::Customer')
    end

    context 'with base shopify order data', vcr: { cassette_name: 'shopify/base_order' } do
      let(:shopify_order) { ShopifyAPI::Order.find(5_182_437_124) }
      let!(:order_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: shopify_order.id, data_feed: shopify_order.to_json)
      end
      let(:spree_order) { Spree::Order.find_by!(number: shopify_order.order_number) }

      before do
        shopify_order.line_items.each do |line_item|
          create(:shopify_data_feed,
                 spree_object: create(:variant),
                 shopify_object_type: 'ShopifyAPI::Variant',
                 shopify_object_id: line_item.variant_id)
        end
      end

      it 'creates spree order' do
        expect { subject.save! }.to change(Spree::Order, :count).by(1)
      end

      it 'assigns shopify data feed to spree order' do
        subject.save!
        expect(order_data_feed.reload.spree_object).to eq spree_order
      end

      context 'with existing user' do
        it 'assigns order to user' do
          subject.save!
          expect(spree_order.reload.user).to eq user
        end
      end

      context 'with not existing user' do
        let!(:user_data_feed) do
          create(:shopify_data_feed,
                 spree_object: nil,
                 shopify_object_id: shopify_order.customer.id,
                 shopify_object_type: 'ShopifyAPI::Customer')
        end

        it 'creates spree order' do
          expect { subject.save! }.to change(Spree::Order, :count).by(1)
        end

        it 'creates order as guest one' do
          subject.save!
          expect(spree_order.reload.user).to be_nil
        end
      end

      context 'sets order attributes' do
        before { subject.save! }

        it 'number' do
          expect(spree_order.number).to eq '1001'
        end

        it 'email' do
          expect(spree_order.email).to eq 'example@example.com'
        end

        it 'channel' do
          expect(spree_order.channel).to eq I18n.t(:shopify)
        end

        it 'currency' do
          expect(spree_order.currency).to eq 'EUR'
        end

        it 'confirmation_delivered' do
          expect(spree_order.confirmation_delivered).to be_truthy
        end

        it 'last_ip_address' do
          expect(spree_order.last_ip_address).to be_nil
        end

        it 'item_count' do
          expect(spree_order.item_count).to eq 8
        end
      end

      context 'sets order totals' do
        before { subject.save! }

        it 'total' do
          expect(spree_order.total).to eq 470.0.to_d
        end

        it 'item total' do
          expect(spree_order.item_total).to eq 450.0.to_d
        end

        it 'additional tax total' do
          expect(spree_order.additional_tax_total).to eq 0
        end

        it 'promo total' do
          expect(spree_order.promo_total).to eq 0
        end

        it 'payment total' do
          expect(spree_order.payment_total).to eq 470.0.to_d
        end

        it 'shipment total' do
          expect(spree_order.shipment_total).to eq 20.0.to_d
        end
      end

      context 'sets order states' do
        before { subject.save! }

        it 'state' do
          expect(spree_order.state).to eq 'complete'
        end

        it 'payment state' do
          expect(spree_order.payment_state).to eq 'paid'
        end

        it 'shipment state' do
          expect(spree_order.shipment_state).to eq 'partial'
        end
      end

      context 'sets order timestamps' do
        before { subject.save! }

        it 'completed at at' do
          expect(spree_order.completed_at).to eq shopify_order.created_at
        end

        it 'created at' do
          expect(spree_order.created_at).to eq shopify_order.created_at
        end

        it 'updated at' do
          expect(spree_order.updated_at).to eq shopify_order.updated_at
        end
      end

      context 'order associated items' do
        context 'line items' do
          let(:count) { shopify_order.line_items.count }

          it 'creates spree line items' do
            expect { subject.save! }.to change(Spree::LineItem, :count).by(count)
          end
        end

        context 'payments' do
          it 'creates shopify data feeds' do
            payment_scope = { shopify_object_type: 'ShopifyAPI::Transaction' }

            expect { subject.save! }
              .to change { SpreeShopifyImporter::DataFeed.where(payment_scope).reload.count }.by(1)
          end

          it 'creates spree payments' do
            expect { subject.save! }.to change(Spree::Payment, :count).by(1)
          end
        end

        context 'shipments' do
          it 'creates shopify data feeds' do
            shipment_scope = { shopify_object_type: 'ShopifyAPI::Fulfillment' }

            expect { subject.save! }
              .to change { SpreeShopifyImporter::DataFeed.where(shipment_scope).reload.count }.by(2)
          end

          it 'creates spree payments' do
            expect { subject.save! }.to change(Spree::Shipment, :count).by(2)
          end
        end

        context 'promotions' do
          # TODO: change mock to real data
          before do
            allow_any_instance_of(ShopifyAPI::Order)
              .to receive(:discount_codes).and_return([create(:shopify_discount_code)])
          end

          it 'creates spree tax rates' do
            expect { subject.save! }.to change(Spree::Promotion, :count).by(1)
          end

          it 'creates spree tax adjustments' do
            expect { subject.save! }.to change(Spree::Adjustment, :count).by(1)
          end
        end

        context 'addresses' do
          it 'creates spree tax rates' do
            expect { subject.save! }.to change(Spree::Address, :count).by(2)
          end

          it 'assigns order ship address' do
            subject.save!
            expect(spree_order.ship_address.reload).to be_present
          end

          it 'assigns order bill address' do
            subject.save!
            expect(spree_order.bill_address.reload).to be_present
          end
        end

        context 'with refunds', vcr: { cassette_name: 'shopify/order_with_refund' } do
          it 'creates return authorization' do
            expect { subject.save! }.to change(Spree::ReturnAuthorization, :count).by(1)
          end

          it 'creates customer returns' do
            expect { subject.save! }.to change(Spree::CustomerReturn, :count).by(1)
          end

          it 'creates return items' do
            expect { subject.save! }.to change(Spree::ReturnItem, :count).by(1)
          end

          it 'creates reimbursements' do
            expect { subject.save! }.to change(Spree::Reimbursement, :count).by(1)
          end

          it 'creates refunds' do
            expect { subject.save! }.to change(Spree::Refund, :count).by(1)
          end

          it 'changes payment total' do
            subject.save!
            expect(spree_order.payment_total).to eq 320
          end
        end
      end
    end

    context 'with missing data', vcr: { cassette_name: 'shopify/order_with_missing_data' } do
      let(:shopify_order) { ShopifyAPI::Order.find(5_182_437_124) }
      let!(:order_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: shopify_order.id, data_feed: shopify_order.to_json)
      end
      let(:spree_order) { Spree::Order.find_by!(number: shopify_order.order_number) }

      context 'missing line items variant data' do
        it 'raises variant not found error, do not create objects and enqueue product import' do
          expect { subject.save! }.to raise_error(SpreeShopifyImporter::DataParsers::LineItems::VariantNotFound)
          expect(Spree::Order.count).to eq 0
          expect(Spree::LineItem.count).to eq 0
          expect(SpreeShopifyImporter::Importers::ProductImporterJob).to have_been_enqueued
        end
      end

      context 'missing user data' do
        let!(:user_data_feed) { nil }

        it 'raises variant not found error, do not create objects and enqueue product import' do
          expect { subject.save! }.to raise_error(SpreeShopifyImporter::DataParsers::Orders::UserNotFound)
          expect(Spree::Order.count).to eq 0
          expect(SpreeShopifyImporter::Importers::UserImporterJob).to have_been_enqueued
        end
      end
    end
  end
end
