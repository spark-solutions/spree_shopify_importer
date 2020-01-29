FactoryBot.define do
  factory :shopify_location, class: ShopifyAPI::Location do
    skip_create
    sequence(:id)   { |n| n }
    name            { 'Warehouse' }
    address1        { FFaker::Address.street_name }
    address2        { '' }
    city            { FFaker::Address.city }
    zip             { FFaker::Address.zip_code }
    phone           { ' ' }
    active          { true }
    country_code    { 'CA' }
    country_name    { 'Canada' }
    province_code   { 'AB' }
  end
end
