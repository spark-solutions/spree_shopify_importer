require "singleton"

module SpreeShopifyImporter
  module Connections
    class ClientError < StandardError; end

    class Client
      include Singleton
      attr_reader :connection

      # Authenticates to Shopify as either a Shopify app with oauth token or a private app
      # This method can raise various ActiveResource errors:
      # https://github.com/rails/activeresource/blob/f8abaf13174e94d179227f352c9dd6fb8b03e0da/lib/active_resource/exceptions.rb
      # ActiveResource::ConnectionError
      # ActiveResource::TimeoutError
      # ActiveResource::SSLError
      # ActiveResource::Redirection < ConnectionError
      # ActiveResource::MissingPrefixParam
      # ActiveResource::ClientError < ConnectionError
      # ActiveResource::BadRequest < ClientError
      # ActiveResource::UnauthorizedAccess < ClientError - on invalid password, invalid auth token or invalid domain
      # ActiveResource::ForbiddenAccess < ClientError    - on invalid api_key
      # ActiveResource::ResourceNotFound < ClientError   - on invalid API endpoint
      # ActiveResource::ResourceConflict < ClientError
      # ActiveResource::ResourceGone < ClientError
      # ActiveResource::ServerError < ConnectionError
      # ActiveResource::MethodNotAllowed < ClientError
      def get_connection(api_key: nil, password: nil, shop_domain: nil, token: nil, api_version: nil)
        if api_key.present? && password.present?
          ShopifyAPI::Base.api_version = api_version
          ShopifyAPI::Base.site = "https://#{api_key}:#{password}@#{shop_domain}/admin/"
        elsif token.present?
          session = ShopifyAPI::Session.new(domain: shop_domain, token: token, api_version: api_version)
          ShopifyAPI::Base.activate_session(session)
        else
          raise SpreeShopifyImporter::Connections::ClientError, I18n.t("shopify_import.client.missing_credentials")
        end
      end
    end
  end
end
