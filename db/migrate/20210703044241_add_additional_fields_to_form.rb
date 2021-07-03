class AddAdditionalFieldsToForm < ActiveRecord::Migration[6.0]
  def change
    add_column :forms, :label, :string
    add_column :forms, :primary_key_for_import, :string
  end
end
