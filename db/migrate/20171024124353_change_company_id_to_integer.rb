class ChangeCompanyIdToInteger < ActiveRecord::Migration
  def change
    change_column :virtual_bank_accounts, :company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end
