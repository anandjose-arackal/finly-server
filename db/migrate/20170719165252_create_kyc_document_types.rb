class CreateKycDocumentTypes < ActiveRecord::Migration
  def change
    create_table :company_kyc_document_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
