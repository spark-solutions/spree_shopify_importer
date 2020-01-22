module SpreeShopifyImporter
  module Importers
    class DeliveryProfileImporter
      def initialize(spree_product, shopify_product)
        @spree_product = spree_product
        @shopify_product = shopify_product
      end

      def call
        product_variant = shopify_product.variants.first

        return if product_variant.blank?

        delivery_profile = SpreeShopifyImporter::Connections::DeliveryProfile.new(product_variant.admin_graphql_api_id).call

        return if delivery_profile.blank?

        tax_category = SpreeShopifyImporter::DataSavers::TaxCategories::TaxCategoryCreator.new(delivery_profile).call
        spree_product.update!(tax_category: tax_category)
      end

      private

      attr_reader :spree_product, :shopify_product
    end
  end
end
