class AddDefaultToPointOfContact < ActiveRecord::Migration[4.2]
  def change
    change_column_default :users, :point_of_contact, false
  end
end