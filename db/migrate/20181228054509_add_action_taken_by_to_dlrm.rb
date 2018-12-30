class AddActionTakenByToDlrm < ActiveRecord::Migration
  def change
    add_column :document_level_reviewer_mappings, :action_taken_by_id, :integer, references: 'User', foreign_key: true
    add_column :document_level_reviewer_mappings, :action_id, :integer, references: 'TrailAction', foreign_key: true
  end
end
