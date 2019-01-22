class AddLevelDataToReport < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :controlling_level_id, :integer, references: 'ReviewalLelvel', foreign_key: true
    add_column :money_requests, :controlling_level_id, :integer, references: 'ReviewalLelvel', foreign_key: true
    add_column :travel_requests, :controlling_level_id, :integer, references: 'ReviewalLelvel', foreign_key: true
    add_column :bank_payment_requests, :controlling_level_id, :integer, references: 'ReviewalLelvel', foreign_key: true
  end
end
