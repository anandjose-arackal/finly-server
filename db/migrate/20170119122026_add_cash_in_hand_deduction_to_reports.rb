class AddCashInHandDeductionToReports < ActiveRecord::Migration
  def change
    add_column :reports, :cash_in_hand_deduction_id, :integer, foreign_key: true, index: true
    add_column :report_tracks, :cash_in_hand_deduction_id, :integer, foreign_key: true, index: true
  end
end
