class SeedKycStatus < ActiveRecord::Migration[4.2]
  def change
    KycStatus.seed_data
  end
end
