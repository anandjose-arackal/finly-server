class AddRejectedByIdToDocumentLevelReviewerMappings < ActiveRecord::Migration[5.2]
  def change
    add_column :document_level_reviewer_mappings, :rejected_by_id, :integer, foreign_key: true, references: 'User'
    add_index :document_level_reviewer_mappings, :rejected_by_id
  end
end
