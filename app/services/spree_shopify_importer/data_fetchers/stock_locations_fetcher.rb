module SpreeShopifyImporter
  module DataFetchers
    class StockLocationsFetcher < BaseFetcher
      private

      def resources
        SpreeShopifyImporter::Connections::Location.all
      end

      def job
        SpreeShopifyImporter::Importers::StockLocationImporterJob
      end
    end
  end
end
