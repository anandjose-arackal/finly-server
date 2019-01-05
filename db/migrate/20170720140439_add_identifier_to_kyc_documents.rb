class AddIdentifierToKycDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :kyc_documents, :identifier, :string
  end
end
