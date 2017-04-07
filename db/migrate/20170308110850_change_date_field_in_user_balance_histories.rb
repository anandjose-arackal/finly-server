class ChangeDateFieldInUserBalanceHistories < ActiveRecord::Migration
  def up
    change_column :user_balance_histories, :date, :date
  end

  def down
    change_column :user_balance_histories, :date, :datetime
  end
end
