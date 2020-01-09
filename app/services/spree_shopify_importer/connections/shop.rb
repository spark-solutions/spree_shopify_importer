module SpreeShopifyImporter
  module Connections
    class Shop < Base
      def call
        ShopifyAPI::Shop.find
      end
    end
  end
end
