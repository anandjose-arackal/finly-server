class CreatePaymentsReceivables < ActiveRecord::Migration[4.2]
  def change
    create_table :payments_receivables do |t|
      t.references :customer, index: true, foreign_key: true
      t.references :amount, index: true, foreign_key: true
      t.text :purpose
      t.date :expire_by
      t.references :company, index: true, foreign_key: true
      t.integer :initiating_user_id, references: "User", index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
