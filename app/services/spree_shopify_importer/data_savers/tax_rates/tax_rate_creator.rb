module SpreeShopifyImporter
  module DataSavers
    module TaxRates
      class TaxRateCreator < BaseDataSaver
        delegate :attributes, to: :parser

        def initialize(spree_zone, shopify_object)
          @spree_zone = spree_zone
          @shopify_object = shopify_object
        end

        def create!
          Spree::TaxRate.transaction do
            Spree::TaxRate.create_with(calculator: calculator)
                          .where(name: attributes[:name])
                          .first_or_create!(attributes)
                          .update!(attributes)
          end
        end

        private

        def calculator
          @calculator ||= Spree::Calculator::ShopifyTax.create!
        end

        def parser
          @parser ||= SpreeShopifyImporter::DataParsers::TaxRates::BaseData.new(@spree_zone, @shopify_object)
        end
      end
    end
  end
end
