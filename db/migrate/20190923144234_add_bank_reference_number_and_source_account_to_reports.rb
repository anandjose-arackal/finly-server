class AddBankReferenceNumberAndSourceAccountToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :bank_reference_number, :string
    add_column :reports, :source_account, :string
  end
end
