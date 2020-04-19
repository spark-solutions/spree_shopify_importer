module SpreeShopifyImporter
  module DataSavers
    module Images
      class ImageCreator < ImageBase
        def initialize(shopify_data_feed, spree_object)
          super(shopify_data_feed)
          @spree_object = spree_object # can be product or variant
        end

        def create!
          return unless valid_path?
          return if @spree_object.images.pluck(:attachment_file_name).include?(name)

          Spree::Image.transaction do
            create_spree_image
            assign_spree_image_to_data_feed
          end

          update_timestamps
          @spree_image
        end

        private

        def create_spree_image
          # TODO: Needs to be corrected for spree > 4.0
          @spree_image = Spree::Image.new(attributes_with_attachement)
          @spree_image.attachment.attach(
            io: File.new(attributes_with_attachement[:attachment_content_type]),
            filename: attributes_with_attachement[:alt],
            content_type: attributes_with_attachement[:attachment_content_type]
          ).save.save
          @spree_image.save!
          @spree_object.images << @spree_image
        end
      end
    end
  end
end
