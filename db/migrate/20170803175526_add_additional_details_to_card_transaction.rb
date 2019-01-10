class AddAdditionalDetailsToCardTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :card_transactions, :success, :boolean
    add_column :card_transactions, :acquirer_id, :string
    add_column :card_transactions, :mid, :string
    add_column :card_transactions, :tid, :string
    add_column :card_transactions, :transaction_message, :text
    CardTransaction.where(type_of_details: nil).update_all(type_of_details: 'T')
    CardTransaction.where(type_of_details: ['T', 'S', 'F']).update_all(success: true)
  end
end
