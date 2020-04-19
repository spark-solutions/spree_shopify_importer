module SpreeShopifyImporter
  module DataParsers
    module TaxRates
      class BaseData
        def initialize(spree_zone, shopify_object)
          @spree_zone = spree_zone
          @shopify_object = shopify_object
        end

        def attributes
          @attributes ||= {
            name: "Shopify/#{zone_name}/#{profile_name}",
            amount: amount,
            zone: @spree_zone,
            tax_category: tax_category,
            included_in_price: included_in_price,
            show_rate_in_label: false
          }
        end

        private

        def rest_of_world_zone?
          @shopify_object.is_a?(ShopifyAPI::ShippingZone)
        end

        def zone_name
          rest_of_world_zone? ? @shopify_object.countries.first.name : @shopify_object.name
        end

        def amount
          rest_of_world_zone? ? @shopify_object.countries.first.tax : @shopify_object.tax
        end

        def tax_category
          Spree::TaxCategory.where("name like ?", "#{profile_name}%").first_or_create!
        end

        def profile_name
          @spree_zone.name.split("/").last
        end

        def included_in_price
          JSON.parse(SpreeShopifyImporter::DataFeed.find_by(shopify_object_type: "ShopifyAPI::Shop").data_feed)["taxes_included"]
        end
      end
    end
  end
end
