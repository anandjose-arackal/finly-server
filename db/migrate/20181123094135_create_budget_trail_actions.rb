class CreateBudgetTrailActions < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_modification_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
