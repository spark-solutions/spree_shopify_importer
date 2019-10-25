class ChangeCollationForSpreeTagNames < ActiveRecord::Migration[4.2]
  def up
    if ActsAsTaggableOn::Utils.using_mysql?
      execute("ALTER TABLE spree_tags MODIFY name varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;")
    end
  end
end
