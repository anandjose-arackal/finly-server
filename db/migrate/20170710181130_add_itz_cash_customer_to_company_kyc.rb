class AddItzCashCustomerToCompanyKyc < ActiveRecord::Migration
  def change
    add_column :company_kycs, :customer_type_id, :integer
  end
end
