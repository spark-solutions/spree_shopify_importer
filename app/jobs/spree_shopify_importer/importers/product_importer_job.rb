module SpreeShopifyImporter
  module Importers
    class ProductImporterJob < ::SpreeShopifyImporterJob
      def perform(resource)
        SpreeShopifyImporter::Importers::ProductImporter.new(resource).import!
      end
    end
  end
end
