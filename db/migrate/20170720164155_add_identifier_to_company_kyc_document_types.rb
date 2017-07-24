class AddIdentifierToCompanyKycDocumentTypes < ActiveRecord::Migration
  def change
    add_column :company_kyc_document_types, :identifier, :string
  end
end
