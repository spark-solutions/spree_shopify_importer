module SpreeShopifyImporter
  module Connections
    class DeliveryProfile
      DELIVERY_PROFILE_QUERY = ShopifyAPI::GraphQL.new.parse <<-'GRAPHQL'
        query($id: ID!) {
          productVariant (id: $id) {
            deliveryProfile {
              id
              name
              default
            }
          }
        }
      GRAPHQL

      def initialize(product_variant_id)
        @product_variant_id = product_variant_id
      end

      def call
        response = ShopifyAPI::GraphQL.new.query(DELIVERY_PROFILE_QUERY, variables: { id: product_variant_id })

        return if response.data.product_variant.nil?

        response.data.product_variant.delivery_profile
      end

      private

      attr_reader :product_variant_id
    end
  end
end
