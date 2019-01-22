class UpdateTravelRequestAttributes < ActiveRecord::Migration[4.2]
  def change
    remove_column :travel_requests, :required_by_date
    remove_column :travel_requests, :report_id
    remove_column :travel_requests, :money_request_id
    remove_column :reports, :money_request_id
    add_reference :money_requests, :travel_request, index: true, foreign_key: true
    add_column :travel_requests, :memo, :text
    add_column :travel_requests, :from_date, :date, index: true
    add_column :travel_requests, :to_date, :date, index: true
  end
end
