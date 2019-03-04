class AddTripMoneyRequestToPolicyConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :policy_configurations, :trips_money_request, :boolean, default: true
  end
end
