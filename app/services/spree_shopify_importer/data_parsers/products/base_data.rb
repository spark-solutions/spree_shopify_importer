module SpreeShopifyImporter
  module DataParsers
    module Products
      class BaseData
        def initialize(shopify_product)
          @shopify_product = shopify_product
        end

        def attributes
          @attributes ||= {
            name: @shopify_product.title,
            description: @shopify_product.body_html,
            available_on: @shopify_product.published_at,
            slug: @shopify_product.handle,
            price: @shopify_product.variants.first.try(:price) || 0,
            created_at: @shopify_product.created_at,
            shipping_category: shipping_category
          }
        end

        def tags
          @tags ||= @shopify_product.tags
        end

        def options
          @options ||= @shopify_product.options
        end

        private

        def shipping_category
          Spree::ShippingCategory.find_or_create_by!(name: I18n.t(:shopify))
        end
      end
    end
  end
end
