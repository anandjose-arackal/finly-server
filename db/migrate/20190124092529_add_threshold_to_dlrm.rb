class AddThresholdToDlrm < ActiveRecord::Migration[5.2]
  def change
    add_column :document_level_reviewer_mappings, :threshold, :decimal, precision: 20, scale: 5
  end
end
