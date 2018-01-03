class AddHsnSacNumberToLineItems < ActiveRecord::Migration
  def change
    add_column :invoice_line_items, :hsn_sac, :string
  end
end
