module SpreeShopifyImporter
  module DataFetchers
    class ZonesFetcher < BaseFetcher
      private

      def resources
        SpreeShopifyImporter::Connections::ShippingZone.all
      end

      def job
        SpreeShopifyImporter::Importers::ZoneImporterJob
      end
    end
  end
end
