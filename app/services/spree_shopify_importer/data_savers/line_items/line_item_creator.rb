module SpreeShopifyImporter
  module DataSavers
    module LineItems
      class LineItemCreator < BaseDataSaver
        def initialize(shopify_line_item, shopify_order, spree_order)
          @shopify_line_item = shopify_line_item
          @shopify_order = shopify_order
          @spree_order = spree_order
        end

        def create
          return if spree_variant.blank?

          line_item = @spree_order.line_items.find_or_initialize_by(variant: spree_variant)
          line_item.assign_attributes(parser.line_item_attributes)
          line_item.save(validate: false)
          line_item
        end

        private

        def spree_variant
          parser.variant
        end

        def parser
          @parser ||= SpreeShopifyImporter::DataParsers::LineItems::BaseData.new(@shopify_line_item, @shopify_order)
        end
      end
    end
  end
end
