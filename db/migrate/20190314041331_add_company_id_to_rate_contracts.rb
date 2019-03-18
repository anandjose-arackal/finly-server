class AddCompanyIdToRateContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_contracts, :company_id, :integer
  end
end
