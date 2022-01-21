class SeedEmailApprovalStatus < ActiveRecord::Migration[6.0]
  def change
    EmailApprovalStatus.seed_data
  end
end
