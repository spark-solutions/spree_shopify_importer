module SpreeShopifyImporter
  module DataSavers
    module ShippingCategories
      class ShippingCategoryCreator
        def initialize(tax_category)
          @tax_category = tax_category
        end

        def call
          Spree::ShippingCategory.where(name: tax_category.name).first_or_create!
        end

        private

        attr_reader :tax_category
      end
    end
  end
end
