class ChangeColumnNamesInLinItems < ActiveRecord::Migration
  def change
    rename_column :invoice_line_items, :name, :description
  end
end
