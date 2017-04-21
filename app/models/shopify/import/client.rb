require 'singleton'

module Shopify
  module Import
    class Client
      include Singleton
      attr_reader :site

      def get_connection(api_key: nil, password: nil, shop_name: nil)
        @api_key = api_key || Spree::Config[:shopify_api_key]
        @password = password || Spree::Config[:shopify_password]
        @shop_name = shop_name || Spree::Config[:shopify_shop_name]
        @site = shopify_site
      end

      private

      def shopify_site
        ShopifyAPI::Base.site = "https://#{api_key}:#{password}@#{shop_name}.myshopify.com/admin"
      end

      def api_key
        @api_key || Spree::Config[:shopify_api_key]
      end

      def password
        @password || Spree::Config[:shopify_password]
      end

      def shop_name
        @shop_name || Spree::Config[:shopify_shop_name]
      end
    end
  end
end
