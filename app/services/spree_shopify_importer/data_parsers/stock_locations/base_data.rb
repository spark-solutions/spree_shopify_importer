module SpreeShopifyImporter
  module DataParsers
    module StockLocations
      class BaseData
        def initialize(shopify_location)
          @shopify_location = shopify_location
        end

        def attributes
          @attributes ||= {
            name: stock_location_name,
            address1: @shopify_location.address1,
            address2: @shopify_location.address2,
            city: @shopify_location.city,
            zipcode: @shopify_location.zip,
            phone: @shopify_location.phone,
            country: country,
            state: state,
            active: @shopify_location.active
          }
        end

        private

        def stock_location_name
          "#{@shopify_location.name}/#{@shopify_location.id}"
        end

        def country
          @country = Spree::Country.find_by(iso: @shopify_location.country_code, name: @shopify_location.country_name)
        end

        def state
          Spree::State.find_by(country_id: @country&.id, abbr: @shopify_location.province_code)
        end
      end
    end
  end
end
