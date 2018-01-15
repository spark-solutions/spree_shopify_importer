module ShopifyImport
  module DataSavers
    module OptionValues
      class OptionValueCreator
        delegate :name, :attributes, to: :parser

        def initialize(shopify_value, spree_option_type)
          @shopify_value = shopify_value
          @spree_option_type = spree_option_type
        end

        def create!
          Spree::OptionValue.transaction do
            ::RedisMutex.with_lock("#{@spree_option_type.name}/#{name}") do
              Spree::OptionValue
                .where(option_type: @spree_option_type)
                .where('lower(name) = ?', name)
                .first_or_create!(attributes)
            end
          end
        end

        private

        def parser
          @parser ||= ShopifyImport::DataParsers::OptionValues::BaseData.new(@shopify_value)
        end
      end
    end
  end
end
