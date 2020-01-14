module SpreeShopifyImporter
  module DataSavers
    module TaxCategories
      class TaxCategoryCreator
        def initialize(delivery_profile)
          @delivery_profile = delivery_profile
        end

        def call
          Spree::TaxCategory.where(name: tax_category_name, is_default: delivery_profile.default).first_or_create!
        end

        private

        attr_reader :delivery_profile

        def tax_category_name
          "#{delivery_profile.name.upcase}/#{delivery_profile.id.split('/').last}"
        end
      end
    end
  end
end
