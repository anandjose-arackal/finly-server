class RenameInvoicesAttributesYesAgainThanksAbi < ActiveRecord::Migration[4.2]
  def change
    rename_column :invoices, :tax_rate, :tax
  end
end
