module SpreeShopifyImporter
  module DataFetchers
    class ProductsFetcher < BaseFetcher
      private

      def resources
        SpreeShopifyImporter::Connections::Product.all
      end

      def job
        SpreeShopifyImporter::Importers::ProductImporterJob
      end
    end
  end
end
