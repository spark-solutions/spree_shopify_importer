module SpreeShopifyImporter
  module DataSavers
    module Zones
      class ZoneUpdater < ZoneBase
        def initialize(shopify_object, parent_object, spree_zone, shipping_methods, country = nil)
          @shopify_object = shopify_object
          @parent_object = parent_object
          @country = country
          @spree_zone = spree_zone
          @shipping_methods = shipping_methods
        end

        def update!
          Spree::Zone.transaction do
            update_spree_zone
            destroy_old_spree_zone_member
            create_spree_zone_member
            update_rest_of_world_zone
            create_or_update_tax_rate
            assign_zone_to_shipping_methods
          end
        end

        private

        def update_spree_zone
          @spree_zone.update!(attributes)
        end

        def destroy_old_spree_zone_member
          Spree::ZoneMember.where(zone_id: @spree_zone.id).destroy_all
        end
      end
    end
  end
end
