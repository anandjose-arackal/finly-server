class AddEnabledToCardLimits < ActiveRecord::Migration
  def change
    add_column :card_limits, :enabled, :boolean
  end
end
