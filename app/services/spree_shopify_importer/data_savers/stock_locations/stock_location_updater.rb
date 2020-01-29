module SpreeShopifyImporter
  module DataSavers
    module StockLocations
      class StockLocationUpdater < StockLocationBase
        def initialize(shopify_data_feed, spree_stock_location)
          @shopify_data_feed = shopify_data_feed
          @spree_stock_location = spree_stock_location
        end

        def update!
          Spree::StockLocation.transaction do
            update_spree_stock_location
            assign_data_to_spree_stock_items
          end
        end

        def update_spree_stock_location
          @spree_stock_location.update(attributes: attributes)
        end
      end
    end
  end
end
