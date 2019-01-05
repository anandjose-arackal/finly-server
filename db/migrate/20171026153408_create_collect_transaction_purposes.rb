class CreateCollectTransactionPurposes < ActiveRecord::Migration[4.2]
  def change
    create_table :collect_transaction_purposes do |t|
      t.string :name

      t.timestamps null: false
    end

    CollectTransactionPurpose.seed_data
  end
end
