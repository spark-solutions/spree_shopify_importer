class ChangeUniqueIndexToSpreeShopifyImporterDataFeeds < ActiveRecord::Migration[6.0]
  def change
    remove_index :spree_shopify_importer_data_feeds, [:shopify_object_id, :shopify_object_type]

    add_index :spree_shopify_importer_data_feeds, [:shopify_object_id, :shopify_object_type, :parent_id],
              name: 'index_shopify_object_id_shopify_object_type_parent_id', unique: true
  end
end
