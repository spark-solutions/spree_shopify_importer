module SpreeShopifyImporter
  module DataSavers
    module StockLocations
      class StockLocationCreator < StockLocationBase
        def create!
          Spree::StockLocation.transaction do
            create_spree_stock_location
            assign_spree_stock_location_to_data_feed
          end
        end

        private

        def create_spree_stock_location
          @spree_stock_location = Spree::StockLocation.new(attributes)
          @spree_stock_location.save(validate: false)
        end

        def assign_spree_stock_location_to_data_feed
          @shopify_data_feed.update!(spree_object: @spree_stock_location)
        end
      end
    end
  end
end
