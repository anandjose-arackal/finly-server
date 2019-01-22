class CreateAutoReloadConfigs < ActiveRecord::Migration[4.2]
  def change
    create_table :auto_reload_configs do |t|
      t.integer :minimum_balance_id, references: "Amount"
      t.references :parent, polymorphic: true

      t.timestamps null: false
    end
  end
end
