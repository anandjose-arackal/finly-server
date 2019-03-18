class CreateIciciBankCompanyAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :icici_bank_company_accounts do |t|

      t.timestamps
    end
  end
end
