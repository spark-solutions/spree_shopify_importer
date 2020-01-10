module SpreeShopifyImporter
  module Connections
    class Base
      class << self
        def count(**opts)
          api_class.get(:count, opts)
        end

        def all
          results = []
          batch = api_class.find(:all, params: { limit: 50 })
          loop do
            results += batch
            break unless batch.next_page?
            batch = batch.fetch_next_page
          end
          results
        end

        private

        def api_class
          "ShopifyAPI::#{name.demodulize}".constantize
        end
      end
    end
  end
end
