class RenameEnabledToAllowed < ActiveRecord::Migration
  def change
    rename_column :card_limits, :enabled, :allowed
  end
end
