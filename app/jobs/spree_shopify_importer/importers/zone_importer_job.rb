module SpreeShopifyImporter
  module Importers
    class ZoneImporterJob < ::SpreeShopifyImporterJob
      def perform(resource, parent_object)
        SpreeShopifyImporter::Importers::ZoneImporter.new(resource, parent_object).import!
      end
    end
  end
end
