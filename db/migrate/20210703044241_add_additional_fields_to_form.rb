class AddAdditionalFieldsToForm < ActiveRecord::Migration[6.0]
  def change
    add_column :forms, :label, :string
  end
end
