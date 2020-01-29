module SpreeShopifyImporter
  module DataSavers
    module StockLocations
      class StockLocationUpdater < StockLocationBase
        def initialize(shopify_data_feed, spree_stock_location)
          @shopify_data_feed = shopify_data_feed
          @spree_stock_location = spree_stock_location
        end

        def update!
          @spree_stock_location.attributes = attributes
          @spree_stock_location.save(validate: false)
        end
      end
    end
  end
end
