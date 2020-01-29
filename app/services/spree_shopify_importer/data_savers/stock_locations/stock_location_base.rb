module SpreeShopifyImporter
  module DataSavers
    module StockLocations
      class StockLocationBase < BaseDataSaver
        delegate :attributes, to: :parser

        private

        def parser
          @parser ||= SpreeShopifyImporter::DataParsers::StockLocations::BaseData.new(shopify_location)
        end

        def shopify_location
          @shopify_location ||= ShopifyAPI::Location.new(data_feed)
        end
      end
    end
  end
end
