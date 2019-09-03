class SeedSecurityDepositStatus < ActiveRecord::Migration[5.2]
  def change
    SecurityDepositStatus.seed_data
  end
end
