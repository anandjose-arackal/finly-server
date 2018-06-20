class AddReporAndMoneyRequestToTravelRequests < ActiveRecord::Migration
  def change
    add_column :travel_requests, :report_id, :integer, references: "Report", foreign_key: true, index: true
    add_column :travel_requests, :money_request_id, :integer, references: "MoneyRequest", foreign_key: true, index: true
  end
end