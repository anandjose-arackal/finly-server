class AddRejectReasonToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :reject_reason, :text
  end
end
