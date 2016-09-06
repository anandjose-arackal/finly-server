class CreateBudgetPeriods < ActiveRecord::Migration
  def change
    create_table :budget_periods do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
