class RenameEnabledToAllowed < ActiveRecord::Migration[4.2]
  def change
    rename_column :card_limits, :enabled, :allowed
  end
end
