class CreateTravelRequestStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :travel_request_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
