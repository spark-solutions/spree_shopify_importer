FactoryGirl.define do
  factory :shopify_refund, class: ShopifyAPI::Refund do
    skip_create

    sequence(:id) { |n| 200_000_000 + n }
    sequence(:order_id) { |n| 100_000_000 + n }
    note 'it broke during shipping'
    restock true
    sequence(:user_id) { |n| 300_000_000 + n }
    created_at '2017-01-05T15:40:07-05:00'
    processed_at '2017-01-05T15:40:07-05:00'
    refund_line_items []
    transactions []
    order_adjustments []
  end
end
