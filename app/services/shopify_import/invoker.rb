module ShopifyImport
  class Invoker
    ROOT_FETCHERS = [
      ShopifyImport::DataFetchers::ProductsFetcher,
      ShopifyImport::DataFetchers::UsersFetcher,
      ShopifyImport::DataFetchers::TaxonsFetcher,
      ShopifyImport::DataFetchers::OrdersFetcher
    ].freeze

    def initialize(credentials: nil)
      @credentials = credentials
      @credentials ||= {
        api_key: Spree::Config[:shopify_api_key],
        password: Spree::Config[:shopify_password],
        shop_domain: Spree::Config[:shopify_shop_domain],
        token: Spree::Config[:shopify_token]
      }
    end

    def import!
      connect

      initiate_import!
    end

    private

    def connect
      set_current_credentials
      ShopifyImport::Client.instance.get_connection(@credentials)
    end

    def set_current_credentials
      Spree::Config[:shopify_current_credentials] = @credentials
    end

    # TODO: custom params for fetchers
    def initiate_import!
      ROOT_FETCHERS.each do |fetchers|
        fetchers.new.import!
      end
    end
  end
end
