class AddIsDeletedToBookingCar < ActiveRecord::Migration[4.2]
  def change
    add_column :booking_car_rentals, :is_deleted, :boolean, index: true, default: false
  end
end
