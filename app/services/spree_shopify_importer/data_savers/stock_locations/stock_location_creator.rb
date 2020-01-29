module SpreeShopifyImporter
  module DataSavers
    module StockLocations
      class StockLocationCreator < StockLocationBase
        def create!
          Spree::StockLocation.transaction do
            create_spree_stock_location
            assign_spree_stock_location_to_data_feed
          end
          assign_data_to_spree_stock_items
        end

        private

        def create_spree_stock_location
          @spree_stock_location = Spree::StockLocation.create!(attributes)
        end

        def assign_spree_stock_location_to_data_feed
          @shopify_data_feed.update!(spree_object: @spree_stock_location)
        end
      end
    end
  end
end
