class ChangeTypeOfTheMoneyRequestMemo < ActiveRecord::Migration
  def change
    change_column :money_requests, :memo, :text
  end
end
