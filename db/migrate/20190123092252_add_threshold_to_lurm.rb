class AddThresholdToLurm < ActiveRecord::Migration[5.2]
  def change
    add_column :level_user_reviewer_mappings, :threshold, :decimal, precision: 20, scale: 5
  end
end
