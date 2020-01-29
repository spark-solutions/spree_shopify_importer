module SpreeShopifyImporter
  module Importers
    class StockLocationImporter < BaseImporter
      private

      def creator
        SpreeShopifyImporter::DataSavers::StockLocations::StockLocationCreator
      end

      def updater
        SpreeShopifyImporter::DataSavers::StockLocations::StockLocationUpdater
      end

      def shopify_class
        ShopifyAPI::Location
      end
    end
  end
end
