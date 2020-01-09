module SpreeShopifyImporter
  module Importers
    class ShopImporterJob < ::SpreeShopifyImporterJob
      def perform(resource)
        ShopImporter.new(resource).import!
      end
    end
  end
end
