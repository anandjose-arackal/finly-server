class FixColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :invoices, :add_agreement_based_next_due_date, :agreement_based_next_due_date
  end
end
