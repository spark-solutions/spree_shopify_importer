module SpreeShopifyImporter
  module DataSavers
    module StockLocations
      class StockLocationBase < BaseDataSaver
        delegate :attributes, to: :stock_location_parser
        delegate :stock_item_attributes, :backorderable?, :count_on_hand, to: :stock_item_parser

        private

        def stock_location_parser
          @stock_location_parser ||= SpreeShopifyImporter::DataParsers::StockLocations::BaseData.new(shopify_location)
        end

        def stock_item_parser
          SpreeShopifyImporter::DataParsers::StockItems::BaseData.new(@spree_stock_location, @inventory_level)
        end

        def assign_data_to_spree_stock_items
          @shopify_location.inventory_levels.each do |inventory_level|
            @inventory_level = inventory_level
            stock_item = Spree::StockItem.where(stock_item_attributes).first_or_create!
            stock_item.update!(
              count_on_hand: count_on_hand,
              backorderable: backorderable?
            )
          end
        end

        def shopify_location
          @shopify_location ||= ShopifyAPI::Location.new(data_feed)
        end
      end
    end
  end
end
