class CreateCollectTransactionVirtualAccountMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :collect_transaction_virtual_account_mappings do |t|
      t.integer :virtual_account_id, references: "VirtualBankAccount", foreign_key: true
      t.integer :transaction_purpose_id, references: "CollectTransactionPurpose", foreign_key: true

      t.timestamps null: false
    end
  end
end
