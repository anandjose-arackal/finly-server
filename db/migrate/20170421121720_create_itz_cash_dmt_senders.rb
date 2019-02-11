class CreateItzCashDmtSenders < ActiveRecord::Migration[4.2]
  def change
    create_table :itz_cash_dmt_senders do |t|
      t.string :username, null: false
      t.string :mobile_number, null: false
      t.string :registration_id, null: false
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
