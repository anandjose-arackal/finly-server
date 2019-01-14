class AddTravelRequestAndMoneyRequestToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :travel_request_id, :integer, references: "TravelRequest", foreign_key: true, index: true
    add_column :reports, :money_request_id, :integer, references: "TravelRequest", foreign_key: true, index: true
  end
end