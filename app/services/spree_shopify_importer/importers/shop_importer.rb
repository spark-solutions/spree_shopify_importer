module SpreeShopifyImporter
  module Importers
    class ShopImporter < BaseImporter
      def import!
        process_data_feed
        set_currency
      end

      private

      def shopify_class
        ShopifyAPI::Shop
      end

      def set_currency
        Spree::Config[:currency] = JSON.parse(@resource)['currency']
      end
    end
  end
end
