class AddCompanyIdToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :company_id, :integer
  end
end
