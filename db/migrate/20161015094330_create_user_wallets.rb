class CreateUserWallets < ActiveRecord::Migration
  def change
    create_table :user_wallet_track_actions do |t|
      t.string name, null: false

      t.timestamps null: false
    end
    create_table :user_wallets do |t|
      t.integer :balance_id, :references => 'amount', index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    create_table :user_wallet_tracks do |t|
      t.references :user_wallet, index: true, foreign_key: true, null: false
      t.references :user_wallet_track_action, index: true, foreign_key: true, null: false
      t.references :amount, index: true, foreign_key: true, null: false
      t.integer :action_user_id, :references => 'user', index: true, foreign_key: true, null: false
      t.integer :balance_after_action_id, :references => 'amount', index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
