class ChangeTypeOfTheMoneyRequestMemo < ActiveRecord::Migration[4.2]
  def change
    change_column :money_requests, :memo, :text
  end
end
