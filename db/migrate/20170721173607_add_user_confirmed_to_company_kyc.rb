class AddUserConfirmedToCompanyKyc < ActiveRecord::Migration[4.2]
  def change
    add_column :company_kycs, :user_confirmed, :boolean, default: false
  end
end
