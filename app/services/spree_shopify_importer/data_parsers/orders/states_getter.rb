module SpreeShopifyImporter
  module DataParsers
    module Orders
      class StatesGetter
        def initialize(shopify_order)
          @shopify_order = shopify_order
        end

        def order_state
          return ::Orders::Constants::OrderStates::RETURNED if @shopify_order.financial_status == ::Orders::Constants::Payments::Shopify::REFUNDED

          case payment_state
          when ::Orders::Constants::Payments::Spree::PAID,
               ::Orders::Constants::Payments::Spree::BALANCE_DUE
            ::Orders::Constants::OrderStates::COMPLETE
          when ::Orders::Constants::Payments::Spree::VOID then ::Orders::Constants::OrderStates::CANCELED
          when ::Orders::Constants::Payments::Spree::PENDING then order_state_by_shipment_state
          else
            raise NotImplementedError
          end
        end

        def payment_state
          @payment_state ||= case @shopify_order.financial_status
                             when ::Orders::Constants::Payments::Shopify::PENDING,
                                  ::Orders::Constants::Payments::Shopify::AUTHORIZED
                               ::Orders::Constants::Payments::Spree::PENDING
                             when ::Orders::Constants::Payments::Shopify::PARTIALLY_PAID then ::Orders::Constants::Payments::Spree::BALANCE_DUE
                             when ::Orders::Constants::Payments::Shopify::PAID,
                                  ::Orders::Constants::Payments::Shopify::PARTIALLY_REFUNDED,
                                  ::Orders::Constants::Payments::Shopify::REFUNDED
                               ::Orders::Constants::Payments::Spree::PAID
                             when ::Orders::Constants::Payments::Shopify::VOIDED then ::Orders::Constants::Payments::Spree::VOID
                             else
                               raise NotImplementedError
                             end
        end

        def shipment_state
          @shipment_state ||= case @shopify_order.fulfillment_status
                              when ::Orders::Constants::Shipments::Shopify::FULFILLED then ::Orders::Constants::Shipments::Spree::SHIPPED
                              when nil then set_correct_unfulfilled_state
                              when ::Orders::Constants::Shipments::Shopify::PARTIAL then ::Orders::Constants::Shipments::Spree::PARTIAL
                              else
                                raise NotImplementedError
                              end
        end

        private

        def order_state_by_shipment_state
          return ::Orders::Constants::OrderStates::COMPLETE if shipment_state == ::Orders::Constants::Shipments::Spree::SHIPPED

          ::Orders::Constants::OrderStates::PENDING
        end

        def set_correct_unfulfilled_state
          case @shopify_order.financial_status
          when ::Orders::Constants::Payments::Shopify::PAID then ::Orders::Constants::Shipments::Spree::READY
          when ::Orders::Constants::Payments::Shopify::PENDING then ::Orders::Constants::Shipments::Spree::PENDING
          else
            ::Orders::Constants::Shipments::Spree::PENDING
          end
        end
      end
    end
  end
end
