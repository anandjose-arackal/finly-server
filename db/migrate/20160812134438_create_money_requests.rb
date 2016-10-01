class CreateMoneyRequests < ActiveRecord::Migrationpayment_id
  def change
    create_table :payment_modes do |t|
      t.string :name

      t.timestamps null: false
    end
    create_table :money_requests do |t|
      t.string :name
      t.references :user, index: true, foreign_key: true, null: false
      t.references :policy, index: true, foreign_key: true
      t.references :payment_mode, index: true, foreign_key: true, null: false
      t.references :payment, index: true, foreign_key: true
      t.date :required_by_date
      t.integer :status_id, references: 'money_request_status', index: true, foreign_key: true, null: false
      t.integer :controlling_user_id, references: 'user', index: true, foreign_key: true
      t.integer :controlling_for_user_id, references: 'user', index: true, foreign_key: true
      t.integer :loaded_by, references: 'user', index: true, foreign_key: true
      t.datetime :loaded_at
      t.datetime :submitted_at, limit: 6
      t.string :note
      t.boolean :accounted, default: false, null: false

      t.timestamps null: false
    end
  end
end
