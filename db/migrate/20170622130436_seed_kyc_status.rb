class SeedKycStatus < ActiveRecord::Migration
  def change
    KycStatus.seed_data
  end
end
