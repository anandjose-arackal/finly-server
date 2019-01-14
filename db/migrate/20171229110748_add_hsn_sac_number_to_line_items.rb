class AddHsnSacNumberToLineItems < ActiveRecord::Migration[4.2]
  def change
    add_column :invoice_line_items, :hsn_sac, :string
  end
end
