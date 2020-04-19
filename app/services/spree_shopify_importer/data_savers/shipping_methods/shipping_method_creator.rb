module SpreeShopifyImporter
  module DataSavers
    module ShippingMethods
      class ShippingMethodCreator
        def initialize(shopify_rate, delivery_profile_id)
          @shopify_rate = shopify_rate
          @delivery_profile_id = delivery_profile_id
        end

        def call
          find_shipping_method || create_shipping_method
        end

        private

        def find_shipping_method
          Spree::ShippingMethod.includes(:shipping_categories, :calculator).find_by(
            shipping_method_attributes.merge(
              spree_shipping_categories: { id: shipping_category.id },
              spree_calculators: { id: calculators_ids }
            )
          )
        end

        def create_shipping_method
          Spree::ShippingMethod.create!(shipping_method_attributes.merge(
            shipping_categories: [@shipping_category],
            calculator: calculator
          ))
        end

        def calculators_ids
          Spree::Calculator::Shipping::FlatRate
            .where(calculator_attributes)
            .select { |c| c.preferences[:amount] == @shopify_rate.price.to_f }.pluck(:id)
        end

        def calculator
          Spree::Calculator::Shipping::FlatRate.create!(calculator_attributes.merge(preferences: { amount: @shopify_rate.price.to_f }))
        end

        def calculator_attributes
          { type: "Spree::Calculator::Shipping::FlatRate",
            calculable_type: "Spree::ShippingMethod" }
        end

        def shipping_method_attributes
          { name: @shopify_rate.name,
            admin_name: shipping_category.name.split("/").first,
            display_on: "both" }
        end

        def shipping_category
          @shipping_category = Spree::ShippingCategory.where("name like ?", "%#{@delivery_profile_id}%").first_or_create!
        end
      end
    end
  end
end
