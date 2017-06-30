class AddDefaultToPointOfContact < ActiveRecord::Migration
  def change
    change_column_default :users, :point_of_contact, false
  end
end