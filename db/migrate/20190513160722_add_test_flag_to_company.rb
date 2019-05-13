class AddTestFlagToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :test_account, :boolean, default: false
    Company.second&.update(test_account: true)
  end
end
