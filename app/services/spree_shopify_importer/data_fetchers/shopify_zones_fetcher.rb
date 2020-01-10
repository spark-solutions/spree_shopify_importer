module SpreeShopifyImporter
  module DataFetchers
    class ShopifyZonesFetcher < BaseFetcher
      private

      def resources
        SpreeShopifyImporter::Connections::ShippingZone.all
      end

      def job
        SpreeShopifyImporter::Importers::ShopifyZoneImporterJob
      end
    end
  end
end
