class CreateEmailApprovalDocumentType < ActiveRecord::Migration[6.0]
  def change
    create_table :email_approval_document_types do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end