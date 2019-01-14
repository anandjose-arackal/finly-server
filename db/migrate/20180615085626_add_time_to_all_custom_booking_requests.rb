class AddTimeToAllCustomBookingRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :booking_customs, :start_time, :text
    add_column :booking_customs, :end_time, :text
  end
end
