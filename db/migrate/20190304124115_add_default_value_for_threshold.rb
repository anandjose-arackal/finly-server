class AddDefaultValueForThreshold < ActiveRecord::Migration[5.2]
  def change
    change_column :level_user_reviewer_mappings, :threshold, :decimal, precision: 20, scale: 5, default: 0.0
    change_column :level_reviewer_mappings, :threshold, :decimal, precision: 20, scale: 5, default: 0.0
  end
end
