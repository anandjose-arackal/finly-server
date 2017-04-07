class AllowCustomFieldToHaveNullParent < ActiveRecord::Migration
  def change
    change_column :custom_fields, :parent_id, :integer, foreign_key: true, index: true, null: true
    change_column :custom_fields, :parent_type, :string, foreign_key: true, index: true, null: true

    change_column :custom_fields, :value_id, :integer, foreign_key: true, index: true, null: true
    change_column :custom_fields, :value_type, :string, foreign_key: true, index: true, null: true
  end
end
