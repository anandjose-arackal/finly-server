class ChangeThresholdToMinMax < ActiveRecord::Migration[5.2]
  def change
    # Add to LRM
    add_column :level_reviewer_mappings, :min, :decimal, precision: 20, scale: 5, default: 0.0
    add_column :level_reviewer_mappings, :max, :decimal, precision: 20, scale: 5

    # Add to LURM
    add_column :level_user_reviewer_mappings, :min, :decimal, precision: 20, scale: 5, default: 0.0
    add_column :level_user_reviewer_mappings, :max, :decimal, precision: 20, scale: 5

    # Add to DLRM
    add_column :document_level_reviewer_mappings, :min, :decimal, precision: 20, scale: 5, default: 0.0
    add_column :document_level_reviewer_mappings, :max, :decimal, precision: 20, scale: 5
  end
end
