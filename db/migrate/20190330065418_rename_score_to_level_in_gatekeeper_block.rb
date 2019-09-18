class RenameScoreToLevelInGatekeeperBlock < ActiveRecord::Migration[5.2]
  def change
    rename_column :gatekeeper_blocks, :score, :level
  end
end
