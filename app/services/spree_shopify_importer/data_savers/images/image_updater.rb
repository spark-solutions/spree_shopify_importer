module SpreeShopifyImporter
  module DataSavers
    module Images
      class ImageUpdater < ImageBase
        def initialize(shopify_data_feed, spree_image)
          super(shopify_data_feed)
          @spree_image = spree_image
        end

        def update!
          Spree::Image.transaction do
            return unless valid_path?

            update_spree_image
            assign_spree_image_to_data_feed
          end
          update_timestamps
        end

        private

        def update_spree_image
          @spree_image.update!(attributes_with_attachement)
        end
      end
    end
  end
end
