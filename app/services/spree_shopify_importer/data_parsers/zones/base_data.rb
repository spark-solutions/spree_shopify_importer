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

        # TODO change profile_id for profile_name, when it will be known
        def spree_zone_name
          "#{@parent_object.name}/#{@parent_object.profile_id.split('/').last}/#{@shopify_object.name}"
        end

        def spree_zone_description
          "shopify shipping to #{@shopify_object.name}"
        end
      end
    end
  end
end
