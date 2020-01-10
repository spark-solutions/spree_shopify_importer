module SpreeShopifyImporter
  module Importers
    class ZoneImporter < BaseImporter
      def initialize(resource, parent_object)
        @resource = resource
        @parent_object = ShopifyAPI::ShippingZone.new(JSON.parse(parent_object))
        @country = country
      end

      def import!
        if (spree_object = process_data_feed.spree_object).blank?
          creator.new(@shopify_object, @parent_object, @country).create!
        else
          updater.new(@shopify_object, @parent_object, @country, spree_object).update!
        end
      end

      private

      def find_existing_data_feed
        return if shopify_object.blank?

        SpreeShopifyImporter::DataFeed.find_by(shopify_object_id: @shopify_object.id,
                                               shopify_object_type: @shopify_object.class.to_s,
                                               parent_id: parent_feed.id)
      end

      def create_data_feed
        SpreeShopifyImporter::DataFeeds::Create.new(@shopify_object, @parent_feed).save!
      end

      def update_data_feed(old_data_feed)
        SpreeShopifyImporter::DataFeeds::Update.new(old_data_feed, @shopify_object, @parent_feed).update!
      end

      def parent_feed
        @parent_feed = SpreeShopifyImporter::DataFeed.find_by(shopify_object_id: @parent_object.id,
                                                              shopify_object_type: @parent_object.class.to_s)
      end

      def creator
        SpreeShopifyImporter::DataSavers::Zones::ZoneCreator
      end

      def updater
        SpreeShopifyImporter::DataSavers::Zones::ZoneUpdater
      end

      def country
        ShopifyAPI::Country.new(JSON.parse(@resource.last))
      end

      def shopify_object
        @shopify_object = shopify_object_class.new(JSON.parse(@resource.first))
      end

      def shopify_object_class
        @resource.second ? ShopifyAPI::Province : ShopifyAPI::Country
      end
    end
  end
end
