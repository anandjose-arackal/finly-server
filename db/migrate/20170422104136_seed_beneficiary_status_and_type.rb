class SeedBeneficiaryStatusAndType < ActiveRecord::Migration
  def change
    ItzCashDmtBeneficiaryType.seed_data
    ItzCashDmtBeneficiaryStatus.seed_data
  end
end
