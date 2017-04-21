Spree::AppConfiguration.class_eval do
  preference :shopify_api_key, :string, default: 'api_key'
  preference :shopify_password, :string, default: 'password'
  preference :shopify_shop_name, :string, default: 'shop_name'
end
