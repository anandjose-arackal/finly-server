class AddUserConfirmedToCompanyKyc < ActiveRecord::Migration
  def change
    add_column :company_kycs, :user_confirmed, :boolean, default: false
  end
end
