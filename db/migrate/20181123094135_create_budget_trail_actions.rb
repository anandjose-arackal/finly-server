class CreateBudgetTrailActions < ActiveRecord::Migration
  def change
    create_table :budget_modification_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
