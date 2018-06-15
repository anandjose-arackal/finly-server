class AddTimeToAllCustomBookingRequests < ActiveRecord::Migration
  def change
    add_column :booking_customs, :start_time, :text
    add_column :booking_customs, :end_time, :text
  end
end
