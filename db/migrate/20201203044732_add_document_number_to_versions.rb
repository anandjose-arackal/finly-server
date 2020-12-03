class AddDocumentNumberToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :document_number, :string, null: true
  end
end
