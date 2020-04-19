def authenticate_with_shopify
  SpreeShopifyImporter::Connections::Client.instance.get_connection(credentials)
end

def credentials
  {
    api_key: "0a9445b7b067719a0af024610364ee34",
    password: "800f97d6ea1a768048851cdd99a9101a",
    shop_domain: "spree-shopify-importer-test-store.myshopify.com",
    api_version: "2019-10"
  }
end
