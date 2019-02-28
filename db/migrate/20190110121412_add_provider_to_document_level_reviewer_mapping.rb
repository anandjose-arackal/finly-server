class AddProviderToDocumentLevelReviewerMapping < ActiveRecord::Migration[4.2]
  def change
    add_column :document_level_reviewer_mappings, :provider_name, :string
  end
end
