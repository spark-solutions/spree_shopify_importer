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

      def find_and_import(id)
        resource = find(id)
        create_data_feed_and_spree_object(resource)
      end

      def find_all(**opts)
        results = []
        find_in_batches(**opts) do |batch|
          return results if batch.nil?
          batch.each { |resource| results << resource }
        end
        results
      end

      def find_all_first_and_import(**opts)
        find_all(**opts).each do |resource|
          create_data_feed_and_spree_object(resource)
        end
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

      def create_data_feed_and_spree_object(resource)
        shopify_data_feed = Shopify::DataFeeds::Create.new(resource).save!
        shopify_spree_creator.new(shopify_data_feed).save!
      end

      def api_class
        "ShopifyAPI::#{class_name}".constantize
      end

      def shopify_spree_creator
        "Shopify::Import::#{class_name}s::Create".constantize
      end

      def class_name
        self.class.to_s.demodulize
      end
    end
  end
end
