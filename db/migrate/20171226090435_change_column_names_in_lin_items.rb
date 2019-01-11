class ChangeColumnNamesInLinItems < ActiveRecord::Migration[4.2]
  def change
    rename_column :invoice_line_items, :name, :description
  end
end
