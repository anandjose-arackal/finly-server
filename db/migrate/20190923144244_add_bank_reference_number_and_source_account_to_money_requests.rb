class AddBankReferenceNumberAndSourceAccountToMoneyRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :money_requests, :bank_reference_number, :string
    add_column :money_requests, :source_account, :string
  end
end
