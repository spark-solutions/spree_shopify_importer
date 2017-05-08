module ShopifyImport
  module Products
    class Create
      def initialize(shopify_data_feed)
        @shopify_data_feed = shopify_data_feed
      end

      def save!
        Spree::Product.transaction(isolation: :serializable) do
          @spree_product = create_spree_product
          assign_spree_product_to_data_feed
          add_option_types
          add_tags
        end
      end

      private

      def create_spree_product
        Spree::Product.create!(product_attributes)
      end

      def assign_spree_product_to_data_feed
        @shopify_data_feed.update!(spree_object: @spree_product)
      end

      def add_tags
        return unless @spree_product.respond_to?(:tag_list)

        @spree_product.tag_list.add(product_tags, parse: true)
        @spree_product.save!
      end

      def add_option_types
        return if shopify_product.options.blank?

        @spree_product.update!(option_type_ids: create_option_types)
      end

      def create_option_types
        option_types_data.map do |option_type, option_values|
          spree_option_type = Spree::OptionType.where(name: option_type).first_or_create!(presentation: option_type)
          create_option_values(spree_option_type, option_values)
          spree_option_type.id
        end
      end

      def create_option_values(spree_option_type, option_values)
        option_values.each do |option_value|
          spree_option_type
            .option_values.where('lower(name) = ?', option_value)
            .first_or_create! do |ov|
            ov.name = option_value
            ov.presentation = option_value
          end
        end
      end

      def product_attributes
        parser.product_attributes
      end

      def product_tags
        parser.product_tags
      end

      def option_types_data
        parser.option_types
      end

      def parser
        @parser ||= DataParsers::BaseData.new(shopify_product)
      end

      def shopify_product
        @shopify_product ||= ShopifyAPI::Product.new(JSON.parse(@shopify_data_feed.data_feed))
      end
    end
  end
end
