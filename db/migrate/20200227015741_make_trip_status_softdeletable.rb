class MakeTripStatusSoftdeletable < ActiveRecord::Migration[5.2]
  def change
    unless TripStatus.has_attribute? :deleted_at
      add_column 'trip_statuses', :deleted_at, :datetime, index: true
    end
  end
end
