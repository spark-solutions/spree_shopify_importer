module SpreeShopifyImporter
  module DataFetchers
    class ShopFetcher < BaseFetcher
      def import!
        job.perform_later(resource.attributes.to_json)
      end

      private

      def resource
        SpreeShopifyImporter::Connections::Shop.new.call
      end

      def job
        SpreeShopifyImporter::Importers::ShopImporterJob
      end
    end
  end
end
