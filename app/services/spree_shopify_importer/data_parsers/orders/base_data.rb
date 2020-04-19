module SpreeShopifyImporter
  module DataParsers
    module Orders
      class UserNotFound < StandardError; end

      class BaseData
        def initialize(shopify_order)
          @shopify_order = shopify_order
        end

        def user
          return if (customer = @shopify_order.customer).blank?
          return @user if @user.present?
          return handle_missing_user(customer) if (data_feed = user_data_feed(customer)).blank?

          @user ||= data_feed.spree_object
        end

        def attributes
          @attributes ||= [
            base_order_attributes,
            order_totals,
            order_states
          ].inject(&:merge).select { |a| Spree::Order.attribute_method?(a) }
        end

        def timestamps
          @timestamps ||= {
            completed_at: @shopify_order.created_at.to_datetime,
            created_at: @shopify_order.created_at.to_datetime,
            updated_at: @shopify_order.updated_at.to_datetime
          }
        end

        private

        def user_data_feed(customer)
          @user_data_feed ||= SpreeShopifyImporter::DataFeed.find_by(shopify_object_id: customer.id,
                                                                     shopify_object_type: 'ShopifyAPI::Customer')
        end

        def handle_missing_user(customer)
          SpreeShopifyImporter::Importers::UserImporterJob.perform_later(customer.to_json)
          raise UserNotFound, I18n.t('errors.customers.no_user_found', customer_id: customer.id)
        end

        def base_order_attributes
          {
            number: @shopify_order.order_number,
            email: @shopify_order.email,
            channel: I18n.t('shopify'),
            currency: @shopify_order.currency,
            note: @shopify_order.note,
            confirmation_delivered: @shopify_order.confirmed,
            last_ip_address: @shopify_order.browser_ip,
            item_count: @shopify_order.line_items.sum(&:quantity)
          }
        end

        # TODO: ORDER ADJUSTMENT TOTAL
        # TODO: ORDER INCLUDED TAX TOTAL
        def order_totals
          {
            total: @shopify_order.total_price,
            item_total: @shopify_order.total_line_items_price,
            additional_tax_total: @shopify_order.total_tax,
            promo_total: - @shopify_order.total_discounts.to_d,
            payment_total: payment_total,
            shipment_total: shipment_total
          }
        end

        def order_states
          {
            state: states_getter.order_state,
            payment_state: states_getter.payment_state,
            shipment_state: states_getter.shipment_state
          }
        end

        def payment_total
          transactions = @shopify_order.transactions.select do |t|
            %w[sale capture].include?(t.kind)
          end

          transactions.select { |t| t.status == 'success' }.sum { |t| t.amount.to_d }
        end

        def shipment_total
          @shopify_order.shipping_lines.sum { |shipping_line| shipping_line.price.to_d }
        end

        def states_getter
          @states_getter ||= SpreeShopifyImporter::DataParsers::Orders::StatesGetter.new(@shopify_order)
        end
      end
    end
  end
end
