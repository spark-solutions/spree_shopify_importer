module Shopify
  module Import
    class Base
      def initialize(credentials: {}, client: nil)
        @client = client(credentials) unless client
      end

      def count(**opts)
        api_class.get(:count, opts)
      end

      def find(id)
        api_class.find(id)
      end

      def find_all(**opts)
        results = []
        find_in_batches(**opts) do |batch|
          return results if batch.nil?
          batch.each { |resource| results << resource }
        end
        results
      end

      private

      def find_in_batches(**opts)
        opts = { limit: 250, page: 1 }.merge(opts)
        begin
          batch = api_class.find(:all, params: opts)
          yield batch
          opts[:page] += 1
        end while batch.try(:any?)
      end

      def client(credentials)
        Shopify::Import::Client.instance.get_connection(credentials)
      end

      def api_class
        "ShopifyAPI::#{self.class.to_s.demodulize}".constantize
      end
    end
  end
end
