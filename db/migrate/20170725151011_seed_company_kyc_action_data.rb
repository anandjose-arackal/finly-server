class SeedCompanyKycActionData < ActiveRecord::Migration[4.2]
  def change
    CompanyKycTrailAction.seed_data
  end
end
