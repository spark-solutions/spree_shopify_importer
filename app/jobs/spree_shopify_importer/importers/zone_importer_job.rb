module SpreeShopifyImporter
  module Importers
    class ZoneImporterJob < ::SpreeShopifyImporterJob
      def perform(resource, parent_object, shipping_methods)
        SpreeShopifyImporter::Importers::ZoneImporter.new(resource, parent_object, shipping_methods).import!
      end
    end
  end
end
