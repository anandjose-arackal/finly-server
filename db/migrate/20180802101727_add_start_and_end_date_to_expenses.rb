class AddStartAndEndDateToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :usage_date_start, :datetime, index: true
    add_column :expenses, :usage_date_end, :datetime, index: true
    add_column :expenses, :usage_date_type, :string, index: true
  end
end
