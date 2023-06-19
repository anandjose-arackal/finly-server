class AddHiddenColumnToForm < ActiveRecord::Migration[6.0]
  def change
    add_column :forms, :hidden, :boolean
  end
end
