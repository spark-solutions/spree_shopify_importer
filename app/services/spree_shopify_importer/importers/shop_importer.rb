module SpreeShopifyImporter
  module Importers
    class ShopImporter < BaseImporter
      def import!
        process_data_feed
      end

      def shopify_class
        ShopifyAPI::Shop
      end
    end
  end
end
