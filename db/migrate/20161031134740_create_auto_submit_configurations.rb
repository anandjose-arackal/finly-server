class CreateAutoSubmitConfigurations < ActiveRecord::Migration
  def change
    create_table :auto_submit_configs do |t|
      t.boolean :enabled, null: false, default: false
      t.boolean :limit_to_card_expenses, null: false, default: false
      t.references :period, index: true, foreign_key: true, null: false
      t.text :default_memo
      t.integer :default_policy_id, :references => 'policy', index: true, foreign_key: true
      t.references :submitable, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
