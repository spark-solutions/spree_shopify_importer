module SpreeShopifyImporter
  module DataSavers
    module Zones
      class ZoneCreator < ZoneBase
        def initialize(shopify_object, parent_object, country = nil)
          @shopify_object = shopify_object
          @parent_object = parent_object
          @country = country
        end

        def create!
          Spree::Zone.transaction do
            @spree_zone = create_spree_zone
            assign_spree_zone_to_data_feed
            create_spree_zone_member
            update_rest_of_world_zone
            create_or_update_tax_rate
          end
        end

        private

        def assign_spree_zone_to_data_feed
          shopify_data_feed = SpreeShopifyImporter::DataFeed.find_by(shopify_object_id: @shopify_object.id,
                                                                     shopify_object_type: @shopify_object.class.to_s,
                                                                     parent_id: parent_feed.id)
          shopify_data_feed.update!(spree_object: @spree_zone)
        end

        def create_spree_zone
          Spree::Zone.create(attributes)
        end

        def parent_feed
          SpreeShopifyImporter::DataFeed.find_by(shopify_object_id: @parent_object.id,
                                                 shopify_object_type: @parent_object.class.to_s)
        end
      end
    end
  end
end
