module SpreeShopifyImporter
  module Importers
    class ShopifyZoneImporter < BaseImporter
      def import!
        process_data_feed
        shipping_methods = create_spree_shipping_methods
        if @shopify_object.countries.first.name == "Rest of World"
          RestOfWorldZones::CreateJob.perform_later(@shopify_object.to_json, shipping_methods)
        else
          shipping_zone_members.each do |member|
            SpreeShopifyImporter::Importers::ZoneImporterJob.perform_later(member, @shopify_object.to_json, shipping_methods)
          end
        end
      end

      private

      def shipping_zone_members
        @shopify_object.countries.each_with_object([]) do |country, members|
          if country.provinces.present?
            country.provinces.each do |province|
              members << [province.to_json, country.to_json]
            end
          else
            members << [country.to_json]
          end
        end
      end

      def create_spree_shipping_methods
        delivery_profile_id = @shopify_object.profile_id.split("/").last
        shopify_rates = @shopify_object.weight_based_shipping_rates + @shopify_object.price_based_shipping_rates
        shopify_rates.map do |rate|
          SpreeShopifyImporter::DataSavers::ShippingMethods::ShippingMethodCreator.new(rate, delivery_profile_id).call
        end
      end

      def shopify_class
        ShopifyAPI::ShippingZone
      end
    end
  end
end
