class AddItzCashCustomerToCompanyKyc < ActiveRecord::Migration[4.2]
  def change
    add_column :company_kycs, :customer_type_id, :integer
  end
end
