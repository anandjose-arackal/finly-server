class ChangeDescriptionToBeTextInInwardDocumentItems < ActiveRecord::Migration[5.2]
  def change
    change_column :inward_document_items, :description, :text
  end
end
