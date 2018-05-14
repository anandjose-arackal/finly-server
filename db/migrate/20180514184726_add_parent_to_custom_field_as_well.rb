class AddParentToCustomFieldAsWell < ActiveRecord::Migration
  def change
    add_column :custom_fields, :dependent_parent_id, :integer, foreign_key: true, index: true
    add_column :custom_fields, :dependent_parent_type, :string, foreign_key: true, index: true
  end
end
