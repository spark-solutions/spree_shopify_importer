module SpreeShopifyImporter
  module Importers
    class DeliveryProfileImporter
      def initialize(spree_variant, shopify_variant)
        @spree_variant = spree_variant
        @shopify_variant = shopify_variant
      end

      def call

        return if product_variant.blank? || product_variant.admin_graphql_api_id.blank?

        delivery_profile = SpreeShopifyImporter::Connections::DeliveryProfile.new(@shopify_variant.admin_graphql_api_id).call

        return if delivery_profile.blank?

        tax_category = SpreeShopifyImporter::DataSavers::TaxCategories::TaxCategoryCreator.new(delivery_profile).call
        @spree_variant.update!(tax_category: tax_category)
      end

      private

      attr_reader :spree_variant, :shopify_variant
    end
  end
end
