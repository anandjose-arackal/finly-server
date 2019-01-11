class AddEnabledToCardLimits < ActiveRecord::Migration[4.2]
  def change
    add_column :card_limits, :enabled, :boolean
  end
end
