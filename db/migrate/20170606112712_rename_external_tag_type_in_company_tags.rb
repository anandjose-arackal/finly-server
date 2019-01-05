class RenameExternalTagTypeInCompanyTags < ActiveRecord::Migration[4.2]
  def change
    rename_column :company_tags, :external_tag_id, :external_tag_type
  end
end
