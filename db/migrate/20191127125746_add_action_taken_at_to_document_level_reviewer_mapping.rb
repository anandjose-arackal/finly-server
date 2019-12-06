class AddActionTakenAtToDocumentLevelReviewerMapping < ActiveRecord::Migration[5.2]
  def change
    add_column :document_level_reviewer_mappings, :action_taken_at, :datetime
  end
end
