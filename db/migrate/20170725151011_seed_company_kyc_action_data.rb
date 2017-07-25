class SeedCompanyKycActionData < ActiveRecord::Migration
  def change
    CompanyKycTrailAction.seed_data
  end
end
