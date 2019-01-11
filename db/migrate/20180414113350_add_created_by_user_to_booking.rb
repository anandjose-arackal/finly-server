class AddCreatedByUserToBooking < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :created_by_user_id, :integer,  references: 'User', foreign_key: true, index: true
    add_column :travel_members, :gender, :string
  end
end
