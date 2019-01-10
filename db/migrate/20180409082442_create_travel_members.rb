class CreateTravelMembers < ActiveRecord::Migration[4.2]
  def change
    create_table :travel_members do |t|
      t.string :title
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.boolean :child
      t.integer :age
      t.string :email
      t.string :mobile_number
      t.references :booking, index: true, foreign_key: true
      t.references :booking_request, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
