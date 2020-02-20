module SpreeShopifyImporter
  module DataSavers
    module Adjustments
      class TaxCreator
        delegate :attributes, to: :parser

        def initialize(spree_line_item, shopify_tax_line, spree_order)
          @spree_line_item = spree_line_item
          @shopify_tax_line = shopify_tax_line
          @spree_order = spree_order
        end

        def create!
          @spree_order.adjustments.create!(attributes)
        end

        private

        def parser
          @parser ||= SpreeShopifyImporter::DataParsers::Adjustments::Tax::BaseData.new(@spree_line_item, @shopify_tax_line, @spree_order)
        end
      end
    end
  end
end
