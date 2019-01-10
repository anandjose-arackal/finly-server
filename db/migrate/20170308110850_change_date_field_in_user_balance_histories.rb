class ChangeDateFieldInUserBalanceHistories < ActiveRecord::Migration[4.2]
  def up
    change_column :user_balance_histories, :date, :date
  end

  def down
    change_column :user_balance_histories, :date, :datetime
  end
end
