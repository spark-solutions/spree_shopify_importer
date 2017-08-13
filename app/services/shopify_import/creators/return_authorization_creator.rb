module ShopifyImport
  module Creators
    class ReturnAuthorizationCreator < BaseCreator
      attr_reader :spree_return_authorization
      delegate :number, :attributes, :timestamps, to: :parser

      def initialize(shopify_data_feed, spree_order)
        super(shopify_data_feed)
        @spree_order = spree_order
      end

      def save!
        Spree::ReturnAuthorization.transaction do
          create_return_authorization
          assign_spree_return_authorization_to_data_feed
        end
        update_timestamps
      end

      private

      def create_return_authorization
        @spree_return_authorization = Spree::ReturnAuthorization.find_or_initialize_by(number: number)
        @spree_return_authorization.assign_attributes(attributes)
        @spree_return_authorization.save(validate: false)
      end

      def assign_spree_return_authorization_to_data_feed
        @shopify_data_feed.update!(spree_object: @spree_return_authorization)
      end

      def update_timestamps
        @spree_return_authorization.update_columns(timestamps)
      end

      def parser
        @parser ||= ShopifyImport::DataParsers::ReturnAuthorizations::BaseData.new(shopify_refund, @spree_order)
      end

      def shopify_refund
        @shopify_refund ||= ShopifyAPI::Refund.new(data_feed)
      end
    end
  end
end
