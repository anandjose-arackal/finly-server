class CreateKycDocuments < ActiveRecord::Migration[4.2]
  def change
    create_table :kyc_documents do |t|
      t.references :company_kyc_document_type, index: true, foreign_key: true
      t.references :company_kyc, index: true, foreign_key: true

      t.attachment :doc

      t.timestamps null: false
    end
  end
end
