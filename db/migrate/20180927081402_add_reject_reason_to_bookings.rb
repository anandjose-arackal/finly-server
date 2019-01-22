class AddRejectReasonToBookings < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :reject_reason, :text
  end
end
