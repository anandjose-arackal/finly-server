class AddMoreStatusesForMoneyRequest < ActiveRecord::Migration[5.2]
  def change
    MoneyRequestStatus.seed_data
  end
end
