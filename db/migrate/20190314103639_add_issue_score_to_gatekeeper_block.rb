class AddIssueScoreToGatekeeperBlock < ActiveRecord::Migration[5.2]
  def change
    add_column :gatekeeper_blocks, :score, :integer, index: true, default: 1, null: false
  end
end
