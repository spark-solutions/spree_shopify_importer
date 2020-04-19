FactoryBot.define do
  factory :shopify_shipping_zone, class: ShopifyAPI::ShippingZone do
    skip_create
    sequence(:id)   { |n| n }
    name            { "Domestic" }
    profile_id      { "gid://shopify/DeliveryProfile/18869387313" }
    countries       { build_list(:shopify_country, 1) }
  end
end
