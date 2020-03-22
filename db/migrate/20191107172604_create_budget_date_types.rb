class CreateBudgetDateTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_date_types do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    BudgetDateType.seed_data
  end
end
