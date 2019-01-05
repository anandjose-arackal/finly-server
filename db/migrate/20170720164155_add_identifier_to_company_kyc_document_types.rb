class AddIdentifierToCompanyKycDocumentTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :company_kyc_document_types, :identifier, :string
  end
end
