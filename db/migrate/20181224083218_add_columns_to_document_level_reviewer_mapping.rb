class AddColumnsToDocumentLevelReviewerMapping < ActiveRecord::Migration
  def change
    add_column :document_level_reviewer_mappings, :level_number, :integer
    add_column :document_level_reviewer_mappings, :taken_control, :boolean, default: false
    add_column :document_level_reviewer_mappings, :taken_control_by_id, :integer, references: 'User', index: true, foreign_key: true
  end
end
