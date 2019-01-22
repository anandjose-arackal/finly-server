class AddPersonalToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :personal, :boolean, default: false
  end
end
