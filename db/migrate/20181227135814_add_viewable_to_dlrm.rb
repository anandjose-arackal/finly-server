class AddViewableToDlrm < ActiveRecord::Migration
  def change
    add_column :document_level_reviewer_mappings, :viewable, :boolean, default: false
    add_column :document_level_reviewer_mappings, :became_viewable_at, :timestamp
  end
end
