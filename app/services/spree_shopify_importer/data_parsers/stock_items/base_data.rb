# frozen_string_literal: true

module SpreeShopifyImporter
  module DataParsers
    module StockItems
      class BaseData
        CONTINUE = "continue"

        def initialize(spree_stock_location, inventory_level)
          @spree_stock_location = spree_stock_location
          @inventory_level = inventory_level
        end

        def stock_item_attributes
          {
            stock_location_id: @spree_stock_location.id,
            variant_id: variant.id
          }
        end

        def backorderable?
          JSON.parse(variant_data_feed.data_feed)["inventory_policy"] == CONTINUE
        end

        def count_on_hand
          @inventory_level.available.to_i.positive? ? @inventory_level.available : 0
        end

        private

        def variant_data_feed
          SpreeShopifyImporter::DataFeed
            .where(shopify_object_type: "ShopifyAPI::Variant")
            .where("data_feed like ?", "%inventory_item_id\":#{@inventory_level.inventory_item_id}%").first
        end

        def variant
          Spree::Variant.find(variant_data_feed.spree_object_id)
        end
      end
    end
  end
end
