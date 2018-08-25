class CreateBudgetEntityMappings < ActiveRecord::Migration
  def change
    create_table :budget_entity_mappings do |t|
      t.references :budget, index: true, foreign_key: true
      t.integer :entity_id
      t.string :entity_type

      t.timestamps null: false
    end
  end
end