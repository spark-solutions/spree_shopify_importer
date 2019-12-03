module SpreeShopifyImporter
  module DataSavers
    module Addresses
      class AddressCreator < AddressBase
        def initialize(shopify_data_feed, spree_user, is_order = false)
          super(shopify_data_feed)
          @spree_user = spree_user
          @is_order = is_order
        end

        def create!
          create_spree_address
          create_user_shipping_and_billing_addresses unless @is_order
          assigns_spree_address_to_data_feed unless @is_order
          @spree_address
        end

        private

        def create_user_shipping_and_billing_addresses
          return unless shopify_address.default?

          default_address = Spree::Address.new(attributes)
          @spree_user.ship_address = default_address
          @spree_user.bill_address = default_address
          @spree_user.save(validate: false)
        end

        def create_spree_address
          # Spree Orders should not be users addresses same time.
          @spree_address = (@is_order ? Spree::Address : @spree_user.addresses).new(attributes)

          # Shopify has'n got validation for filed like zipcode, city or province code.
          @spree_address.save(validate: false)
        end
      end
    end
  end
end
