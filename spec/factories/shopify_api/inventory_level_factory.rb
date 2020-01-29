FactoryBot.define do
  factory :shopify_inventory_level, class: ShopifyAPI::InventoryLevel do
    skip_create
    inventory_item_id   { 5 }
    location_id         { 2 }
    available           { 10 }
  end
end
