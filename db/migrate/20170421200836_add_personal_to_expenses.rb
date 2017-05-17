class AddPersonalToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :personal, :boolean, default: false
  end
end
