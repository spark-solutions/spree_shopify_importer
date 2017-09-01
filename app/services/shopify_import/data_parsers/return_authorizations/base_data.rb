module ShopifyImport
  module DataParsers
    module ReturnAuthorizations
      class BaseData
        def initialize(shopify_refund, spree_order)
          @shopify_refund = shopify_refund
          @spree_order = spree_order
        end

        def number
          @return_authorization_number ||= "SRA#{@shopify_refund.id}"
        end

        def attributes
          @attributes ||= {
            state: :authorized,
            memo: @shopify_refund.note,
            stock_location: stock_location,
            order: @spree_order,
            reason: reason
          }
        end

        def timestamps
          @timestamps ||= {
            created_at: @shopify_refund.created_at.to_datetime,
            updated_at: @shopify_refund.created_at.to_datetime
          }
        end

        private

        def stock_location
          Spree::StockLocation.find_or_create_by!(name: I18n.t(:shopify))
        end

        def reason
          Spree::ReturnAuthorizationReason.find_or_create_by!(name: I18n.t(:shopify), active: false)
        end
      end
    end
  end
end
