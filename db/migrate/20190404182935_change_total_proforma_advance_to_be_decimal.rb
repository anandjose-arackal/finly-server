class ChangeTotalProformaAdvanceToBeDecimal < ActiveRecord::Migration[5.2]
  def change
  	change_column :invoices, :total_proforma_advance, :decimal, precision: 20, scale: 2
  end
end
