module SpreeShopifyImporter
  module DataSavers
    module TaxCategories
      class TaxCategoryCreator
        def initialize(delivery_profile)
          @delivery_profile = delivery_profile
        end

        def call
          Spree::TaxCategory.where(name: delivery_profile.name, is_default: delivery_profile.default).first_or_create!
        end

        private

        attr_reader :delivery_profile
      end
    end
  end
end
