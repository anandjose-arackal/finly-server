class RenameBookingCustomToBookingOthers < ActiveRecord::Migration[4.2]
  def change
    rename_table :booking_customs, :booking_others
    BookingType.seed_data
  end
end
