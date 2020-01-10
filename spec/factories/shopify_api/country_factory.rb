FactoryBot.define do
  factory :shopify_country, class: ShopifyAPI::Country do
    skip_create
    sequence(:id)   { |n| n }
    name            { 'Poland' }
    code            { 'PL' }
    provinces       { [] }
  end
end
