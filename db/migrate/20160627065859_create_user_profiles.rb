class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.references :user, index: true, foreign_key: true
      t.attachment :avatar
      t.boolean :kyc_verified
      t.string :gcm_sender_id
      t.integer :employee_id
      t.integer :payroll_id
      t.integer :default_currency_id, :references => "currency", index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
