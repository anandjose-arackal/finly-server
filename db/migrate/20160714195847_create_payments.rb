class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :amount, index: true, foreign_key: true, null: false
      t.date :date, null: false
      t.references :payment_type, index: true, foreign_key: true, null: false
      t.integer :initiating_user_id, :references => "user", index: true, foreign_key: true, null: false
      t.integer :receiving_user_id, :references => "user", index: true, foreign_key: true, null: false
      t.text :note

      t.timestamps null: false
    end
  end
end
