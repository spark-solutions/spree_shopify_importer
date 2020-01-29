module SpreeShopifyImporter
  module Importers
    class StockLocationImporterJob < ::SpreeShopifyImporterJob
      def perform(resource)
        SpreeShopifyImporter::Importers::StockLocationImporter.new(resource).import!
      end
    end
  end
end
