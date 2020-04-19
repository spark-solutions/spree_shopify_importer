ShopifyAPI::Base.api_version = ENV["SHOPIFY_API_VERSION"]
ShopifyAPI::Base.site = "https://#{ENV["SHOPIFY_API_KEY"]}:#{ENV["SHOPIFY_API_PASSWORD"]}@#{ENV["SHOPIFY_API_DOMAIN"]}/admin/"
