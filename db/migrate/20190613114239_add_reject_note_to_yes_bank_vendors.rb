class AddRejectNoteToYesBankVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :yes_bank_vendors, :reject_note, :string
  end
end
