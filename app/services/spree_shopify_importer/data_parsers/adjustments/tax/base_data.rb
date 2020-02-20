module SpreeShopifyImporter
  module DataParsers
    module Adjustments
      module Tax
        class BaseData
          def initialize(spree_line_item, shopify_tax_line, spree_order)
            @spree_line_item = spree_line_item
            @shopify_tax_line = shopify_tax_line
            @spree_order = spree_order
          end

          def attributes
            @attributes ||= {
              order: @spree_order,
              adjustable: @spree_order,
              label: @shopify_tax_line.title,
              source: spree_tax_rate,
              amount: @shopify_tax_line.price,
              state: :closed
            }
          end

          private

          def spree_tax_rate
            Spree::TaxRate.find_by(zone: @spree_order.tax_zone, tax_category: @spree_line_item.tax_category)
          end
        end
      end
    end
  end
end
