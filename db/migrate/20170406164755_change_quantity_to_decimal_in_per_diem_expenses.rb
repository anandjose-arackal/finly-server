class ChangeQuantityToDecimalInPerDiemExpenses < ActiveRecord::Migration[4.2]
  def change
    change_column :per_diem_expenses, :quantity, :decimal, :precision => 10, scale: 4
  end
end
