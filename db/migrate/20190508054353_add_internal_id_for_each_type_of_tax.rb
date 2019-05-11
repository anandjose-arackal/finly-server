class AddInternalIdForEachTypeOfTax < ActiveRecord::Migration[5.2]
  def change
    add_column :tax_rates, :igst_internal_id, :string
    add_column :tax_rates, :cgst_internal_id, :string
    add_column :tax_rates, :sgst_internal_id, :string
  end
end
