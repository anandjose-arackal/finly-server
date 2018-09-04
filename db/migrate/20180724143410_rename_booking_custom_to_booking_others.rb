class RenameBookingCustomToBookingOthers < ActiveRecord::Migration
  def change
    rename_table :booking_customs, :booking_others
    BookingType.seed_data
  end
end
