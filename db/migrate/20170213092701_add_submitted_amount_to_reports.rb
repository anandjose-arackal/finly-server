class AddSubmittedAmountToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :submitted_amount_id, :integer, references: "Amount", foreign_key: true, nidex: true
    add_column :money_requests, :submitted_amount_id, :integer, references: "Amount", foreign_key: true, nidex: true
  end
end
