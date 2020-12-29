class AddParentDocumentTypeToVersions < ActiveRecord::Migration[6.0]
  def change
      add_column :versions, :parent_document_type, :string, null: true
  end
end
