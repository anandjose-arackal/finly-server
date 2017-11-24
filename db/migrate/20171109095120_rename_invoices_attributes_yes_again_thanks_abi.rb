class RenameInvoicesAttributesYesAgainThanksAbi < ActiveRecord::Migration
  def change
    rename_column :invoices, :tax_rate, :tax
  end
end
