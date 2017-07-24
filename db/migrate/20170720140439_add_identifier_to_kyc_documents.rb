class AddIdentifierToKycDocuments < ActiveRecord::Migration
  def change
    add_column :kyc_documents, :identifier, :string
  end
end
