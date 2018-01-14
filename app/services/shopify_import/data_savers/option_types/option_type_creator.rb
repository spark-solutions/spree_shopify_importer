module ShopifyImport
  module DataSavers
    module OptionTypes
      class OptionTypeCreator
        delegate :name, :attributes, :shopify_values, to: :parser

        def initialize(shopify_option_type)
          @shopify_option_type = shopify_option_type
        end

        def create!
          Spree::OptionType.transaction do
            @spree_option_type = find_or_create_option_type

            ::RedisMutex.with_lock(@spree_option_type, block: 2) do
              create_option_values
            end
          end
          @spree_option_type
        end

        private

        def find_or_create_option_type
          Spree::OptionType.where('lower(name) = ?', name).first_or_create!(attributes)
        end

        def create_option_values
          shopify_values.each do |value|
            ShopifyImport::DataSavers::OptionValues::OptionValueCreator.new(value, @spree_option_type).create!
          end
        end

        def parser
          @parser ||= ShopifyImport::DataParsers::OptionTypes::BaseData.new(@shopify_option_type)
        end
      end
    end
  end
end
