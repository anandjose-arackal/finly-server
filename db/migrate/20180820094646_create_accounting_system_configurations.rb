class CreateAccountingSystemConfigurations < ActiveRecord::Migration[4.2]
  def change
    create_table :accounting_system_configurations do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.boolean :enabled, default: false
      t.string :accounting_system, index: true
      t.text :options

      t.timestamps null: false
    end
  end
end
