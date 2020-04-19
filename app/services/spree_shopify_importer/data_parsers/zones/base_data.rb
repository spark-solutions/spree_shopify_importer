module SpreeShopifyImporter
  module DataParsers
    module Zones
      class BaseData
        def initialize(shopify_object, parent_object, spree_zone_kind)
          @shopify_object = shopify_object
          @parent_object = parent_object
          @spree_zone_kind = spree_zone_kind
        end

        def attributes
          @attributes ||= {
            name: spree_zone_name,
            kind: @spree_zone_kind,
            description: spree_zone_description
          }
        end

        private

        def spree_zone_name
          "#{@parent_object.name}/#{@shopify_object.name}/#{profile_name}"
        end

        def spree_zone_description
          "Shopify shipping to #{@shopify_object.name}"
        end

        def profile_name
          Spree::TaxCategory.find_by("name like ?", "%#{@parent_object.profile_id.split('/').last}").name.split("/").first
        end
      end
    end
  end
end
