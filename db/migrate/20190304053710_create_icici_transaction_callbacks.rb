class CreateIciciTransactionCallbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :icici_transaction_callbacks do |t|
      t.string :AGGRNAME
      t.string :AGGRID
      t.string :URN
      t.string :UNIQUEID
      t.string :REQUESTID
      t.string :TXNSTATUS
      t.string :UTRNUMBER
      t.string :CORPID
      t.string :USERID

      t.timestamps
    end
  end
end
