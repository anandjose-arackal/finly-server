class AddPrecisionToDistanceAndTimeFields < ActiveRecord::Migration[4.2]
  def change
    change_column :distances, :value, :decimal, precision: 10, scale: 4
    change_column :time_objects, :value, :decimal, precision: 10, scale: 4

  end
end
