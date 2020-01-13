class ChangeRejectNoteSizeInYesBankVendors < ActiveRecord::Migration[5.2]
  def change
  	change_column :yes_bank_vendors, :reject_note, :text
  end
end
