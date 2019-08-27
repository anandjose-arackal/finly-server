class CreateIciciBankTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :icici_bank_transactions do |t|
      t.string :aggr_id
      t.string :aggr_name

      t.timestamps
    end
  end
end
