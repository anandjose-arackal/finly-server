class CreateUserManagerMappings < ActiveRecord::Migration
  def change
    create_table :user_manager_mappings do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :manager_id, :references => "user", index: true, foreign_key: true
      t.integer :finance_manager_id, :references => "user", index: true, foreign_key: true
      t.integer :approves_to_id, :references => "user", index: true, foreign_key: true
      t.integer :approves_finance_to_id, :references => "user", index: true, foreign_key: true
      t.integer :greater_than_amount_id, :references => "amount", index: true, foreign_key: true
      t.boolean :default, default: false, null: false

      t.timestamps null: false
    end
  end
end
