class AddProviderToDocumentLevelReviewerMapping < ActiveRecord::Migration
  def change
    add_column :document_level_reviewer_mappings, :provider_name, :string
  end
end
