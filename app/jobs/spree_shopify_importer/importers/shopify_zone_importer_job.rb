module SpreeShopifyImporter
  module Importers
    class ShopifyZoneImporterJob < ::SpreeShopifyImporterJob
      def perform(resource)
        SpreeShopifyImporter::Importers::ShopifyZoneImporter.new(resource).import!
      end
    end
  end
end
