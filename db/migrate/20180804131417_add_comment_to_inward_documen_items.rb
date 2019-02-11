class AddCommentToInwardDocumenItems < ActiveRecord::Migration[4.2]
  def change
    add_column :inward_document_items, :comment, :string
    add_column :inward_document_items, :previously_delivered,:decimal, precision: 20, scale: 5
    change_column :inward_document_items, :quantity,:decimal, precision: 20, scale: 5
    change_column :inward_document_items, :delivered,:decimal, precision: 20, scale: 5
    change_column :inward_document_items, :accepted,:decimal, precision: 20, scale: 5
    change_column :inward_document_items, :rejected,:decimal, precision: 20, scale: 5
  end
end
