class SeedBeneficiaryStatusAndType < ActiveRecord::Migration[4.2]
  def change
    # ItzCashDmtBeneficiaryType.seed_data
    ItzCashDmtBeneficiaryStatus.seed_data
  end
end
