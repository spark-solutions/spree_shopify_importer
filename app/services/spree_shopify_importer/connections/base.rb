module SpreeShopifyImporter
  module Connections
    class Base
      class << self
        def count(**opts)
          api_class.get(:count, opts)
        end

        def all(**opts)
          results = []
          find_in_batches(**opts) do |batch|
            results += batch
          end
          results
        end

        private

        def find_in_batches(**opts)
          opts = { page: 1 }.merge(opts)
          loop do
            batch = api_class.find(:all, params: opts)
            break if batch.blank?
            yield batch
            opts[:page] += 1
          end
        end

        def api_class
          "ShopifyAPI::#{name.demodulize}".constantize
        end
      end
    end
  end
end
