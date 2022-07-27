class ChangeProcurementTermTextType < ActiveRecord::Migration[6.0]
  def change
    change_column :purchase_orders, :procurement_term_text, :longtext
  end
end
