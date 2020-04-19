module SpreeShopifyImporter
  module DataParsers
    module InventoryUnits
      class BaseData
        def initialize(shopify_line_item, spree_shipment)
          @shopify_line_item = shopify_line_item
          @spree_shipment = spree_shipment
        end

        def attributes
          @attributes ||= {
            order: order,
            variant: variant,
            line_item: line_item,
            state: inventory_unit_state
          }
        end

        def line_item
          return if variant.blank?

          @line_item ||= order.line_items.find_by(variant: variant)
        end

        private

        def order
          @order ||= @spree_shipment.order
        end

        def variant
          @variant ||= SpreeShopifyImporter::DataFeed.find_by(shopify_object_type: "ShopifyAPI::Variant",
                                                              shopify_object_id: shopify_variant_id).try(:spree_object)
        end

        def inventory_unit_state
          return :shipped if @spree_shipment.state.to_sym == :shipped

          :on_hand
        end

        def shopify_variant_id
          @shopify_variant_id ||= @shopify_line_item.variant_id
        end
      end
    end
  end
end
