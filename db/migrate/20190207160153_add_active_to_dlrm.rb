class AddActiveToDlrm < ActiveRecord::Migration[5.2]
  def change
    add_column :document_level_reviewer_mappings, :active, :boolean, default: true
    remove_column :document_level_reviewer_mappings, :became_viewable_at, :timestamp
  end
end